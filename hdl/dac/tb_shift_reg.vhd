library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity tb_shift_reg is
end entity tb_shift_reg;

architecture behavioral of tb_shift_reg is
  signal clk : std_logic := '0';
  signal value : std_logic_vector(23 downto 0) := x"000000";
  signal trigger : std_logic := '0';
  
  signal MOSI : std_logic;
  signal SCK : std_logic;
  signal CS : std_logic;
begin
  shift_reg : entity work.shift_reg port map(value, trigger, MOSI, SCK, CS, clk);
  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;
  
  process begin
    wait for 10 ns;
    
    value <= x"000000";
    trigger <= '1';
    wait for 2 ns;
    trigger <= '0';
    wait for 1 us;
    
    value <= x"AAAAAA";
    trigger <= '1';
    wait for 2 ns;
    trigger <= '0';
    wait for 1 us;
    
    value <= x"5500AA";
    trigger <= '1';
    wait for 2 ns;
    trigger <= '0';
    wait for 1 us;
  end process;
  
end architecture behavioral;