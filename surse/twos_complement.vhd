library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity twos_complement is
    port (
        data_in  : in  std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
end entity twos_complement;

architecture behavioral of twos_complement is
begin
    data_out <= std_logic_vector(not signed(data_in) + 1);
end architecture behavioral;