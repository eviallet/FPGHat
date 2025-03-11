library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity top is
    port(
        -- FPGA
        rclk : in std_logic;
        nrst : in std_logic;

        -- -- INPUTS
        btn : in std_logic;
        sw : in std_logic;

        -- LEDS
        led0 : out std_logic;
        led1 : out std_logic;
        led2 : out std_logic;
        led3 : out std_logic;
        led4 : out std_logic;
        led5 : out std_logic;
        led6 : out std_logic;
        led7 : out std_logic;

        -- ADCs
        adc_ssn  : out std_logic;
        adc_clk  : out std_logic; 
        adc1_sdo : in std_logic;
        adc2_sdo : in std_logic;

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
        seg_k7 : out std_logic;

        -- UART
        ftdi_rx : in std_logic;
        ftdi_tx : out std_logic;
        fpga_rx : in std_logic;
        fpga_tx : out std_logic;

        -- SPI
        st_spi_sck : out std_logic;
        st_spi_sdo : out std_logic;
        st_spi_nss : out std_logic;

        -- Connectors
        -- CN1
        cn1_1 : out std_logic; 
        cn1_2 : out std_logic; 
        cn1_3 : out std_logic; 
        cn1_5 : out std_logic; 
        cn1_10 : out std_logic;
        cn1_11 : out std_logic;
        cn1_12 : out std_logic;
        cn1_13 : out std_logic;
        cn1_14 : out std_logic;
        cn1_15 : out std_logic;
        cn1_16 : out std_logic;
        cn1_18 : out std_logic;
        -- CN2
        cn2_8 : out std_logic; 
        cn2_9 : out std_logic; 
        cn2_11 : out std_logic;
        cn2_13 : out std_logic;
        cn2_19 : out std_logic;
        cn2_20 : out std_logic;
        cn2_21 : out std_logic
    );
end entity;

architecture rtl of top is
    signal rst: std_logic;

    -- Clocks
    signal mclk: std_logic;
    signal pll_locked : std_logic;
    signal clk_adc : std_logic;
    signal clk_seg : std_logic;
    signal clk_uart: std_logic;
    signal clk_spi: std_logic;
    signal heartbeat: std_logic;

    -- ADCs
    signal adc_int_clk : std_logic;
    signal adc_int_ssn : std_logic;
    signal adc_sdo : std_logic_vector(1 downto 0);
    signal adc_out: std_logic_vector(19 downto 0);
    signal adc1_out : std_logic_vector(9 downto 0);
    signal adc1_clk_sample : std_logic;
    signal adc1_avail: std_logic;
    signal adc1_volts: std_logic_vector(15 downto 0);

    -- Segments
    signal segment: std_logic_vector(8 downto 0);
    signal seg_sel : std_logic_vector(3 downto 0);

    -- Registers
    signal uart_ftdi_sdi : std_logic_vector(7 downto 0); 
    signal uart_ftdi_sdo : std_logic_vector(7 downto 0); 
    signal uart_ftdi_tx_request : std_logic := '0';
    signal uart_ftdi_rx_available : std_logic;
    signal spi_tx_request : std_logic := '0';
    signal spi_tx_data : std_logic_vector(7 downto 0); 
    signal spi_sck_dbg : std_logic;
    signal spi_sdo_dbg : std_logic;
    signal spi_nss_dbg : std_logic;

