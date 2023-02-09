library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity top is
    port(
        -- FPGA
        rclk : in std_logic;
        nrst : in std_logic;

        -- INPUTS
        btn : in std_logic;

        -- LEDS
        led0 : out std_logic;

        -- Segments
        --  Digit selection
        seg_a0 : out std_logic;
        seg_a1 : out std_logic;
        seg_a2 : out std_logic;
        seg_a3 : out std_logic;
        seg_a4 : out std_logic;     
        --  Segment for selected digit
        seg_k0 : out std_logic;
        seg_k1 : out std_logic;
        seg_k2 : out std_logic;
        seg_k3 : out std_logic;
        seg_k4 : out std_logic;
        seg_k5 : out std_logic;
        seg_k6 : out std_logic;
        seg_k7 : out std_logic
    );
end entity;

architecture rtl of top is
    signal rst: std_logic;
    signal mclk: std_logic;

    signal clk_3khz : std_logic;

    signal seg_sel : std_logic_vector(3 downto 0);

begin
    -- Reset
    rst <= not nrst;

    -- Button
    led0 <= not btn;

    -- Clocks setup
    pll_inst: entity work.pll
        port map(
            REFERENCECLK => rclk,
            PLLOUTCORE => open,
            PLLOUTGLOBAL => mclk,
            RESET => rst
    );

    clkgen_inst: entity work.clkgen
        port map(
            MCLK => mclk,
            RST => rst,
            CLK_3KHZ => clk_3khz
    );

    -- Segments
    seg_a1 <= seg_sel(0); 
    seg_a2 <= seg_sel(1); 
    seg_a3 <= seg_sel(2); 
    seg_a4 <= seg_sel(3); 
    seg_driver: entity work.seg
        generic map(n_digits => 4)
        port map (
            CLK => clk_3khz,
            RST => rst,
            DIGITS => "0000000000000001",
            DP => "0100",
            SEG_SEL => seg_sel,
            SEG_A   => seg_k1,
            SEG_B   => seg_k2,
            SEG_C   => seg_k3,
            SEG_D   => seg_k4,
            SEG_E   => seg_k5,
            SEG_F   => seg_k6,
            SEG_G   => seg_k7,
            SEG_DP  => seg_k0
    );
end rtl;

