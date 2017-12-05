library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity shift_reg is
	port(	value : in std_logic_vector(23 downto 0);
	  trigger : in std_logic;
		MOSI : out std_logic := '0';
		SCK : out std_logic;
		CS : out std_logic := '1';
		clk : in std_logic );
end entity shift_reg;

architecture behavioral of shift_reg is
  signal clock_divider : std_logic_vector(3 downto 0) := "0000";
  signal counter : std_logic_vector(4 downto 0) := "00000";
  signal active : std_logic := '0';
  signal SCK_EN : std_logic := '0';
  signal prev_sck : std_logic := '0';
  signal prev_trigger : std_logic := '0';
begin
  SCK <= clock_divider(3) and SCK_EN;
  
  process(clk)
  begin
    if rising_edge(clk) then
      prev_sck <= clock_divider(3);
      clock_divider <= std_logic_vector(unsigned(clock_divider) + 1);
      
      if trigger /= prev_trigger then
        prev_trigger <= trigger;
        if trigger='1' then
          active <= '1';
          counter <= "10111"; --23
        end if;
      elsif prev_sck /= clock_divider(3) then
        if clock_divider(3)='1' then
          if active='1' then
            if SCK_EN='0' then
              SCK_EN <= '1';
              CS <= '0';
            end if;
            
            MOSI <= value(to_integer(unsigned(counter)));
            
            if counter="00000" then
              active <= '0';
            else
              counter <= std_logic_vector(unsigned(counter) - 1);
            end if;
          end if;
        elsif active='0' and SCK_EN='1' then
          SCK_EN <= '0';
          CS <= '1';
        end if;
      end if;
    end if;
  end process;
  
end architecture behavioral;