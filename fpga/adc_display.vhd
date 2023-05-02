library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;

entity adc_display is
    generic(
        adc_data_bits : natural := 10;
        ram_addr_bits : natural := 8;
        n_digits : natural := 4
    );
    port (
        CLK : in  std_logic;
        RST : in  std_logic;
        -- Registers
        DAT : in std_logic_vector(adc_data_bits-1 downto 0);
        DIGITS : out std_logic_vector(n_digits*4-1 downto 0);
        -- Control & monitoring
        REQUEST : in std_logic
    );
end entity;


architecture rtl of adc_display is
    component SB_RAM40_4K is
        generic (
            INIT_0 : std_logic_vector(255 downto 0);
            INIT_1 : std_logic_vector(255 downto 0);
            INIT_2 : std_logic_vector(255 downto 0);
            INIT_3 : std_logic_vector(255 downto 0);
            INIT_4 : std_logic_vector(255 downto 0);
            INIT_5 : std_logic_vector(255 downto 0);
            INIT_6 : std_logic_vector(255 downto 0);
            INIT_7 : std_logic_vector(255 downto 0);
            INIT_8 : std_logic_vector(255 downto 0);
            INIT_9 : std_logic_vector(255 downto 0);
            INIT_A : std_logic_vector(255 downto 0);
            INIT_B : std_logic_vector(255 downto 0);
            INIT_C : std_logic_vector(255 downto 0);
            INIT_D : std_logic_vector(255 downto 0);
            INIT_E : std_logic_vector(255 downto 0);
            INIT_F : std_logic_vector(255 downto 0)
        );
        port (
            RCLK : in std_logic;
            RCLKE : in std_logic;
            RADDR : in std_logic_vector(7 downto 0);
            RDATA : out std_logic_vector(15 downto 0);
            RE : in std_logic;
            WCLK : in std_logic;
            WCLKE : in std_logic;
            WADDR : in std_logic_vector(7 downto 0);
            WDATA : in std_logic_vector(15 downto 0);
            WE : in std_logic
        );
    end component;

    signal read_output : std_logic_vector(15 downto 0);
    signal openwire : std_logic;
    signal openaddr : std_logic_vector(7 downto 0);
    signal openreg : std_logic_vector(15 downto 0);

    signal addr : std_logic_vector(7 downto 0);
    signal read_request : std_logic := '0';

    ---- States ----
    type ram_state is (
        state_idle,
        state_reading,
        state_latch,
        state_done
    );
begin

    addr <= DAT(DAT'high downto adc_data_bits-ram_addr_bits);

    ram_inst: SB_RAM40_4K
        generic map (
            INIT_0 => X"0195018201690156014301300117010400910078006500520039002600130000",
            INIT_1 => X"0403039003770364035103380325031202990286027302600247023402210208",
            INIT_2 => X"0611059805850572055905460533052005070494048104680455044204290416",
            INIT_3 => X"0819080607930780076707540741072807150702068906760663065006370624",
            INIT_4 => X"1027101410010988097509620949093609230910089708840871085808450832",
            INIT_5 => X"1235122212091196118311701157114411311118110510921079106610531040",
            INIT_6 => X"1443143014171404139113781365135213391326131313001287127412611248",
            INIT_7 => X"1651163816251612159915861573156015471534152115081495148214691456",
            INIT_8 => X"1859184618331820180717941781176817551742172917161703169016771664",
            INIT_9 => X"2067205420412028201520021989197619631950193719241911189818851872",
            INIT_A => X"2275226222492236222322102197218421712158214521322119210620932080",
            INIT_B => X"2483247024572444243124182405239223792366235323402327231423012288",
            INIT_C => X"2691267826652652263926262613260025872574256125482535252225092496",
            INIT_D => X"2899288628732860284728342821280827952782276927562743273027172704",
            INIT_E => X"3107309430813068305530423029301630032990297729642951293829252912",
            INIT_F => X"0000330232893276326332503237322432113198318531723159314631333120"
        )
        port map (
            RDATA => read_output,
            RADDR => addr,
            RCLK => CLK,
            RCLKE => read_request,
            RE => '1',
            WADDR => openaddr,
            WCLK => openwire,
            WCLKE => openwire,
            WDATA => openreg,
            WE => '0'
    );
    
    process(CLK, RST)
        variable state : ram_state := state_idle;
    begin
        if RST = '1' then
            state := state_idle;
            read_request <= '0';
        elsif rising_edge(CLK) then
            case state is
                when state_idle => 
                    if REQUEST = '1' then
                        state := state_latch;
                        read_request <= '1';
                    end if;

                when state_reading =>
                    state := state_latch;

                when state_latch =>
                    read_request <= '0';
                    DIGITS <= read_output(n_digits*4-1 downto 0);
                    state := state_done;

                when state_done =>
                    state := state_idle;
            end case;
        end if;
    end process;
end architecture;
