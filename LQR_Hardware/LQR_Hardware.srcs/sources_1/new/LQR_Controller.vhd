----------------------------------------------------------------------------------
-- Company: Iowa State University -- CprE 583 -- Final Project
-- Engineer: Matt Cauwels
-- 
-- Create Date: 12/04/2017 07:54:47 PM
-- Design Name: LQR Controller
-- Module Name: LQR_Controller - Controller
-- Project Name: Inverted Pendulum Cart w/ Zybo Board LQR
-- Target Devices: Zybo Board
-- Tool Versions: Vivado 2017.1
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

entity LQR_Controller is
    Port ( 
           Cart_Pos_Int : in STD_LOGIC_VECTOR (31 downto 0);
           Pend_Ang_Int : in STD_LOGIC_VECTOR (31 downto 0);
           Mstr_Clk     : in STD_LOGIC;
           Clk_En       : in STD_LOGIC;
           Update_State : in STD_LOGIC;
           Reset_State  : in STD_LOGIC;
           U_Ref        : in STD_LOGIC_VECTOR(31 downto 0);
           Volt_Int32   : out STD_LOGIC_VECTOR (31 downto 0)
           );
end LQR_Controller;

architecture Controller of LQR_Controller is
----------------------------------------------------------------------------------
-- Component Declarations
----------------------------------------------------------------------------------

