library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wallace_tree_24_mul is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        a_in        : in  std_logic_vector(23 downto 0);
        b_in        : in  std_logic_vector(23 downto 0);
        product_out : out std_logic_vector(47 downto 0) 
    );
end entity wallace_tree_24_mul;

architecture behavioral of wallace_tree_24_mul is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            product_out <= (others => '0');
        elsif rising_edge(clk) then
            product_out <= std_logic_vector(unsigned(a_in) * unsigned(b_in));
        end if;
    end process;
end architecture behavioral;