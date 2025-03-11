library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity scope is
    generic (
        adc_count : natural := 2;
        adc_data_bits : natural := 10;
        mem_max_sample_count : natural := 7680
    );
    port (
        CLK  : in  std_logic;
        RST  : in  std_logic;
        -- Physical pins
        ARMED    : out std_logic;
        TRIGGED  : out std_logic;
        -- Registers
        SAMPLE : in std_logic_vector((adc_count*adc_data_bits)-1 downto 0);
        KEEP_SAMPLE : out std_logic;
        -- Control & monitoring
        SAMPLE_UPDATED : in std_logic;
        ACQ_REQUEST : in std_logic;
        ACQ_SINGLE  : in std_logic;
        ACQ_COUNT   : in std_logic_vector(15 downto 0);
        ACQ_DONE    : out std_logic;
        -- Trigger control
        TRIG_SOURCE : in std_logic_vector(adc_count-1 downto 0);
        TRIG_LEVEL : in std_logic_vector(adc_data_bits-1 downto 0);
        TRIG_SLOPE : in std_logic -- 1 = positive, 0 = negative
        -- TRIG_DELAY : in std_logic;
    );
end entity;


architecture rtl of scope is

    type fsm_state is (
        state_idle,
        state_armed,
        state_trig,
        state_end
    );
    signal state : fsm_state;

begin

    scope_handler : process(CLK, RST) is
        variable acq_counter : integer range 0 to 2**16-1;
        variable is_trigged : boolean;
        variable trig_source_sample : std_logic_vector(adc_data_bits downto 0);
    begin
    
        if RST = '1' then
            -- Internal variables
            state <= state_idle;
            is_trigged := false;
            ACQ_DONE <= '0';
            ARMED    <= '0';
            TRIGGED  <= '0';
        elsif rising_edge(CLK) then
            case state is
            
                when state_idle =>
                    KEEP_SAMPLE <= '0';
                    is_trigged := false;
                    
                    if ACQ_REQUEST = '1' then
                        acq_counter := 0;
                        ARMED <= '1';
                        state <= state_armed; 
                    end if;
                    
                when state_armed =>
                    KEEP_SAMPLE <= '1';
                    if is_trigged then
                        -- Trigged, keep storing samples until having acquired enough samples
                        acq_counter := acq_counter + 1;
                        if to_unsigned(acq_counter, 16) = unsigned(ACQ_COUNT) then
                            state <= state_end;
                        end if;
                    else
                        -- Extract sample from samples vector coming from all sources
                        -- TODO better approach allowing more than 2 channels
                        if TRIG_SOURCE = "01" then
                            trig_source_sample := SAMPLE(SAMPLE'high downto SAMPLE'high-adc_data_bits);
                        elsif TRIG_SOURCE = "10" then
                            trig_source_sample := SAMPLE(adc_data_bits-1 downto 0);
                        end if;

                        -- Trigger logic
                        if TRIG_SLOPE = '1' then -- Positive slope : signal above trigger level ?
                            if unsigned(trig_source_sample) > unsigned(TRIG_LEVEL) then
                                state <= state_trig;
                            end if;
                        else -- Negative slope
                            if unsigned(trig_source_sample) < unsigned(TRIG_LEVEL) then
                                state <= state_trig;
                            end if;
                        end if;
                    end if;

                when state_trig =>
                    TRIGGED <= '1';
                    is_trigged := true;
                    state <= state_armed;
    
                when state_end =>
                    ACQ_DONE <= '1';
                    KEEP_SAMPLE <= '0';
                    TRIGGED <= '0';
                    is_trigged := false;
                    if ACQ_SINGLE = '1' then
                        state <= state_idle;
                    else
                        acq_counter := 0;
                        state <= state_armed;
                    end if;
            end case;
        end if;

    end process;

end architecture;
