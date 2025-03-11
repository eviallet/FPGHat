library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity seg_tb is
end entity;

architecture rtl of seg_tb is
    --------------- SIM SETTINGS ---------------
    signal tb_finished : std_logic;
    constant clk_half_period : time := 333 us; -- 3 kHz
    constant sim_clk_periods : natural := 28;
    constant sim_duration : time := clk_half_period * 2 * sim_clk_periods;

    --------------- DUT SIGNALS --------------
    signal sig_in_clk : std_logic := 'U'; -- 'U' necessary for clock sim
    signal in_rst : std_logic;
    signal sig_in_digits : std_logic_vector(7 downto 0) := (others => 'U');
    signal sig_in_dp : std_logic_vector(1 downto 0) := (others => 'U');
    signal sig_out_sel : std_logic_vector(1 downto 0);
    signal sig_out_segs : std_logic_vector(7 downto 0);
begin
    --------------- DUT --------------
    dut : entity work.seg generic map(n_digits => 2)
        port map(
            CLK => sig_in_clk,
            RST => in_rst,
            -- Digits to display (0000 to FFFF)
            DIGITS => sig_in_digits,
            -- Decimal points
            DP => sig_in_dp,
            -- Segments output
            SEG_SEL => sig_out_sel,
            SEG_A   => sig_out_segs(7),
            SEG_B   => sig_out_segs(6),
            SEG_C   => sig_out_segs(5),
            SEG_D   => sig_out_segs(4),
            SEG_E   => sig_out_segs(3),
            SEG_F   => sig_out_segs(2),
            SEG_G   => sig_out_segs(1),
            SEG_DP  => sig_out_segs(0)
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

    -- Try to display "1" for the first seg display, "2" for the other
    sig_in_digits <=
        "10010001", 
        "00000010" after clk_half_period * 2 * 20;

    -- Try to display a decimal point between both digits
    sig_in_dp <= "10" when in_rst = '0';


    
end rtl;
