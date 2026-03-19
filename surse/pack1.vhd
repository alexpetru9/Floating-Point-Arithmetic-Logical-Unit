library ieee;
use ieee.std_logic_1164.all;

entity pack is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        sign_in    : in  std_logic;
        exp_in     : in  std_logic_vector(7 downto 0);
        sig_in     : in  std_logic_vector(22 downto 0);
        result_out : out std_logic_vector(31 downto 0)
    );
end entity pack;

architecture behavioral of pack is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            result_out <= (others => '0');
        elsif rising_edge(clk) then
            result_out <= sign_in & exp_in & sig_in;
        end if;
    end process;
end architecture behavioral;