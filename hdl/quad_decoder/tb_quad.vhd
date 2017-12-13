library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_quad is
end entity tb_quad;

architecture behavioral of tb_quad is
	signal clk : std_logic := '0';
	signal ch_a, ch_b : std_logic := '0';
	signal count : std_logic_vector(31 downto 0);
	signal count_raw : std_logic_vector(31 downto 0);
	signal update_output : std_logic := '0';
begin
	decoder : entity work.quad_decoder port map(ch_a, ch_b, update_output, count, count_raw, clk);

	process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;

	process
	begin
		wait for 10 ns;

		ch_a <= '1';
		wait for 10 ns;
		ch_a <= '0';
		wait for 10 ns;
		ch_a <= '1';
		wait for 10 ns;
		ch_a <= '0';
		wait for 10 ns;

		ch_b <= '1';
		wait for 10 ns;
		ch_b <= '0';
		wait for 10 ns;
		ch_b <= '1';
		wait for 10 ns;
		ch_b <= '0';
		wait for 10 ns;
		
		update_output <= '1';
		wait for 10 ns;
		update_output <= '0';
		wait for 10 ns;

		ch_a <= '1';
		wait for 10 ns;
		ch_b <= '1';
		wait for 10 ns;
		update_output <= '1';
		wait for 10 ns;
		update_output <= '0';
		wait for 10 ns;
		ch_a <= '0';
		wait for 10 ns;
		ch_b <= '0';
		wait for 10 ns;

		ch_b <= '1';
		wait for 10 ns;
		update_output <= '1';
		wait for 10 ns;
		update_output <= '0';
		wait for 10 ns;
		ch_a <= '1';
		wait for 10 ns;
		update_output <= '1';
		wait for 10 ns;
		update_output <= '0';
		wait for 10 ns;
		ch_b <= '0';
		wait for 10 ns;
		update_output <= '1';
		wait for 10 ns;
		update_output <= '0';
		wait for 10 ns;
		ch_a <= '0';
		update_output <= '1';
		wait for 10 ns;
		update_output <= '0';
		wait for 10 ns;
	end process;
end architecture behavioral;