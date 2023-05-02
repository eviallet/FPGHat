library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity adc is
    generic (
        -- TODO adc_count : natural := 2;
        adc_data_bits : natural := 10;
        adc_dummy_bits : natural := 2
    );
    port (
        CLK  : in  std_logic;
        RST  : in  std_logic;
        -- Physical pins
        SCK  : out std_logic;
        SSN  : out std_logic;
        -- TODO SDI  : in std_logic_vector(adc_count downto 0);
        SDI  : in std_logic;
        -- Registers
        -- TODO DAT  : out std_logic_vector(((adc_count+1)*adc_data_bits)-1 downto 0);
        DAT  : out std_logic_vector(adc_data_bits-1 downto 0);
        -- Control & monitoring
        SAMPLE_REQUEST : in std_logic;
        SAMPLE_AVAILABLE : out std_logic
    );
end entity;


architecture rtl of adc is

    type fsm_state is (
        state_idle,
        state_data,
        state_end
    );
    signal state : fsm_state;

    signal active : std_logic := '0';

begin

    SCK <= CLK when active = '1' else '0';


    adc_handler : process(CLK, RST) is
        variable dummy_bit_cnt : integer range 0 to adc_dummy_bits;
        variable data_bit_cnt : integer range 0 to adc_data_bits;
        variable state_next : fsm_state;
    begin
    
        if RST = '1' then
            -- Internal variables
            state <= state_idle;
            data_bit_cnt := 0;
            dummy_bit_cnt := 0;
            active <= '0';
            SAMPLE_AVAILABLE <= '0';
            -- External signals
            SSN <= '1';
            DAT <= (others => '0');
        elsif rising_edge(CLK) then
            case state is
            
                when state_idle =>
                    -- Idle state
                    data_bit_cnt := 0;
                    dummy_bit_cnt := 0;
                    active <= '0';
                    SAMPLE_AVAILABLE <= '0';
                    -- Frame trigger
                    if SAMPLE_REQUEST = '1' then
                        SSN <= '0';
                        active <= '1';
                        state <= state_data; 
                    end if;
                    
                when state_data =>
                    if dummy_bit_cnt < adc_dummy_bits then
                        dummy_bit_cnt := dummy_bit_cnt + 1;
                    else
                        -- TODO for adc_idx in 0 to adc_count loop
                        --     DAT(data_bit_cnt) <= SDI(adc_idx);
                        -- end loop;
                        DAT(adc_data_bits-data_bit_cnt-1) <= SDI;
                        data_bit_cnt := data_bit_cnt + 1;
                        if data_bit_cnt = adc_data_bits then
                            state <= state_end;
                        end if;
                    end if;
    
                when state_end =>
                    active <= '0';
                    SSN <= '1';
                    SAMPLE_AVAILABLE <= '1';
                    if SAMPLE_REQUEST = '0' then
                        state <= state_idle;
                    end if;
            end case;
        end if;

    end process;

end architecture;
