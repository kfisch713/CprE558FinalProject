library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity dac is
	port(	value : in std_logic_vector(15 downto 0);
	  trigger : in std_logic;
		clk : in std_logic;
	  done_flag : out std_logic := '0';
		MOSI : out std_logic := '0';
		SCK : out std_logic := '0';
		CS : out std_logic := '0';
		dac_active : out std_logic;
		dac_trigger_out : out std_logic
	);
end entity dac;



architecture behavioral of dac is
component shift_mux is
  port( value_in0 : in std_logic_vector(23 downto 0);
        trigger_in0 : in std_logic;
        value_in1 : in std_logic_vector(23 downto 0);
        trigger_in1 : in std_logic;
        sel : in std_logic;
        value_out : out std_logic_vector(23 downto 0);
        trigger_out : out std_logic );
end component shift_mux;

COMPONENT shift_reg IS
    PORT(
        clk             : IN  STD_LOGIC;
        Input_Value     : IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
        trigger         : IN  STD_LOGIC;
        MOSI            : OUT STD_LOGIC := '1';
        SCK             : OUT STD_LOGIC := '1';
        CS              : OUT STD_LOGIC := '1'
        );
END COMPONENT shift_reg;

  signal dac_out : std_logic_vector(23 downto 0) := x"000000";
  signal shift_trigger : std_logic := '0';

  signal active : std_logic := '0';
  
  signal watchdog : std_logic_vector(23 downto 0) := x"000000"; -- 100,000
  signal zero_clock : std_logic_vector(23 downto 0) := x"000000";
  
  signal zero_value : std_logic_vector(23 downto 0) := x"600000";
  signal zero_trigger : std_logic := '0';
  
  signal dac_value : std_logic_vector(23 downto 0) := x"000000";
  signal dac_trigger : std_logic := '0';
  
  signal trigger_hold : std_logic := '0';
  signal zero_trigger_hold : std_logic := '0';
  
  signal s_CS : std_logic := '1';
  signal CS_Hold : std_logic := '1';
begin
--  shift_mux_0 : entity work.shift_mux port map(
--    value_in0       =>  zero_value,
--    trigger_in0     =>  zero_trigger,
--    value_in1       =>  dac_value,
--    trigger_in1     =>  dac_trigger,
--    sel             =>  active,
--    value_out       =>  dac_out,
--    trigger_out     =>  OPEN
--  );
  
  shift_reg_0 : entity work.shift_reg port map(
      clk             => clk,
      Input_Value     => dac_out,
      trigger         => shift_trigger,
      MOSI            => MOSI,
      SCK             => SCK,
      CS              => s_CS
  );
  
  zero_trigger <= zero_clock(23) and not zero_trigger_hold;
  dac_trigger <= trigger and not trigger_hold;
  dac_trigger_out <= dac_trigger;
  
  dac_out <= dac_value when active='1' else zero_value;
  shift_trigger <= dac_trigger or (zero_trigger and not(active));
  
  CS <= s_CS;
  done_flag <= s_CS and not CS_Hold;
  
  dac_active <= active;
  
  process(clk)
  begin
    if rising_edge(clk) then
        trigger_hold <= trigger;
        zero_trigger_hold <= zero_clock(23);
        CS_Hold <= s_CS;
            
      if trigger='1' and trigger_hold='0' then
          dac_value <= "01" & value & "000000";
          active <= '1';
          watchdog <= x"000000";
      ELSIF active='1' then
        watchdog <= std_logic_vector(unsigned(watchdog) + 1);
        IF watchdog(23)='1'then
          active <= '0';
          zero_clock <= x"800000";
        END IF;
      end if;
      
      zero_clock <= std_logic_vector(unsigned(zero_clock) + 1);
      END IF;
  end process;
end architecture behavioral;