-- Floating Point 32-bit Signed Integer to Single Precision Floating Point
COMPONENT floating_point_Int32_to_Float32 is
  Port ( 
    aclk                 : in  STD_LOGIC;
    aclken               : in  STD_LOGIC;
    s_axis_a_tvalid      : in  STD_LOGIC;
    s_axis_a_tready      : out STD_LOGIC;
    s_axis_a_tdata       : in  STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_result_tvalid : out STD_LOGIC;
    m_axis_result_tready : in  STD_LOGIC;
    m_axis_result_tdata  : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
end COMPONENT;

-- Floating Point Single Precision Addition
COMPONENT floating_point_Addition is
  Port ( 
    aclk                 : in  STD_LOGIC;
    aclken               : in  STD_LOGIC;
    s_axis_a_tvalid      : in  STD_LOGIC;
    s_axis_a_tready      : out STD_LOGIC;
    s_axis_a_tdata       : in  STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_b_tvalid      : in  STD_LOGIC;
    s_axis_b_tready      : out STD_LOGIC;
    s_axis_b_tdata       : in  STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_result_tvalid : out STD_LOGIC;
    m_axis_result_tready : in  STD_LOGIC;
    m_axis_result_tdata  : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
end COMPONENT;

-- Floating Point Single Precision Multiplication
COMPONENT floating_point_Multiplication is
  Port ( 
    aclk                 : in  STD_LOGIC;
    aclken               : in  STD_LOGIC;
    s_axis_a_tvalid      : in  STD_LOGIC;
    s_axis_a_tready      : out STD_LOGIC;
    s_axis_a_tdata       : in  STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_b_tvalid      : in  STD_LOGIC;
    s_axis_b_tready      : out STD_LOGIC;
    s_axis_b_tdata       : in  STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_result_tvalid : out STD_LOGIC;
    m_axis_result_tready : in  STD_LOGIC;
    m_axis_result_tdata  : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  
  end COMPONENT;
  
-- Single Precision Floating Point to 32-bit Signed Integer
COMPONENT floating_point_Float32_to_Int32 is
  Port ( 
    aclk                 : in  STD_LOGIC;
    aclken               : in  STD_LOGIC;
    s_axis_a_tvalid      : in  STD_LOGIC;
    s_axis_a_tready      : out STD_LOGIC;
    s_axis_a_tdata       : in  STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_result_tvalid : out STD_LOGIC;
    m_axis_result_tready : in  STD_LOGIC;
    m_axis_result_tdata  : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end COMPONENT;

----------------------------------------------------------------------------------
-- Signal Declarations
----------------------------------------------------------------------------------
SIGNAL CP_Float    : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL PA_Float    : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL SensorData1 : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL SensorData2 : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL M11         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M12         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M13         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M14         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M21         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M22         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M23         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M24         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M31         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M32         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M33         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL M34         : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL A11         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL A12         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL A13         : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL A21         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL A22         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL A23         : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL A31         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL A32         : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL A33         : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL VoltFP      : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL x1_Next     : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL x2_Next     : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL x1          : STD_LOGIC_VECTOR (31 DOWNTO 0):= x"00000000"; -- Initialize to zero
SIGNAL x2          : STD_LOGIC_VECTOR (31 DOWNTO 0):= x"00000000"; -- Initialize to zero

SIGNAL Clk         : STD_LOGIC;
SIGNAL Ctrl_counter: STD_LOGIC_VECTOR (16 DOWNTO 0) := "00000000000000000";

SIGNAL VoltBFP     : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL VoltDFP     : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL VoltInt32   : STD_LOGIC_VECTOR (31 DOWNTO 0);

SIGNAL Update_State_Hold    : STD_LOGIC := '0';
SIGNAL Reset_Hold           : STD_LOGIC := '0';

--SIGNAL U_ref       : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"00000000"; -- Initialize to zero
SIGNAL K1_U_ref    : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL K2_U_ref    : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL K3_U_ref    : STD_LOGIC_VECTOR (31 DOWNTO 0);


----------------------------------------------------------------------------------
-- Constant Declarations
----------------------------------------------------------------------------------
CONSTANT CP_Bias : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"37beb717"; -- 0.000022735022866982035338878631591796875 = 1/43985
CONSTANT PA_Bias : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"3ac90fdb"; -- 0.001533980830572545528411865234375 = pi/2048

CONSTANT Vt_Bias : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"41200000"; -- 10

CONSTANT DAC_Bias: STD_LOGIC_VECTOR (31 DOWNTO 0) := x"454ccc00"; -- 3276.75 = (-1 + 2^16)/20

CONSTANT T11     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"423fc28f"; -- 47.9400
CONSTANT T12     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"c1d0f5c3"; -- -26.1200
CONSTANT T13     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"44073fb8"; -- 540.9956
CONSTANT T14     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"c3a3509d"; -- -326.6298

CONSTANT T21     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"3fd05f07"; -- 1.6279
CONSTANT T22     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"bec346dc"; -- -0.3814
CONSTANT T23     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"4102b22d"; -- 8.1685
CONSTANT T24     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"c09816f0"; -- -4.7528

CONSTANT T31     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"3fce2eb2"; -- 1.6108
CONSTANT T32     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"3d4e703b"; -- 0.0504
CONSTANT T33     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"41a00f5c"; -- 20.0075
CONSTANT T34     : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"c133f6fd"; -- -11.2478

CONSTANT K1      : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"c2720000"; -- -60.5
CONSTANT K2      : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"bfbdf3b6"; -- -1.4840
CONSTANT K3      : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"c05a92a3"; -- -3.4152

CONSTANT V_Int32_Bias : STD_LOGIC_VECTOR (31 DOWNTO 0) := x"00008000"; --

begin

----------------------------------------------------------------------------------
-- Convert Encoders to Floats
----------------------------------------------------------------------------------
-- Convert Cart Position Encoder from 32-bit Signed Int to Single Precision Float
CP_Int2FP:    floating_point_Int32_to_Float32 PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => Cart_Pos_Int,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => CP_Float);
-- Convert Pendulum Angle Encoder from 32-bit Signed Int to Single Precision Float
PA_Int2FP:    floating_point_Int32_to_Float32 PORT MAP(
            aclk                 => Mstr_Clk,
            aclken               => Clk_En,
            s_axis_a_tvalid      => '1',
            s_axis_a_tready      => OPEN,
            s_axis_a_tdata       => Pend_Ang_Int,
            m_axis_result_tvalid => OPEN,
            m_axis_result_tready => '1',
            m_axis_result_tdata  => PA_Float);

-- Multiply Cart Position Float by 1 meter / 44810 ticks
CP_FP_to_m:   floating_point_Multiplication PORT MAP(
            aclk                 => Mstr_Clk,
            aclken               => Clk_En,
            s_axis_a_tvalid      => '1',
            s_axis_a_tready      => OPEN,
            s_axis_a_tdata       => CP_Float,
            s_axis_b_tvalid      => '1',
            s_axis_b_tready      => OPEN,
            s_axis_b_tdata       => CP_Bias,
            m_axis_result_tvalid => OPEN,
            m_axis_result_tready => '1',
            m_axis_result_tdata  => SensorData1);
-- Multiply Pendulum Angle Float by 1 radian / 650.625 ticks
PA_FP_to_Rad: floating_point_Multiplication PORT MAP(
            aclk                 => Mstr_Clk,
            aclken               => Clk_En,
            s_axis_a_tvalid      => '1',
            s_axis_a_tready      => OPEN,
            s_axis_a_tdata       => PA_Float,
            s_axis_b_tvalid      => '1',
            s_axis_b_tready      => OPEN,
            s_axis_b_tdata       => PA_Bias,
            m_axis_result_tvalid => OPEN,
            m_axis_result_tready => '1',
            m_axis_result_tdata  => SensorData2);

----------------------------------------------------------------------------------
-- LQR Multiplications
----------------------------------------------------------------------------------
-- T11 * x1
T11_Mult_x1:  floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T11,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => x1,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M11);

-- T12 * x2
T12_Mult_x2:  floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T12,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => x2,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M12);
-- T13 * Sd1
T13_Mult_sd1: floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T13,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => SensorData1,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M13);
-- T14 * Sd2
T14_Mult_sd2: floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T14,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => SensorData2,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M14);
-- T21 * x1
T21_Mult_x1:  floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T21,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => x1,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M21);
-- T22 * x2
T22_Mult_x2:  floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T22,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => x2,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M22);
-- T23 * Sd1
T21_Mult_sd1: floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T23,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => SensorData1,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M23);
-- T24 * Sd2
T24_Mult_sd2: floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T24,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => SensorData2,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M24);
-- T31 * x1
T31_Mult_x1:  floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T31,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => x1,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M31);
-- T32 * x2
T32_Mult_x2:  floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T32,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => x2,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M32);
-- T33 * Sd1
T33_Mult_sd1: floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T33,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => SensorData1,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M33);
-- T34 * Sd2
T34_Mult_sd2: floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => T34,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => SensorData2,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => M34);
              
