library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity spi is
    generic (
        data_bits : natural := 8
    );
    port (
        CLK  : in  std_logic;
        RST  : in  std_logic;
        -- Physical pins
        SCK  : out std_logic;
        SSN  : out std_logic;
        SDO  : out std_logic;
        -- Registers
        DAT  : in std_logic_vector(data_bits-1 downto 0);
        -- Control & monitoring
        TRANSMIT_REQUEST : in std_logic
    );
end entity;


architecture rtl of spi is

    type fsm_state is (
        state_idle,
        state_data,
        state_end
    );
    signal state : fsm_state;

    signal active : std_logic := '0';

begin

    SCK <= not CLK when active = '1' else '0';

    spi_handler : process(CLK, RST) is
        variable data_bit_cnt : integer range 0 to data_bits;
        variable state_next : fsm_state;
    begin
    
        if RST = '1' then
            -- Internal variables
            state <= state_idle;
            data_bit_cnt := 0;
            active <= '0';
            -- External signals
            SSN <= '1';

        elsif rising_edge(CLK) then
            case state is
            
                when state_idle =>
                    -- Idle state
                    data_bit_cnt := 0;
                    active <= '0';
                    -- Frame trigger
                    if TRANSMIT_REQUEST = '1' then
                        SSN <= '0';
                        active <= '1';
                        state <= state_data; 
                    end if;
                    
                when state_data =>
                    SDO <= DAT(data_bit_cnt);
                    data_bit_cnt := data_bit_cnt + 1;
                    if data_bit_cnt = data_bits then
                        state <= state_end;
                        active <= '0';
                    end if;
    
                when state_end =>
                    SSN <= '1';
                    if TRANSMIT_REQUEST = '0' then
                        state <= state_idle;
                    end if;
            end case;
        end if;

    end process;

end architecture;
