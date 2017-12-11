library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity dac_clamp is
	port(	volt_int32 : in std_logic_vector(31 downto 0);
	  trigger_in : in std_logic;
		clk : in std_logic;
		dac_uint16 : out std_logic_vector(15 downto 0) := x"0000";
		trigger_out : out std_logic := '0' );
end entity dac_clamp;

architecture behavioral of dac_clamp is
begin
  process(clk)
  begin
    if rising_edge(clk) then
      trigger_out <= trigger_in;
      
      if volt_int32(31)='1' then
        dac_uint16 <= x"0000";
      else
        if to_integer(unsigned(volt_int32)) > 65535 then
          dac_uint16 <= x"FFFF";
        else
          dac_uint16 <= volt_int32(15 downto 0);
        end if;
      end if;
    end if;
  end process;
end architecture behavioral;