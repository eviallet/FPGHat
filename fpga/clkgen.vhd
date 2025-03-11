library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity clkgen is
    generic (
        -- Prescaler => CLK_OUT = CLK_IN / 2^(P+1)
        -- For prescaler=0, CLK_OUT = CLK_IN/2
        prescaler : natural := 15;
        -- Tick allows to clock out a single tick during one MCLK period at CLK_OUT rate
        tick : boolean:= false
    );
    port(
        CLK_IN : in std_logic;
        RST : in std_logic;
        CLK_OUT : out std_logic
    );
end entity;

architecture rtl of clkgen is
    signal clk_out_signal : std_logic;
    signal counter : unsigned(prescaler downto 0);
begin
    CLK_OUT <= clk_out_signal;

    process(CLK_IN, RST) is
    begin
        if RST = '1' then
            counter <= (0 => '1', others => '0');
            clk_out_signal <= '0';
        elsif rising_edge(CLK_IN) then
            if counter(counter'high) = '1' then
                clk_out_signal <= not clk_out_signal;
                counter <= (0 => '1', others => '0');
            else
                counter <= counter + 1;
                if tick then
                    clk_out_signal <= '0';
                end if;
            end if;
        end if;
    end process;
end rtl;

