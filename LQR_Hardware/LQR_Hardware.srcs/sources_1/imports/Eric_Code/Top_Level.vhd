----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/05/2017 08:33:25 PM
-- Design Name: 
-- Module Name: Top_Level - Inverted_Pendulum
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top_Level is
    Port ( 
           Clock : in STD_LOGIC;
           --Run_Flag : in STD_LOGIC;
           CP_Ch_A : in STD_LOGIC;
           CP_Ch_B : in STD_LOGIC;
           PA_Ch_A : in STD_LOGIC;
           PA_CH_B : in STD_LOGIC;
           SCK : out STD_LOGIC;
           MOSI : out STD_LOGIC;
           CS : out STD_LOGIC;
           CS_Mirror : out STD_LOGIC;
           FSM_State : out STD_LOGIC_VECTOR (2 downto 0);
           Cart_Neg : out STD_LOGIC;
           dac_active : out STD_LOGIC;
           fsm_dac_trigger : out STD_LOGIC;
           dac_done_flag : out STD_LOGIC;
           FP_Enable_Out : out STD_LOGIC
           
           -- V_16int : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
           -- DAC_Clamp_Done : OUT STD_LOGIC
           );
end Top_Level;



architecture Inverted_Pendulum of Top_Level is
----------------------------------------------------------------------------------
-- Component Declarations
----------------------------------------------------------------------------------
-- LQR Controller
COMPONENT LQR_Controller is
    Port ( 
           Cart_Pos_Int : in STD_LOGIC_VECTOR (31 downto 0);
           Pend_Ang_Int : in STD_LOGIC_VECTOR (31 downto 0);
           Mstr_Clk     : in STD_LOGIC;
           Clk_En       : in STD_LOGIC;
           Update_State : in STD_LOGIC;
           Reset_State  : in STD_LOGIC;
           U_Ref        : in STD_LOGIC_VECTOR (31 downto 0);
           Volt_Int32   : out STD_LOGIC_VECTOR (31 downto 0)
           );
end COMPONENT;

-- Quadrature Decoders
COMPONENT quad_decoder is
	port(	
	    ch_a          : in  std_logic;
		ch_b          : in  std_logic;
		update_output : in  std_logic;
		count         : out std_logic_vector(31 downto 0) := x"00000000";
		count_raw     : out std_logic_vector(31 downto 0) := x"00000000";
		clk           : in  std_logic	);
end COMPONENT;

-- Digital-to-Analog Converter interface
COMPONENT dac is
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
end COMPONENT;

-- Digital-to-Analog Output Clamp
COMPONENT dac_clamp is
	port(	volt_int32 : in std_logic_vector(31 downto 0);
	  trigger_in : in std_logic;
		clk : in std_logic;
		dac_uint16 : out std_logic_vector(15 downto 0) := x"0000";
		trigger_out : out std_logic := '0' );
end COMPONENT;

-- Finite State Machine for Inverted Pendulum LQR Controller
COMPONENT lqr_fsm is
  port( run_flag : in std_logic;
        dac_done : in std_logic;
        clk : in std_logic;
        fp_enable : out std_logic := '0';
        dac_trigger : out std_logic := '0';
        encoder_update : out std_logic := '0';
        lqr_reset : out std_logic := '0';
        state_out : out std_logic_vector(2 downto 0) );
end COMPONENT;

----------------------------------------------------------------------------------
-- Constant Declarations
----------------------------------------------------------------------------------
CONSTANT Encoder_Start_Min      : STD_LOGIC_VECTOR(31 downto 0) := x"000007F8"; --2040
CONSTANT Encoder_Start_Max      : STD_LOGIC_VECTOR(31 downto 0) := x"00000808"; --2056
CONSTANT Encoder_Stop_Min       : STD_LOGIC_VECTOR(31 downto 0) := x"0000079C"; --1948
CONSTANT Encoder_Stop_Max       : STD_LOGIC_VECTOR(31 downto 0) := x"00000864"; --2148

CONSTANT POS_0                  : STD_LOGIC_VECTOR(31 downto 0) := x"3d4ccccd"; -- 0.05m
CONSTANT POS_1                  : STD_LOGIC_VECTOR(31 downto 0) := x"bd4ccccd"; -- -0.05m
CONSTANT POS_COUNT              : STD_LOGIC_VECTOR(7 downto 0) := "11001000"; -- 200

