----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2017 08:14:20 PM
-- Design Name: 
-- Module Name: Cart_Int_to_Float - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Cart_Int_to_Float is
    Port ( CartPos_Int : in STD_LOGIC_VECTOR (31 downto 0);
           CartPos_FP : out STD_LOGIC_VECTOR (31 downto 0));
end Cart_Int_to_Float;

architecture Behavioral of Cart_Int_to_Float is

begin


end Behavioral;
