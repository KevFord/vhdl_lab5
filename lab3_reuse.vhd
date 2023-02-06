-- Lab 3 led blink
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
 
entity lab3_reuse is
port( 

	clk 		: in std_logic;
	reset_n 	: in std_logic;
	led 		: out std_logic);
end entity lab3_reuse;

architecture rtl of lab3_reuse is

constant c_cnt_max : integer := 25000000-1; -- Set to 25000000-1; for live demo. 25 is for simulation.
 
signal tick 	: std_logic; 
signal led_int	: std_logic;
signal counter 	: integer range 0 to c_cnt_max; 

begin

	p_tick 			: process(clk, reset_n)
	begin
		if reset_n = '0' then
			tick <= '0';
			counter <= 0;
		elsif rising_edge(clk) then
			-- My code:
			if counter = c_cnt_max then -- Check if we hit the maximum value.
				tick <= '1'; -- Set the tick signal.
				counter <= 0; -- Reset counter.
			else 
			counter <= (counter + 1); -- Not at maximum value yet, can add one more.
			tick <= '0'; -- Reset tick signal.
			end if;
		-- End of My code
		end if;
	end process p_tick;
	
	led <= led_int; -- Set the output.
	
	p_led_blink 	: process(clk, reset_n)
	begin
		if reset_n = '0' then
			led_int <= '1';		
		elsif rising_edge(clk) then
			-- My code:
			if tick = '1' then -- Tick signal high.
				led_int <= not led_int; -- Toggle the state of the led.
			end if;
		-- End of my code.
		end if;
	end process p_led_blink;
end architecture rtl;