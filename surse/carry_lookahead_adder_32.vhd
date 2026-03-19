library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity carry_lookahead_adder_32 is
    port (
        clk     : in  std_logic; 
        rst     : in  std_logic; 
        a_in    : in  std_logic_vector(31 downto 0);
        b_in    : in  std_logic_vector(31 downto 0);
        c_in    : in  std_logic;
        sum_out : out std_logic_vector(31 downto 0);
        c_out   : out std_logic
    );
end entity carry_lookahead_adder_32;

architecture behavioral of carry_lookahead_adder_32 is
begin
    process(clk, rst)
        variable v_a_ext : unsigned(32 downto 0);
        variable v_b_ext : unsigned(32 downto 0);
        variable v_c_in_full : unsigned(32 downto 0);
        variable v_sum_ext : unsigned(32 downto 0);
    begin
        if rst = '1' then
            sum_out <= (others => '0');
            c_out   <= '0';
        elsif rising_edge(clk) then
            v_a_ext := unsigned('0' & a_in);  -- am adugat un bit pentru overflow
            v_b_ext := unsigned('0' & b_in);
            if c_in = '1' then v_c_in_full := to_unsigned(1, 33); else v_c_in_full := to_unsigned(0, 33); end if;
            
            v_sum_ext := v_a_ext + v_b_ext + v_c_in_full;
            -- adun cele doua mantise
            sum_out <= std_logic_vector(v_sum_ext(31 downto 0));
            c_out   <= v_sum_ext(32); 
        end if;
    end process;
end architecture behavioral;