----------------------------------------------------------------------------------
-- Signal Declarations
----------------------------------------------------------------------------------
SIGNAL Encoder_Update : STD_LOGIC;
SIGNAL DAC_Trigger    : STD_LOGIC;
SIGNAL FP_Enable      : STD_LOGIC;
SIGNAL Reset          : STD_LOGIC;
SIGNAL DAC_Done       : STD_LOGIC;
SIGNAL CP_Count       : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL CP_Count_Raw   : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL PA_Count       : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL PA_Count_Raw   : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL V_32int        : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL V_16int        : STD_LOGIC_VECTOR (15 DOWNTO 0);
SIGNAL DAC_Clamp_Done : STD_LOGIC;

SIGNAL HW_run_flag    : STD_LOGIC := '0';
SIGNAL PA_Count_Bias  : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL U_Ref          : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL Pos_Counter    : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
SIGNAL Pos_index      : STD_LOGIC := '0';

SIGNAL Update_hold    : STD_LOGIC := '0';
SIGNAL s_CS           : STD_LOGIC := '0';

begin

FSM: lqr_fsm PORT MAP(
     run_flag       => HW_run_flag,
     dac_done       => DAC_Done,
     clk            => Clock,
     fp_enable      => FP_Enable,
     dac_trigger    => DAC_Trigger,
     encoder_update => Encoder_Update,
     lqr_reset      => Reset,
     State_Out      => FSM_State );
        
Cart_Encoder: quad_decoder PORT MAP(
              ch_a          => CP_Ch_A,
              ch_b          => CP_Ch_B,
              update_output => Encoder_Update,
              count         => CP_Count,
              count_raw     => CP_Count_Raw,
              clk           => Clock	);

Pend_Encoder: quad_decoder PORT MAP(
              ch_a          => PA_Ch_A,
              ch_b          => PA_Ch_B,
              update_output => Encoder_Update,
              count         => PA_Count,
              count_raw     => PA_Count_Raw,
              clk           => Clock	);
		
LQR_Control: LQR_Controller PORT MAP(
             Cart_Pos_Int => CP_Count,
             Pend_Ang_Int => PA_Count_Bias,
             Mstr_Clk     => Clock,
             Clk_En       => FP_Enable,
             Update_State => Encoder_Update,
             Reset_State  => Reset,
             U_Ref        => U_Ref,
             Volt_Int32   => V_32int);
DAC_Cmp: dac_clamp PORT MAP(
         volt_int32  => V_32int,
         trigger_in  => DAC_Trigger,
         clk         => Clock,
         dac_uint16  => V_16int,
         trigger_out => DAC_Clamp_Done);

Dig2An: dac PORT MAP(
	    value     => V_16int,
	    trigger   => DAC_Clamp_Done,
		clk       => Clock,
	    done_flag => DAC_Done,
		MOSI      => MOSI,
		SCK       => SCK,
		CS        => s_CS,
		dac_active => dac_active,
		dac_trigger_out => OPEN
    );

   PA_Count_Bias <= STD_LOGIC_VECTOR(SIGNED(PA_Count) - 2048);
   Cart_Neg <= CP_Count_Raw(31);
   fsm_dac_trigger <= dac_trigger;
   dac_done_flag <= DAC_Done;
   FP_Enable_Out <= FP_Enable;
   
   CS <= s_CS;
   CS_Mirror <= s_CS;
   
   U_Ref <= POS_0 when Pos_Index='0' else POS_1;

   process(Clock)
   begin
        if rising_edge(Clock) then
            Update_Hold <= Encoder_Update;
            
            if HW_run_flag='1' and Encoder_Update='1' and Update_Hold='0' then
                Pos_Counter <= std_logic_vector(unsigned(Pos_Counter) + 1);
            end if;
            
            if Pos_Counter=Pos_Count then
                Pos_Counter <= "00000000";
                Pos_Index <= not Pos_Index;
            end if;
        
            if HW_run_flag='0' then
                if (signed(PA_Count_Raw) >= signed(Encoder_Start_Min)) and (signed(PA_Count_Raw) <= signed(Encoder_Start_Max)) then
                    HW_run_flag <= '1';
                end if;
            else
                if (signed(PA_Count_Raw) < signed(Encoder_Stop_Min)) or (signed(PA_Count_Raw) > signed(Encoder_Stop_Max)) then
                    HW_run_flag <= '0';
                    Pos_Index <= '0';
                end if;
            end if;
        end if;
    end process;
end Inverted_Pendulum;
