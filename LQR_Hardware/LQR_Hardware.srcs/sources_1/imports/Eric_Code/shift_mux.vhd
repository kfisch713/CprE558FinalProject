library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity shift_mux is
  port( value_in0 : in std_logic_vector(23 downto 0);
        trigger_in0 : in std_logic;
        value_in1 : in std_logic_vector(23 downto 0);
        trigger_in1 : in std_logic;
        sel : in std_logic;
        value_out : out std_logic_vector(23 downto 0);
        trigger_out : out std_logic );
end entity shift_mux;
        
architecture behavioral of shift_mux is
begin
  value_out <= value_in0 when (sel='0') else value_in1;
  trigger_out <= trigger_in0 when (sel='0') else trigger_in1;
end architecture behavioral;