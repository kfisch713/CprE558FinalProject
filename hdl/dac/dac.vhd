library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity dac is
	port(	value : in std_logic_vector(15 downto 0);
	  trigger : in std_logic;
		clk : in std_logic;
		MOSI : out std_logic;
		SCK : out std_logic;
		CS : out std_logic );
end entity dac;

architecture behavioral of dac is
  signal dac_out : std_logic_vector(23 downto 0) := x"000000";
  signal shift_trigger : std_logic := '0';

  signal active : std_logic := '0';
  
  signal watchdog : std_logic_vector(23 downto 0) := x"000000"; -- 100,000
  signal zero_clock : std_logic_vector(23 downto 0) := x"000000";
  
  signal zero_value : std_logic_vector(23 downto 0) := x"400000";
  signal zero_trigger : std_logic := '0';
  
  signal dac_value : std_logic_vector(23 downto 0) := x"000000";
  signal dac_trigger : std_logic := '0';
  
  signal prev_trigger : std_logic := '0';
begin
  shift_mux : entity work.shift_mux port map(zero_value, zero_trigger, dac_value, dac_trigger, active, dac_out, shift_trigger);
  shift_reg : entity work.shift_reg port map(dac_out, shift_trigger, MOSI, SCK, CS, clk);
  
  zero_trigger <= zero_clock(23);
  
  process(clk)
  begin
    if rising_edge(clk) then
      if trigger /= prev_trigger then
        if trigger='1' then
          dac_value <= "01" & value & "000000";
          dac_trigger <= '1';
          
          active <= '1';
          watchdog <= x"000000";
        else
          dac_trigger <= '0';
        end if;
        prev_trigger <= trigger;
      end if;
      
      if active <= '1' then
        if watchdog(23)='1' then
          active <= '0';
          zero_clock <= x"800000";
        else
          watchdog <= std_logic_vector(unsigned(watchdog) + 1);
        end if;
      end if;
      
      zero_clock <= std_logic_vector(unsigned(zero_clock) + 1);
    end if;
  end process;
end architecture behavioral;