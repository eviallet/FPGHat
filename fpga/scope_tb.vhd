library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity scope_tb is
end scope_tb;


architecture scope_tb_arch of scope_tb is

    --------------- SIM SETTINGS ---------------
    signal tb_finished : std_logic;
    constant clk_half_period : time := 4 ns; -- 120 MHz

    --------------- BENCH SIGNALS --------------
    constant sample_count : integer := 10;
    constant adc_data_bits : integer := 10;
    constant adc_count : integer := 2;

    type table is array (sample_count downto 0) of std_logic_vector((adc_count * adc_data_bits)-1 downto 0);
    constant samples_table : table := (
        "00000000000011001011",
        "00101000000010101110",
        "01001111000011000110",
        "01110100000010101010",
        "10010110010011001110",
        "10110100110010011011",
        "11001110110011010100",
        "11100011110011001010",
        "11110011000010111110",
        "11111100100010110001",
        "11111111110011001100"
    );
    
    --------------- DUT PINS --------------
    -- Physical pins
    signal sig_armed    : std_logic; 
    signal sig_trigged  : std_logic; 
    -- Registers 
    signal sig_sample : std_logic_vector((adc_count*adc_data_bits)-1 downto 0); 
    signal sig_keep_sample : std_logic; 
    -- Control & monitoring
    signal sig_sample_updated : std_logic; 
    signal sig_acq_request : std_logic; 
    signal sig_acq_single  : std_logic; 
    signal sig_acq_count   : std_logic_vector(15 downto 0); 
    signal sig_acq_done    : std_logic; 
    -- Trigger control
    signal sig_trig_source : std_logic_vector(adc_count-1 downto 0); 
    signal sig_trig_level : std_logic_vector(adc_data_bits-1 downto 0); 
    signal sig_trig_slope : std_logic := '1';

    --------------- INTERNAL SIGNALS --------------
    signal sig_clk : std_logic := 'U'; -- 'U' necessary for clock sim
    signal sig_sample_clk : std_logic;
    signal tb_rst : std_logic;
    signal sig_table_finished : std_logic := '0';

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
            CLK_OUT => sig_sample_clk
    );

    --------------- DUT --------------
    dut : entity work.scope 
        port map(
            CLK  => sig_clk,
            RST  => tb_rst,
            -- Physical pins
            ARMED    => sig_armed,
            TRIGGED  => sig_trigged,
            -- Registers 
            SAMPLE => sig_sample,
            KEEP_SAMPLE => sig_keep_sample,
            -- Control & monitoring
            SAMPLE_UPDATED => sig_sample_clk,
            ACQ_REQUEST => sig_acq_request, 
            ACQ_SINGLE  => sig_acq_single,
            ACQ_COUNT   => sig_acq_count,
            ACQ_DONE    => sig_acq_done,
            -- Trigger control
            TRIG_SOURCE => sig_trig_source,
            TRIG_LEVEL => sig_trig_level,
            TRIG_SLOPE => sig_trig_slope
            -- TRIG_DELAY
    );

    --------------- ASYNCHRONOUS --------------
    sig_clk <=
        '0' when sig_clk = 'U' else
        '1' after clk_half_period when tb_finished /= '1' and sig_clk = '0' else
        '0' after clk_half_period when tb_finished /= '1' and sig_clk = '1';

    tb_finished <= sig_table_finished;

    tb_rst <=
        '1',
        '0' after 10 ns;


    --------------- SDO --------------
    tb_generate_samples : process(sig_sample_clk) is
        variable current_sample : integer range 0 to sample_count;
    begin
        if rising_edge(sig_sample_clk) then
            if current_sample < sample_count then
                sig_sample <= samples_table(current_sample);
            else
                sig_table_finished <= '1';
            end if;
        end if;
    end process;


    -- --------------- Protocol --------------
    -- sig_sample_request <= 
    --  '0',
    --  '1' after frame_start - 2 ns, 
    --  '0' after frame_start + 50 ns;
   

end scope_tb_arch ;
