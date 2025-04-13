library ieee;
use ieee.std_logic_1164.all;

entity variable_frequency_led_blink is
 port
		(
		i_sw_0  :  in std_logic;
		i_sw_1  :  in std_logic;
		i_clock :  in std_logic;
		o_led_0 : out std_logic
		);
end entity variable_frequency_led_blink;

architecture RTL of variable_frequency_led_blink is

--Constants for frequency creation, formula is 10MHz / Target Frequency * 0.5
	
	constant c_count_50Hz : natural := 100000;
	constant c_count_25Hz : natural := 200000;
	constant c_count_10Hz : natural := 500000;
	constant c_count_1Hz  : natural := 5000000;

--Count Registers for frequency creation

	signal r_count_50Hz : natural range 0 to c_count_50Hz;
	signal r_count_25Hz : natural range 0 to c_count_25Hz;
	signal r_count_10Hz : natural range 0 to c_count_10Hz;
	signal r_count_1Hz  : natural range 0 to c_count_1Hz;

--Toggle light signals for each frequency

	signal r_toggle_50Hz : std_logic := '0';
	signal r_toggle_25Hz : std_logic := '0';
	signal r_toggle_10Hz : std_logic := '0';
	signal r_toggle_1Hz  : std_logic := '0';	

--
	
	signal r_select_frequency : std_logic := '0';
	
--Processes for each frequency
begin

p_50Hz : process(i_clock) is
begin
	if rising_edge(i_clock) then
		if r_count_50Hz = c_count_50Hz - 1 then
			r_toggle_50Hz <= not r_toggle_50Hz;
			r_count_50Hz <= 0;
			else r_count_50Hz <= r_count_50Hz + 1;
		end if;
	end if;
end process p_50Hz;

p_25Hz : process(i_clock) is
begin
	if rising_edge(i_clock) then
		if r_count_25Hz = c_count_25Hz - 1 then
			r_toggle_25Hz <= not r_toggle_25Hz;
			r_count_25Hz <= 0;
			else r_count_25Hz <= r_count_25Hz + 1;
		end if;
	end if;
end process p_25Hz;

p_10Hz : process(i_clock) is
begin
	if rising_edge(i_clock) then
		if r_count_10Hz = c_count_10Hz - 1 then
			r_toggle_10Hz <= not r_toggle_10Hz;
			r_count_10Hz <= 0;
			else r_count_10Hz <= r_count_10Hz + 1;
		end if;
	end if;
end process p_10Hz;

p_1Hz : process(i_clock) is
begin
	if rising_edge(i_clock) then
		if r_count_1Hz = c_count_1Hz - 1 then
			r_toggle_1Hz <= not r_toggle_1Hz;
			r_count_1Hz <= 0;
			else r_count_1Hz <= r_count_1Hz + 1;
		end if;
	end if;
end process p_1Hz;

--MUX Logic, assign led_blink signal to the frequency "selected" based on the two input switches
	
r_select_frequency <= r_toggle_50Hz when (i_sw_1 = '0' and i_sw_0 = '0') else
							 r_toggle_25Hz when (i_sw_1 = '0' and i_sw_0 = '1') else
							 r_toggle_10Hz when (i_sw_1 = '1' and i_sw_0 = '0') else
							 r_toggle_1Hz when (i_sw_1 = '1' and i_sw_0 = '1') else '0';

--Connect output led to selected frequency register signal
o_led_0 <= r_select_frequency;
						 
end RTL;