begin
    -- Reset
    rst_buf: entity work.buf
        generic map (
            rst_state => '1'
        )
        port map(
            CLK  => mclk,
            RST  => '0',
            INP  => sw,
            OUTP => rst
    );

    -- -- Clocks setup
    pll_inst: entity work.pll
        port map(
            REFERENCECLK => rclk,
            PLLOUT => mclk,
            LOCKED => pll_locked
    );

    clkgen_heartbeat: entity work.clkgen
        generic map(
            prescaler => 26
        )
        port map(
            CLK_IN => mclk,
            RST => rst,
            CLK_OUT => heartbeat
    );


    -- LEDs
    led0 <= not sw;
    led1 <= not btn;
    led2 <= '0';
    led3 <= '0';
    led4 <= '0';
    led5 <= '0';
    led6 <= pll_locked;
    led7 <= heartbeat;


    -- ADC
    clkgen_adc: entity work.clkgen
        generic map(
            -- 120MHz/8 (2^3)= 15MHz
            prescaler => 2
        )
        port map(
            CLK_IN => mclk,
            RST => rst,
            CLK_OUT => clk_adc
    );
    clkgen_adc_sample: entity work.clkgen
        generic map(
            prescaler => 20 -- 23 for 1/2 second
        )
        port map(
            CLK_IN => mclk,
            RST => rst,
            CLK_OUT => adc1_clk_sample
    );
    adc_clk <= adc_int_clk;
    adc_ssn <= adc_int_ssn;
    adc_sdo <= adc1_sdo & adc2_sdo;
    adc1: entity work.adc
        port map(
            CLK => clk_adc,
            RST => rst,
            SCK => adc_int_clk,
            SSN => adc_int_ssn,
            SDI => adc_sdo,
            DAT => adc_out,
            SAMPLE_REQUEST => adc1_clk_sample,
            SAMPLE_AVAILABLE => adc1_avail
    );
    adc1_out <= adc_out(adc_out'high downto adc_out'high-9);
    adc1_display: entity work.adc_display
        port map(
            CLK => mclk,
            RST => rst,
            DAT => adc1_out,
            DIGITS => adc1_volts,
            REQUEST => adc1_avail
    );


    -- Segments
    clkgen_seg: entity work.clkgen
        generic map(
            -- 120MHz/32768 (2^15)= 3.6kHz
            prescaler => 14
        )
        port map(
            CLK_IN => mclk,
            RST => rst,
            CLK_OUT => clk_seg
    );
    -- Digit selection
    seg_a0 <= '0';
    seg_a1 <= seg_sel(0);
    seg_a2 <= seg_sel(1); 
    seg_a3 <= seg_sel(2); 
    seg_a4 <= seg_sel(3); 
    -- Segment assignments
    seg_k7 <= segment(7);
    seg_k6 <= segment(6);
    seg_k5 <= segment(5);
    seg_k4 <= segment(4);
    seg_k3 <= segment(3);
    seg_k2 <= segment(2);
    seg_k1 <= segment(1);
    seg_k0 <= segment(0);
    -- Driver instanciation
    seg_driver: entity work.seg
        generic map(
            n_digits => 4,
            drive_periods_per_digit => 9
        )
        port map (
            CLK => clk_seg,
            RST => rst,
            -- DIGITS => "0011001000010000",
            DIGITS => adc1_volts,
            DP => "0111",
            SEG_SEL => seg_sel,
            SEG_A   => segment(1),
            SEG_B   => segment(2),
            SEG_C   => segment(3),
            SEG_D   => segment(4),
            SEG_E   => segment(5),
            SEG_F   => segment(6),
            SEG_G   => segment(7),
            SEG_DP  => segment(0)
    );


    -- UART
    clkgen_baudrate: entity work.clkgen
        generic map(
            -- 120MHz/64 (2^6)= 1875000Hz, or 16*117187 baud (115200 + 1.7%)
            prescaler => 5
        )
        port map(
            CLK_IN => mclk,
            RST => rst,
            CLK_OUT => clk_uart
    );
    uart : entity work.uart
        port map (
            CLK  => clk_uart,
            RST  => rst,
            RX => fpga_rx,
            SDI => uart_ftdi_sdi,
            TX => fpga_tx,
            SDO => uart_ftdi_sdo,
            TX_REQUEST => uart_ftdi_tx_request,
            RX_AVAILABLE => uart_ftdi_rx_available
    );

    -- UART echo
    -- uart_ftdi_tx_request <= uart_ftdi_rx_available;

    -- UART ADC
    -- uart_ftdi_tx_request <= adc1_avail;
    -- uart_ftdi_sdo <= adc1_out(adc1_out'high downto 2);


    -- SPI
    clkgen_spi: entity work.clkgen
        generic map(
            -- 120MHz/8 (2^3) = 15 MHz
            prescaler => 2
        )
        port map(
            CLK_IN => mclk,
            RST => rst,
            CLK_OUT => clk_spi
    );
    spi : entity work.spi
        port map (
            CLK => clk_spi,
            RST => rst,
            SCK => spi_sck_dbg,
            SSN => spi_nss_dbg,
            SDO => spi_sdo_dbg,
            DAT => spi_tx_data,
            TRANSMIT_REQUEST => spi_tx_request
    );
    spi_tx_request <= adc1_avail;
    spi_tx_data <= adc1_out(adc1_out'high downto 2);

    st_spi_sck <= spi_sck_dbg;
    st_spi_nss <= spi_sdo_dbg;
    st_spi_sdo <= spi_nss_dbg;

    -- Connectors
    cn1_1  <= adc_int_clk;
    cn1_2  <= adc_int_ssn;
    cn1_3  <= adc1_sdo;
    cn1_5  <= adc1_avail;
    cn1_10 <= adc1_clk_sample;
    cn1_11 <= spi_sck_dbg;
    cn1_12 <= spi_sdo_dbg;
    cn1_13 <= spi_nss_dbg;


end rtl;