K1_mult_uRef: floating_point_Multiplication PORT MAP(
             aclk                 => Mstr_Clk,
             aclken               => Clk_En,
             s_axis_a_tvalid      => '1',
             s_axis_a_tready      => OPEN,
             s_axis_a_tdata       => U_ref,
             s_axis_b_tvalid      => '1',
             s_axis_b_tready      => OPEN,
             s_axis_b_tdata       => K1,
             m_axis_result_tvalid => OPEN,
             m_axis_result_tready => '1',
             m_axis_result_tdata  => K1_U_ref);   
             
K2_mult_uRef: floating_point_Multiplication PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => U_ref,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => K2,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => K2_U_ref);
              
K3_mult_uRef: floating_point_Multiplication PORT MAP(
               aclk                 => Mstr_Clk,
               aclken               => Clk_En,
               s_axis_a_tvalid      => '1',
               s_axis_a_tready      => OPEN,
               s_axis_a_tdata       => U_ref,
               s_axis_b_tvalid      => '1',
               s_axis_b_tready      => OPEN,
               s_axis_b_tdata       => K3,
               m_axis_result_tvalid => OPEN,
               m_axis_result_tready => '1',
               m_axis_result_tdata  => K3_U_ref);       
                      
----------------------------------------------------------------------------------
-- LQR Additions
----------------------------------------------------------------------------------

-- T11 * x1 + T12 * x2 = A11
M11_Add_M12:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => M11,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => M12,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => A11);
-- T13 * Sd1 + T14 * Sd2 = A12
M13_Add_M14:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => M13,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => M14,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => A12);
-- Voltage = A11 + A12
A11_Add_A12:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => A11,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => A12,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => A13);
              
A13_Add_K1:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => A13,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => K1_U_ref,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => VoltFP);
              
-- T21 * x1 + T22 * x2 = A21
M21_Add_M22:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => M21,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => M22,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => A21);
  
-- T23 * Sd1 + T24 * Sd2 = A22
M23_Add_M24:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => M23,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => M24,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => A22);
-- x1_next = A21 + A22
A21_Add_A22:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => A21,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => A22,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => A23);
              
A23_Add_K2:  floating_point_Addition PORT MAP(
             aclk                 => Mstr_Clk,
             aclken               => Clk_En,
             s_axis_a_tvalid      => '1',
             s_axis_a_tready      => OPEN,
             s_axis_a_tdata       => A23,
             s_axis_b_tvalid      => '1',
             s_axis_b_tready      => OPEN,
             s_axis_b_tdata       => K2_U_ref,
             m_axis_result_tvalid => OPEN,
             m_axis_result_tready => '1',
             m_axis_result_tdata  => x1_Next);
   
