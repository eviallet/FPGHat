-- 
-- PLL configuration
-- 
-- This VHDL entity was generated automatically
-- using the icepll tool from the IceStorm project.
-- 
-- Given input frequency:        12.000 MHz
-- Requested output frequency:  120.000 MHz
-- Achieved output frequency:   120.000 MHz
-- 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pll is
	port (
		REFERENCECLK  :  in std_logic;
		PLLOUT : out std_logic;
		LOCKED  : out std_logic
	);
end pll;

architecture synth of pll is

	component SB_PLL40_CORE is
		generic (
			FEEDBACK_PATH : String := "SIMPLE";
			DIVR : unsigned(3 downto 0) := "0000";
			DIVF : unsigned(6 downto 0) := "1001111";
			DIVQ : unsigned(2 downto 0) := "011";
			FILTER_RANGE : unsigned(2 downto 0) := "001"
		);
		port (
			LOCK : out std_logic;
			RESETB : in std_logic;
			BYPASS : in std_logic;
			REFERENCECLK : in std_logic;
			PLLOUTGLOBAL : out std_logic
		);
	end component;

begin

	PLL1 : SB_PLL40_CORE port map (
		LOCK => locked,
		RESETB => '1',
		BYPASS => '0',
		REFERENCECLK => REFERENCECLK,
		PLLOUTGLOBAL => PLLOUT
	);

end;
