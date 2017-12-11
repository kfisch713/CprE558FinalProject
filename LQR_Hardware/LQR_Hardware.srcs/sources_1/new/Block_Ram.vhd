----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2017 08:17:00 PM
-- Design Name: 
-- Module Name: Block_Ram - Behavioral
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

entity Block_Ram is
    Port ( T11 : out STD_LOGIC_VECTOR (31 downto 0);
           T12 : out STD_LOGIC_VECTOR (31 downto 0);
           T21 : out STD_LOGIC_VECTOR (31 downto 0);
           T22 : out STD_LOGIC_VECTOR (31 downto 0));
end Block_Ram;

architecture Behavioral of Block_Ram is

begin


end Behavioral;
