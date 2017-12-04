library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity quad_decoder is
	port(	ch_a : in std_logic;
		ch_b : in std_logic;
		count : out std_logic_vector(31 downto 0);
		clk : in std_logic	);
end entity quad_decoder;

architecture behavioral of quad_decoder is
	signal prev_ch_a, prev_ch_b : std_logic := '0';
	signal init : std_logic := '0';
	signal internal_count : std_logic_vector(31 downto 0) := x"00000000";
begin
	count <= internal_count;

	process(clk)
	begin
		if rising_edge(clk) then
			if init='0' then
				-- Initialize previous state
				prev_ch_a <= ch_a;
				prev_ch_b <= ch_b;
				init <= '1';
			elsif ch_a /= prev_ch_a or ch_b /= prev_ch_b then
				-- If change in encoder state
				if (ch_a xor prev_ch_b) = '1' then
					-- Incrementing change
					internal_count <= std_logic_vector(signed(internal_count) + 1);
				else
					-- Decrementing change
					internal_count <= std_logic_vector(signed(internal_count) - 1);
				end if;

				prev_ch_a <= ch_a;
				prev_ch_b <= ch_b;
			end if;
		end if;
	end process;
end architecture behavioral;