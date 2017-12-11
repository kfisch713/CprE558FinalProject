library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity lqr_fsm is
  port( run_flag : in std_logic;
        dac_done : in std_logic;
        clk : in std_logic;
        fp_enable : out std_logic := '0';
        dac_trigger : out std_logic := '0';
        encoder_update : out std_logic := '0';
        lqr_reset : out std_logic := '0';
        state_out : out std_logic_vector(2 downto 0) );
end entity lqr_fsm;

architecture behavioral of lqr_fsm is
SIGNAL state : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
SIGNAL next_state : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
SIGNAL restart_count : STD_LOGIC_VECTOR(16 DOWNTO 0):= "00000000000000000"; 

constant COMPUTE_TIME   : std_logic_vector(16 downto 0) := "00000000001100000"; -- 96
--constant CONTROL_PERIOD : std_logic_vector(16 downto 0) := "11000011010100000"; -- 100,000
constant CONTROL_PERIOD : std_logic_vector(16 downto 0) :=   "11110100001001000"; -- 125,000

BEGIN
    dac_trigger <= '1' when state="010" else '0';
    fp_enable <= '1' when state="001" else '0';

PROCESS(state, run_flag, dac_done, restart_count)
BEGIN
    next_state <= state;
	IF(state = "000")THEN
		IF(run_flag = '1')THEN
			next_state <= "001";
		END IF;
	ELSIF(state = "001")THEN
		IF(restart_count = COMPUTE_TIME)THEN
			next_state <= "010";
		END IF;
	ELSIF(state = "010")THEN
		IF(dac_done = '1')THEN
			next_state <= "011";
		END IF;
	ELSIF(state = "011")THEN
		IF(restart_count = CONTROL_PERIOD)THEN
			next_state <= "100";
		ELSIF(run_flag = '0')THEN
			next_state <= "000";
		END IF;
	ELSIF(state = "100")THEN
		next_state <= "001";
	END IF;
END PROCESS;

PROCESS(clk)
BEGIN
	IF(clk'event AND clk = '1')THEN
	   state <= next_state;
	   encoder_update <= '0';
	   lqr_reset <= '0';
	   
	   IF((State /= next_state) AND (next_state = "001")) then
	       encoder_update <= '1';
	       IF(State = "000") THEN
	           lqr_reset <= '1';
           END IF;
       END IF;
       
		IF((State = "000" OR State = "100") AND next_state = "001")THEN
		      restart_count <= "00000000000000000";
		ELSE
		  restart_count <= STD_LOGIC_VECTOR(unsigned(restart_count) +1);
		END IF;
    END IF;
END PROCESS;
state_out <= state;
end architecture behavioral;