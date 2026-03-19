library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity carry_lookahead_adder_8_mul is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        a_in    : in  std_logic_vector(7 downto 0);
        b_in    : in  std_logic_vector(7 downto 0);
        sum_out : out std_logic_vector(7 downto 0);
        c_out   : out std_logic
    );
end entity carry_lookahead_adder_8_mul;

architecture behavioral of carry_lookahead_adder_8_mul is
begin
    process(clk, rst)
        variable v_sum_ext : unsigned(8 downto 0);
    begin
        if rst = '1' then
            sum_out <= (others => '0');
            c_out   <= '0';
        elsif rising_edge(clk) then
        -- am adaugat un bit pentru carry
            v_sum_ext := unsigned('0' & a_in) + unsigned('0' & b_in);
            sum_out   <= std_logic_vector(v_sum_ext(7 downto 0));
            c_out     <= v_sum_ext(8);
        end if;
    end process;
end architecture behavioral;