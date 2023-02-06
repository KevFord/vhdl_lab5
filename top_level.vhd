library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library work;

entity top_level is
port(
    -- Inputs
        clk_50          : in std_logic;
        reset_n         : in std_logic;
        rx_in           : in std_logic;

    -- Outputs
        hex0            : out std_logic_vector(6 downto 0); -- 7 Segment display.
        led_r           : out std_logic_vector(9 downto 0) -- led_r(1): received error. led_r(0): heartbeat.
);
end top_level;

architecture rtl of top_level is

	type t_7seg_number is array(0 to 11) of std_logic_vector(6 downto 0); -- An array of vectors to represent numbers on the display
	constant c_7seg_number	: t_7seg_number := (
		"1000000", -- 0 OK
		"1111001", -- 1 OK
		"0100100", -- 2 OK
		"0110000", -- 3 OK
		"0011001", -- 4 OK
		"0010010", -- 5 OK
		"0000010", -- 6 OK
		"1111000", -- 7 OK
		"0000000", -- 8 OK
		"0011000", -- 9 OK
		"0111111", -- - (invalid input)
		"1001110"  -- r (reset)
	);		

    -- Signals from uart:
	signal s_received_data		: std_logic_vector(7 downto 0); -- From the uart component.
	signal s_received_valid		: std_logic;

	-- Synced rx:
	signal s_rx_1r				: std_logic;
	signal s_rx_2r				: std_logic;
	
-- Resets:	
	signal s_reset_n_1r         : std_logic;
    signal s_reset_n_2r         : std_logic;

    signal s_reset_high         : std_logic;

   	signal s_output_value		: std_logic_vector(6 downto 0);

-- Component declarations:
component lab3_reuse is
	port(
			clk 		: in std_logic;
			reset_n 	: in std_logic;
			led 		: out std_logic);
	end component lab3_reuse;
	
component serial_uart is
	generic(
		g_reset_active_state    : std_logic                      := '1';
		g_serial_speed_bps      : natural range 9600 to 115200   := 9600;   -- As per instructions.
		g_clk_period_ns         : natural range 10 to 100        := 20;     -- 100 MHz standard clock
		g_parity                : natural range 0 to 2           := 0);     -- 0 = no, 1 = odd, 2 = even

	port(
		clk                     : in  std_logic;
		reset                   : in  std_logic;   -- active high reset
		rx                      : in  std_logic;
		tx                      : out std_logic;
	
		received_data           : out std_logic_vector(7 downto 0); -- Received data
		received_valid          : out std_logic;  -- Set high one clock cycle when byte is received.
		received_error          : out std_logic;  -- Stop bit was not high
		received_parity_error   : out std_logic;  -- Parity error detected
		transmit_ready          : out std_logic;
		transmit_valid          : in  std_logic;
		transmit_data           : in  std_logic_vector(7 downto 0));
end component serial_uart;    

begin
    -- Component instantiations:
	-- A uart module, only setup to receive.
	-- Has an active high reset and will blink a led if no stop bit is sent.
	-- The signal s_received_valid will be pulsed high for one clock cycle upon successful transmition.
    i_uart_module       : serial_uart
    port map(
        clk 			=> clk_50,
		reset			=> s_reset_high, -- Active high.
		rx				=> rx_in,
		received_error	=> led_r(1),
		received_valid	=> s_received_valid,
		received_data	=> s_received_data, 

	-- Unused
	tx							=> open,
	received_parity_error		=> open,
	transmit_data				=> x"ff", -- Wont synthesize when "open", why?
	transmit_ready				=> open,
	transmit_valid				=> '1'
    );

	-- Blinks a led at a set interval.
	-- Working as intended.
    i_heartbeat_led     : lab3_reuse
	port map(
		clk				=> clk_50,
		reset_n			=> reset_n,
		led				=> led_r(0)
	);

	-- Debounce the reset button.
	p_debounce_reset	: process(clk_50) is
	begin
		if rising_edge(clk_50) then
			s_reset_n_1r	<= reset_n;
			s_reset_n_2r	<= s_reset_n_1r;
			s_reset_high	<= not s_reset_n_2r;
		end if;
	end process p_debounce_reset;

	--p_sync_rx_in		: process(clk_50) is
	--begin
	--	if rising_edge(clk_50) then
	--		s_rx_1r	<= rx_in;
	--		s_rx_2r	<= s_rx_1r;
	--	end if;
	--end process p_sync_rx_in;

	-- Read the data received via uart when a successfull transmit has occured.
	p_ascii_to_7seg		: process(clk_50) is
	begin
		if rising_edge(clk_50) then
			if s_received_valid = '1' then -- The data in the "s_received_data" is an actual value.
				case s_received_data is
					when x"30" =>
					-- Set the output digit to zero
						s_output_value	<= c_7seg_number(0);

					when x"31" =>
					-- Set the output digit to one
						s_output_value	<= c_7seg_number(1);

					when x"32" =>
					-- Set the output digit to two
						s_output_value	<= c_7seg_number(2);

					when x"33" =>
					-- Set the output digit to three
						s_output_value	<= c_7seg_number(3);

					when x"34" =>
						s_output_value	<= c_7seg_number(4);

					when x"35" =>
						s_output_value	<= c_7seg_number(5);

					when x"36" =>
						s_output_value	<= c_7seg_number(6);

					when x"37" =>
						s_output_value	<= c_7seg_number(7);

					when x"38" =>
						s_output_value	<= c_7seg_number(8);

					when x"39" =>
						s_output_value	<= c_7seg_number(9);

					when others =>
						s_output_value	<= c_7seg_number(10);
				end case;
				else hex0 <= s_output_value; -- Display the last valid value, or the reset value.
			end if;
		end if;
	
		-- Reset
		if s_reset_n_2r	= '0' then
			hex0	<= c_7seg_number(11); -- Force display to display the reset "icon".
			s_output_value <= c_7seg_number(11);
		end if;
	end process p_ascii_to_7seg;

    led_r(9 downto 2)   <= (others => '0');

end architecture;