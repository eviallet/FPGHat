library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adc_tb is
end adc_tb;


architecture adc_tb_arch of adc_tb is

    --------------- SIM SETTINGS ---------------
    signal tb_finished : std_logic;
    constant clk_half_period : time := 4 ns; -- 120 MHz
    constant sim_duration : time := 1 us;

    --------------- BENCH SIGNALS --------------
    constant frame_start : time := 20 ns;
    constant frame_length : integer := 12;

    type table is array (frame_length-1 downto 0) of std_logic;
    constant adc_out_table : table := (
        '0','0','1','0','1','0','0','0','1','0','1','1'
    );
    
    --------------- PHYSICAL PINS --------------
    signal sig_sck : std_logic;
    signal sig_sdo : std_logic;
    signal sig_ssn : std_logic;

    --------------- INTERNAL SIGNALS --------------
    signal sig_clk : std_logic := 'U'; -- 'U' necessary for clock sim
    signal sig_adc_clk : std_logic;
    signal tb_rst : std_logic;
    signal sig_sdi : std_logic_vector(9 downto 0);
    signal sig_sample_request : std_logic;
    signal sig_sample_available : std_logic;

begin
    --------------- CLOCK --------------
    clkgen_baudrate: entity work.clkgen
        generic map(
            -- 120MHz/8 (2^3)= 15MHz
            prescaler => 2
        )
        port map(
            CLK_IN => sig_clk,
            RST => tb_rst,
            CLK_OUT => sig_adc_clk
    );

    --------------- DUT --------------
    dut : entity work.adc 
        port map(
            CLK  => sig_adc_clk,
            RST  => tb_rst,
            SCK  => sig_sck,
            SSN  => sig_ssn,
            SDI  => sig_sdo,
            DAT  => sig_sdi,
            SAMPLE_REQUEST => sig_sample_request,
            SAMPLE_AVAILABLE => sig_sample_available
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


    --------------- SDO --------------
    tb_generate_sdo : process(sig_sck) is
        variable current_bit : integer range 0 to frame_length;
    begin
        if rising_edge(sig_sck) then
            if current_bit > 1 and current_bit < frame_length then -- skip dummy bits
                sig_sdo <= adc_out_table(current_bit);
            end if;
            if current_bit < frame_length then
                current_bit := current_bit + 1;
            end if;
        end if;
    end process;


    --------------- Protocol --------------
    sig_sample_request <= 
     '0',
     '1' after frame_start - 2 ns, 
     '0' after frame_start + 50 ns;
   

end adc_tb_arch ;
