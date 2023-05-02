library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity buf is
    generic (
        rst_state : std_logic := '0'
    );
    port (
        CLK  : in  std_logic;
        RST  : in  std_logic;
        INP  : in  std_logic;
        OUTP : out std_logic
    );
end entity;

architecture rtl of buf is
    signal tmp : std_logic := rst_state;
begin
    process (CLK, RST) is
    begin
        if RST = '1' then
            tmp <= rst_state;
            OUTP <= rst_state;
        elsif rising_edge(CLK) then
            OUTP <= tmp;
            tmp <= INP;
        end if;
    end process;
end architecture;
