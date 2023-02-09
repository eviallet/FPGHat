library IEEE;
use IEEE.std_logic_1164.all;

entity pll is
    port(
        REFERENCECLK: in std_logic;
        RESET: in std_logic;
        PLLOUTCORE: out std_logic;
        PLLOUTGLOBAL: out std_logic
    );
end entity pll;

architecture rtl of pll is
    signal openwire : std_logic;
    signal openwirebus : std_logic_vector(7 downto 0);

    component SB_PLL40_CORE 
        generic (
            --- Feedback
            FEEDBACK_PATH : string := "SIMPLE"; -- String (simple, delay, phase_and_delay, external)
            DELAY_ADJUSTMENT_MODE_FEEDBACK : string := "FIXED"; 
            DELAY_ADJUSTMENT_MODE_RELATIVE : string := "FIXED"; 
            SHIFTREG_DIV_MODE : bit_vector(1 downto 0)  := "00"; --  0-->Divide by 4, 1-->Divide by 7, 3 -->Divide by 5  
            FDA_FEEDBACK : bit_vector(3 downto 0) := "0000"; --  Integer (0-15). 
            FDA_RELATIVE : bit_vector(3 downto 0) := "0000"; --  Integer (0-15).
            PLLOUT_SELECT : string := "GENCLK";

            --- Use 'icepll' to determine values below
            DIVF : bit_vector(6 downto 0); 
            DIVR : bit_vector(3 downto 0);
            DIVQ : bit_vector(2 downto 0);
            FILTER_RANGE : bit_vector(2 downto 0);

            --- Additional C-Bits
            ENABLE_ICEGATE : bit := '0';

            --- Test Mode Parameter 
            TEST_MODE : bit := '0';
            EXTERNAL_DIVIDE_FACTOR : integer := 1
        );

        port (
            REFERENCECLK : in std_logic; -- Driven by core logic
            PLLOUTCORE : out std_logic; -- PLL output to core logic
            PLLOUTGLOBAL : out std_logic; -- PLL output to global network
            EXTFEEDBACK : in std_logic; -- Driven by core logic
            DYNAMICDELAY : in std_logic_vector (7 downto 0); -- Driven by core logic
            LOCK : out std_logic; -- Output of PLL
            BYPASS : in std_logic; -- Driven by core logic
            RESETB : in std_logic; -- Driven by core logic
            LATCHINPUTVALUE : in std_logic; -- iCEGate Signal
            -- Test Pins
            SDO : out std_logic; -- Output of PLL
            SDI : in std_logic; -- Driven by core logic
            SCLK : in std_logic -- Driven by core logic
        );
    end component;

begin
    -- icepll -i 12 -o 120
    -- F_PLLIN:    12.000 MHz (given)
    -- F_PLLOUT:  120.000 MHz (requested)
    -- F_PLLOUT:  120.000 MHz (achieved)
    -- FEEDBACK: SIMPLE
    -- F_PFD:   12.000 MHz
    -- F_VCO:  960.000 MHz
    -- DIVR:  0 (4'b0000)
    -- DIVF: 79 (7'b1001111)
    -- DIVQ:  3 (3'b011)
    -- FILTER_RANGE: 1 (3'b001)
    

    pll_inst: SB_PLL40_CORE
        generic map(
            DIVR => "0000",
            DIVF => "1001111",
            DIVQ => "011",
            FILTER_RANGE => "001",
            FEEDBACK_PATH => "SIMPLE",
            DELAY_ADJUSTMENT_MODE_FEEDBACK => "FIXED",
            FDA_FEEDBACK => "0000",
            DELAY_ADJUSTMENT_MODE_RELATIVE => "FIXED",
            FDA_RELATIVE => "0000",
            SHIFTREG_DIV_MODE => "00",
            PLLOUT_SELECT => "GENCLK",
            ENABLE_ICEGATE => '0'
        )
        port map(
            REFERENCECLK => REFERENCECLK,
            PLLOUTCORE => PLLOUTCORE,
            PLLOUTGLOBAL => PLLOUTGLOBAL,
            EXTFEEDBACK => openwire,
            DYNAMICDELAY => openwirebus,
            RESETB => RESET,
            BYPASS => '0',
            LATCHINPUTVALUE => openwire,
            LOCK => open,
            SDI => openwire,
            SDO => open,
            SCLK => openwire
    );

end rtl;


