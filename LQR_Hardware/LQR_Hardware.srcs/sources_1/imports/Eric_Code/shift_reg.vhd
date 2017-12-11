----------------------------------------------------------------------------------
-- Eric Middleton's DAC Shift Register Version 1
-- Had issues with timing

-- Matt updated code AND formatted it

-- Matt's updated code didn't work either
-- Eric fixed it for real AND Matt can suck it

----------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

ENTITY shift_reg IS
    PORT(
        clk             : IN  STD_LOGIC;
        Input_Value     : IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
        trigger         : IN  STD_LOGIC;
        MOSI            : OUT STD_LOGIC := '1';
        SCK             : OUT STD_LOGIC := '1';
        CS              : OUT STD_LOGIC := '1'
        );
END shift_reg;

architecture behavioral OF shift_reg IS
----------------------------------------------------------------------------------
-- Signal Declarations
----------------------------------------------------------------------------------
  SIGNAL clock_divider : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
  SIGNAL counter       : STD_LOGIC_VECTOR (4 DOWNTO 0) := "10111";
  SIGNAL state         : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
  SIGNAL next_state    : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
  SIGNAL trigger_latch : STD_LOGIC := '0';
  SIGNAL Trig_rise     : STD_LOGIC := '0';
  SIGNAL Trig_hold     : STD_LOGIC := '0';

BEGIN
    
    CS <= NOT(state(1) OR state(0));
    MOSI <= NOT(state(1) AND NOT state(0)) OR Input_Value(to_integer(UNSIGNED(counter)));
    SCK <= NOT(state(1) AND NOT state(0)) OR clock_divider(5);
    
    trig_rise <= trigger and not trigger_latch;

----------------------------------------------------------------------------------
-- Main Clock
----------------------------------------------------------------------------------
    PROCESS(clk)
    BEGIN
----------------------------------------------------------------------------------
-- Clock Divider
----------------------------------------------------------------------------------
        IF rising_edge(clk) then
            clock_divider <= STD_LOGIC_VECTOR(UNSIGNED(clock_divider)+1);
            
            trigger_latch <= Trigger;
            Trig_hold <= Trig_rise or (Trig_hold and not(state(1) or state(0)));
        END IF;
    END PROCESS;
----------------------------------------------------------------------------------
-- Slow Clock
----------------------------------------------------------------------------------
    PROCESS(clock_divider(5))
    BEGIN
        IF rising_edge(clock_divider(5)) then
            -- Decrementer
            IF counter="00000" then
                counter <= "10111";
            elsif state /= "00" then
                counter <= STD_LOGIC_VECTOR(UNSIGNED(counter)-1);
            END IF;
            
            -- FSM FF
            state <= next_state;
        END IF;
    END PROCESS;
    
    -- FSM state transition
    PROCESS(state, Trig_hold, counter)
    BEGIN --- get rid of rising edge
        next_state <= state;
        IF (state="00" AND Trig_hold='1') OR (state/="00" AND counter="00000") then
            next_state <= STD_LOGIC_VECTOR(UNSIGNED(state)+1);
        END IF;
    END PROCESS;
END architecture behavioral;