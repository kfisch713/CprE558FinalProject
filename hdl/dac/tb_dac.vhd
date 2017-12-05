library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_dac is
end entity tb_dac;

architecture behavioral of tb_dac is
  signal value : std_logic_vector(15 downto 0) := x"0000";
  signal trigger : std_logic := '0';
  signal clk : std_logic := '0';
  
  signal MOSI : std_logic;
  signal SCK : std_logic;
  signal CS : std_logic;
begin
  dac : entity work.dac port map(value, trigger, clk, MOSI, SCK, CS);
  
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
    
    trigger <= '1';
    value <= x"0000";
    wait for 2 ns;
    trigger <= '0';
    wait for 1 us;
    
    trigger <= '1';
    value <= x"0123";
    wait for 2 ns;
    trigger <= '0';
    wait for 1 us;
    
    trigger <= '1';
    value <= x"ABCD";
    wait for 2 ns;
    trigger <= '0';
    wait for 1 us;
    
    wait for 50 ms;
  end process;
end architecture behavioral;