-- T31 * x1 + T32 * x2 = A31
M31_Add_M32:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => M31,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => M32,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => A31);
-- T33 * Sd1 + T34 * Sd2 = A32
M33_Add_M34:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => M33,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => M34,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => A32);
-- x2_next = A31 + A32
A31_Add_A32:  floating_point_Addition PORT MAP(
              aclk                 => Mstr_Clk,
              aclken               => Clk_En,
              s_axis_a_tvalid      => '1',
              s_axis_a_tready      => OPEN,
              s_axis_a_tdata       => A31,
              s_axis_b_tvalid      => '1',
              s_axis_b_tready      => OPEN,
              s_axis_b_tdata       => A32,
              m_axis_result_tvalid => OPEN,
              m_axis_result_tready => '1',
              m_axis_result_tdata  => A33);
              
A33_Add_K3:  floating_point_Addition PORT MAP(
             aclk                 => Mstr_Clk,
             aclken               => Clk_En,
             s_axis_a_tvalid      => '1',
             s_axis_a_tready      => OPEN,
             s_axis_a_tdata       => A33,
             s_axis_b_tvalid      => '1',
             s_axis_b_tready      => OPEN,
             s_axis_b_tdata       => K3_U_ref,
             m_axis_result_tvalid => OPEN,
             m_axis_result_tready => '1',
             m_axis_result_tdata  => x2_Next);   
                       
----------------------------------------------------------------------------------
-- Convert Voltage from 32-bit Single Precision Float to 32-bit Signed Int
----------------------------------------------------------------------------------
Volt_FP_to_Bias: floating_point_Addition PORT MAP(
                 aclk                 => Mstr_Clk,
                 aclken               => Clk_En,
                 s_axis_a_tvalid      => '1',
                 s_axis_a_tready      => OPEN,
                 s_axis_a_tdata       => VoltFP,
                 s_axis_b_tvalid      => '1',
                 s_axis_b_tready      => OPEN,
                 s_axis_b_tdata       => Vt_bias,
                 m_axis_result_tvalid => OPEN,
                 m_axis_result_tready => '1',
                 m_axis_result_tdata  => VoltBFP);
                
VoltBFP_to_DAC: floating_point_Multiplication PORT MAP(
                aclk                 => Mstr_Clk,
                aclken               => Clk_En,
                s_axis_a_tvalid      => '1',
                s_axis_a_tready      => OPEN,
                s_axis_a_tdata       => VoltBFP,
                s_axis_b_tvalid      => '1',
                s_axis_b_tready      => OPEN,
                s_axis_b_tdata       => DAC_Bias,
                m_axis_result_tvalid => OPEN,
                m_axis_result_tready => '1',
                m_axis_result_tdata  => VoltDFP);                

VB_FP_to_int32: floating_point_Float32_to_Int32 PORT MAP ( 
                aclk                 => Mstr_Clk,
                aclken               => Clk_En,
                s_axis_a_tvalid      => '1',
                s_axis_a_tready      => OPEN,
                s_axis_a_tdata       => VoltDFP,
                m_axis_result_tvalid => OPEN,
                m_axis_result_tready => '1',
                --m_axis_result_tdata  => OPEN);
                m_axis_result_tdata  => Volt_Int32);
    
    --Volt_Int32 <= std_logic_vector(signed(V_Int32_Bias) + signed(Pend_Ang_Int(23 downto 0) & x"00"));
                
----------------------------------------------------------------------------------
-- Save x as x_next
----------------------------------------------------------------------------------
--PROCESS(Update_State, Reset_State)
--BEGIN
--    IF(Reset_State = '1') THEN
--        x1 <= x"00000000";
--        x2 <= x"00000000";
--    ELSIF(Update_State'event AND Update_State = '1') THEN
--        x1 <= x1_next;
--        x2 <= x2_next;
--    END IF;
--END PROCESS;

PROCESS(Mstr_Clk)
BEGIN
    IF(rising_edge(Mstr_Clk)) THEN
        Update_State_Hold <= Update_State;
        Reset_Hold <= Reset_State;
        
        IF(Update_State='1' AND Update_State_Hold='0') THEN
            x1 <= x1_next;
            x2 <= x2_next;
        END IF;
        
        IF(Reset_State='1' AND Reset_Hold='0') THEN
            x1 <= x"00000000";
            x2 <= x"00000000";
        END IF;
    END IF;
END PROCESS;

----------------------------------------------------------------------------------
-- Clear/Reset x to 0s
----------------------------------------------------------------------------------


end Controller;
