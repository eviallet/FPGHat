library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity seg is 
    generic(
        n_digits : natural := 4;
        clock_edges_per_digit : natural := 10;
        drive_periods_per_digit : natural := 5
    );

    port(
        CLK : in std_logic;
        RST : in std_logic;

        -- Digits to display ("0000" to "1111" each)
        DIGITS : in std_logic_vector(n_digits*4-1 downto 0);
        -- Decimal points
        DP : in std_logic_vector(n_digits-1 downto 0);

        -- Segments output
        SEG_SEL : out std_logic_vector(n_digits-1 downto 0);
        SEG_A   : out std_logic;
        SEG_B   : out std_logic;
        SEG_C   : out std_logic;
        SEG_D   : out std_logic;
        SEG_E   : out std_logic;
        SEG_F   : out std_logic;
        SEG_G   : out std_logic;
        SEG_DP  : out std_logic
    );

end entity;

architecture rtl of seg is
    signal segments : std_logic_vector(6 downto 0);
    signal seg_select : std_logic_vector(n_digits-1 downto 0); -- the segment which is currently set to 1 is lightened up (anode)
begin
    -- Map physical pins to a vector for easy assignments
    SEG_A <= segments(6);
    SEG_B <= segments(5);
    SEG_C <= segments(4);
    SEG_D <= segments(3);
    SEG_E <= segments(2);
    SEG_F <= segments(1);
    SEG_G <= segments(0);

    SEG_SEL <= seg_select;

    process(CLK, RST) is
        variable current_period : natural range 0 to clock_edges_per_digit; -- number of periods to light up a given digit (ie. its segments and decimal point)
        variable current_digit : natural range 0 to n_digits-1; -- keep track of which digit is displayed
        variable rolling_digits : std_logic_vector(n_digits*4-1 downto 0); -- rolling buffer; last 4 bits are the digit to display
        variable displayed_digit : std_logic_vector(3 downto 0); -- used to provide a static vector to the 'case' statement
    begin
        if RST = '1' then
            -- Internal variables
            current_period := 0;
            current_digit := 0;
            rolling_digits := (others => '0');
            displayed_digit := "0000";
            -- External signals
            segments <= (others => '1'); -- digit
            seg_select <= (3 => '1', others => '0');
            SEG_DP <= '1'; -- decimal point
        elsif rising_edge(CLK) then
            if current_digit = 0 and current_period = 0 then
                -- On rollover, refresh digits and decimal points to display
                rolling_digits := DIGITS;
            end if;
            if current_period = 0 then
                -- Decimal point
                SEG_DP <= DP(current_digit);
                -- Digit
                displayed_digit := rolling_digits(3 downto 0);
                case displayed_digit is
                    --    DIGIT                 ABCDEFG
                    when "0000" => segments <= "0000001";
                    when "0001" => segments <= "1001111";
                    when "0010" => segments <= "0010010";
                    when "0011" => segments <= "0000110";
                    when "0100" => segments <= "1001100";
                    when "0101" => segments <= "0100100";
                    when "0110" => segments <= "0100000";
                    when "0111" => segments <= "0001111";
                    when "1000" => segments <= "0000000";
                    when "1001" => segments <= "0000100";
                    when "1010" => segments <= "0001000"; -- A
                    when "1011" => segments <= "1100000"; -- b
                    when "1100" => segments <= "0110001"; -- C
                    when "1101" => segments <= "1000011"; -- d
                    when "1110" => segments <= "0110000"; -- E
                    when "1111" => segments <= "0111000"; -- F
                    when others => null;
                end case;
                current_period := current_period + 1;
            elsif current_period < clock_edges_per_digit then
                current_period := current_period + 1;

                -- Turn off segments drive after `drive_periods_per_digit` clock periods
                if current_period = drive_periods_per_digit then
                    segments <= (others => '1');
                    SEG_DP <= '1';
                end if;

            else -- current_period = `clock_edges_per_digit`
                current_period := 0;
                
                -- Currently displayed digit
                if current_digit = n_digits-1 then
                    current_digit := 0;
                else 
                    current_digit := current_digit + 1;
                    -- Shift to the next digit to display
                    rolling_digits := "0000" & rolling_digits(rolling_digits'high downto 4);
                end if;
                    
                -- Select the next segment
                seg_select <= seg_select(0) & seg_select(seg_select'high downto 1);
                
            end if;
        end if;
    end process;
end rtl;
