library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity clkgen is
    port(
        MCLK : in std_logic;
        RST : in std_logic;

        -- Clock outputs
        CLK_3KHZ : out std_logic
    );
end entity;

architecture rtl of clkgen is
    signal clk_3khz_signal : std_logic;

    -- 120MHz/32768 = 3.6kHz ; state change 2 times faster, every 16384 rising edges
    signal counter : unsigned(13 downto 0);
begin
    CLK_3KHZ <= clk_3khz_signal;

    process(MCLK, RST) is
    begin
        if RST = '1' then
            counter <= (others => '0');
            clk_3khz_signal <= '0';
        elsif rising_edge(MCLK) then
            counter <= counter + 1;
            if counter(counter'high) = '1' then
                clk_3khz_signal <= not clk_3khz_signal;
                counter <= (others => '0');
            end if;
        end if;
    end process;
end rtl;


-- architecture rtl of clkgen is
--     signal clk_3khz_signal : std_logic;

--     -- 120MHz/16384 = 7.3kHz ; state change 2 times faster, every 8192 rising edges
-- begin
--     CLK_3KHZ <= clk_3khz_signal;

--     process(MCLK, RST) is
--         variable counter : integer range 0 to 8192;
--     begin
--         if RST = '1' then
--             counter := 0;
--             clk_3khz_signal <= '0';
--         elsif rising_edge(MCLK) then
--             counter := counter + 1;
--             if counter = 8192 then
--                 clk_3khz_signal <= not clk_3khz_signal;
--                 counter := 0;
--             end if;
--         end if;
--     end process;
-- end rtl;
