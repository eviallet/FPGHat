library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;


entity uart is 
    generic(
        n : natural := 8; -- Data bits
        oversampling : natural := 16
    );
    port (
        CLK : in std_logic; -- sampling clock
        RST : in std_logic;

        RX : in  std_logic; -- RX physical pin
        SDI : out std_logic_vector(n-1 downto 0); -- RX input register
        RX_AVAILABLE : out std_logic; -- Pulled high when data available
        TX : out std_logic; -- TX physical pin
        SDO : in  std_logic_vector(n-1 downto 0);  -- TX output register
        TX_REQUEST : in std_logic -- Set high to trigger frame
    );
end uart;

architecture uart_arch of uart is 

    ---- RX ----
    type uart_rx_state is (
        state_rx_idle, -- RX lane = '1'
        state_rx_data, -- next bit
        state_rx_wait, -- baudrate sync
        state_rx_stop -- stop bit
    );
    signal rx_state : uart_rx_state;

    ---- TX ----
    type uart_tx_state is (
        state_tx_idle, -- TX lane set to '1'
        state_tx_wait, -- wait next bit
        state_tx_data, -- send the next bit
        state_tx_stop -- send a stop bit
    );
    signal tx_state : uart_tx_state;
begin
    rx_handler : process(CLK, RST) is
        variable bit_cnt : integer range 0 to n; -- bit counter
        variable clk_cnt : integer range 0 to oversampling; -- current clock counter
        variable wait_cnt : integer range 0 to oversampling; -- target clock counter
        variable rx_state_next : uart_rx_state;
        variable is_start_bit : boolean;
    begin

    if RST = '1' then
        rx_state <= state_rx_idle;
        clk_cnt := 0;
        bit_cnt := 0;
        is_start_bit := true;
        SDI <= (others => '0');
        RX_AVAILABLE <= '0';
    elsif rising_edge(CLK) then
        case rx_state is
        
            when state_rx_idle => -- wait for a start bit
                RX_AVAILABLE <= '0';
                if RX = '0' then
                    bit_cnt := 0;
                    is_start_bit := true;
                    wait_cnt := oversampling / 2; -- align to mid bit
                    rx_state <= state_rx_wait; 
                    rx_state_next := state_rx_data;
                end if;
                
            when state_rx_wait =>
                clk_cnt := clk_cnt + 1;
                if clk_cnt = wait_cnt-1 then
                    clk_cnt := 0;
                    rx_state <= rx_state_next;
                end if;
                
            when state_rx_data =>
                wait_cnt := oversampling; -- wait 16 clocks (a full bit length)
                if is_start_bit then
                    is_start_bit := false;
                    rx_state <= state_rx_wait; 
                else
                    SDI(bit_cnt) <= RX;
                    bit_cnt := bit_cnt + 1;
                    rx_state <= state_rx_wait;
                    if bit_cnt = n then
                        rx_state_next := state_rx_stop;
                    end if;
                end if;

            when state_rx_stop => -- wait for a stop bit
                if RX = '1' then
                    rx_state <= state_rx_idle;
                    RX_AVAILABLE <= '1';
                end if;
        end case;
    end if;

    end process;
        

    
    tx_handler : process(CLK, RST) is
        variable bit_cnt : integer range 0 to n; -- bit counter
        variable clk_cnt : integer range 0 to oversampling; -- current clock counter
        variable wait_cnt : integer range 0 to oversampling; -- target clock counter
        variable tx_state_next : uart_tx_state;
    begin

    if RST = '1' then
        tx_state <= state_tx_idle;
        clk_cnt := 0;
        bit_cnt := 0;
        TX <= '1';
    elsif rising_edge(CLK) then
        case tx_state is
        
            when state_tx_idle => -- create a start bit
                if TX_REQUEST = '1' then
                    bit_cnt := 0;
                    TX <= '0';
                    wait_cnt := oversampling / 2; -- align to mid bit
                    tx_state <= state_tx_wait; 
                    tx_state_next := state_tx_data;
                end if;
                
            when state_tx_wait =>
                clk_cnt := clk_cnt + 1;
                if clk_cnt = wait_cnt then
                    clk_cnt := 0;
                    tx_state <= tx_state_next;
                end if;
                
            when state_tx_data =>
                wait_cnt := oversampling; -- wait 16 clocks (a full bit length)
                TX <= SDO(bit_cnt);
                bit_cnt := bit_cnt + 1;
                tx_state <= state_tx_wait;
                if bit_cnt = n then
                    tx_state_next := state_tx_stop;
                end if;

            when state_tx_stop => -- wait for a stop bit
                TX <= '1';
                if TX_REQUEST = '0' then
                    tx_state <= state_tx_idle;
                end if;
        end case;
    end if;

    end process;
        
    
end uart_arch ; 
