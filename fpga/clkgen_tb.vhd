library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity clkgen_tb is
end entity;

architecture rtl of clkgen_tb is
    --------------- SIM SETTINGS ---------------
    signal tb_finished : std_logic;
    constant clk_half_period : time := 0.5 us; -- 1 MHz
    constant sim_clk_periods : natural := 50;
    constant sim_duration : time := clk_half_period * 2 * sim_clk_periods;

    --------------- DUT SIGNALS --------------
    signal sig_in_clk : std_logic := 'U'; -- 'U' necessary for clock sim
    signal in_rst : std_logic;
    signal sig_out_clk : std_logic;
begin
    --------------- DUT --------------
    dut : entity work.clkgen 
        generic map(
            prescaler => 2,
            tick => true
        )
        port map(
            CLK_IN => sig_in_clk,
            RST => in_rst,
            CLK_OUT => sig_out_clk
    );

    --------------- ASYNCHRONOUS --------------
    sig_in_clk <=
        '0' when sig_in_clk = 'U' else
        '1' after clk_half_period when tb_finished /= '1' and sig_in_clk = '0' else
        '0' after clk_half_period when tb_finished /= '1' and sig_in_clk = '1';

    tb_finished <=
        '0',
        '1' after sim_duration;

    in_rst <=
        '1',
        '0' after 10 ns;
    
end rtl;
