library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity meta_filter is
	port(	input : in std_logic;
		output : out std_logic := '0';
		clk : in std_logic );
end entity meta_filter;

architecture behavioral of meta_filter is
	signal q1 : std_logic := '0';
begin
	process(clk)
	begin
		if rising_edge(clk) then
			q1 <= input;
			output <= q1;
		end if;
	end process;
end architecture behavioral;