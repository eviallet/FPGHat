library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_tb is
end uart_tb;


architecture uart_tb_arch of uart_tb is

    --------------- SIM SETTINGS ---------------
    signal tb_finished : std_logic;
    constant clk_half_period : time := 4 ns; -- 120 MHz
    constant sim_duration : time := 180 us;

    --------------- BENCH SIGNALS --------------
    constant frame_start : time := 20 ns;
    constant baudrate_bit : time := 8 us; -- 115200 baud

    type table is array (12 downto 0) of std_logic;
    constant sig_rx_table : table := (
        '1','0','1','0','1','0','0','0','1','0','1','1','1'
    );
    
    --------------- PHYSICAL PINS --------------
    signal sig_rx : std_logic;
    signal sig_tx : std_logic;

    --------------- INTERNAL SIGNALS --------------
    signal sig_clk : std_logic := 'U'; -- 'U' necessary for clock sim
    signal sig_baudrate : std_logic;
    signal tb_rst : std_logic;
    signal tb_rx_sync : std_logic;
    signal sig_sdi : std_logic_vector(7 downto 0);
    signal sig_sdo : std_logic_vector(7 downto 0);
    signal sig_tx_request : std_logic;
    signal sig_rx_available : std_logic;

begin
    --------------- CLOCK --------------
    clkgen_baudrate: entity work.clkgen
        generic map(
            -- 120MHz/64 (2^6)= 1875000Hz, or 16*117187 baud (115200 + 1.7%)
            prescaler => 5
        )
        port map(
            CLK_IN => sig_clk,
            RST => tb_rst,
            CLK_OUT => sig_baudrate
    );

    --------------- DUT --------------
    dut : entity work.uart 
        port map (
            CLK  => sig_baudrate,
            RST  => tb_rst,
            RX => tb_rx_sync,
            SDI => sig_sdi,
            TX => sig_tx,
            SDO => sig_sdi, -- echo
            TX_REQUEST => sig_tx_request,
            RX_AVAILABLE => sig_rx_available
    );

    --------------- BUFFER --------------
    rx_buf : entity work.buf
        port map (
            CLK  => sig_clk,
            RST  => tb_rst,
            INP  => sig_rx,
            OUTP => tb_rx_sync
    );

    --------------- ASYNCHRONOUS --------------
    sig_clk <=
        '0' when sig_clk = 'U' else
        '1' after clk_half_period when tb_finished /= '1' and sig_clk = '0' else
        '0' after clk_half_period when tb_finished /= '1' and sig_clk = '1';

    tb_finished <=
        '0',
        '1' after sim_duration;

    tb_rst <=
        '1',
        '0' after 10 ns;


    --------------- RX --------------
    tb_generate_rx : process is
    begin
        if tb_finished /= '1' then
            for i in sig_rx_table'range loop
                sig_rx <= sig_rx_table(i);
                wait for baudrate_bit;
            end loop;
            sig_rx <= '1';
            wait;
        end if;
    end process;


    --------------- TX --------------
    -- Echo
    sig_tx_request <= sig_rx_available;
   

end uart_tb_arch ;
