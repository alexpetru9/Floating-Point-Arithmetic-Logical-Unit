library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity normalize_mul is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        product_in   : in  std_logic_vector(47 downto 0);
        exp_sum_in   : in  std_logic_vector(8 downto 0);
        
        preround_exp : out std_logic_vector(7 downto 0);
        preround_sig : out std_logic_vector(31 downto 0); 
        norm_overflow: out std_logic
    );
end entity normalize_mul;

architecture behavioral of normalize_mul is
begin
    process(clk, rst)
        variable v_product    : unsigned(47 downto 0);
        variable v_exp_sum_int : integer;
        variable v_exp_adj_int : integer; 
        variable v_sig_out    : unsigned(31 downto 0);
    begin
        if rst = '1' then
            preround_exp <= (others=>'0'); preround_sig <= (others=>'0'); norm_overflow <= '0';
        elsif rising_edge(clk) then
            v_product := unsigned(product_in);
            v_exp_sum_int := to_integer(unsigned(exp_sum_in));
            v_exp_adj_int := v_exp_sum_int - 127;
            norm_overflow <= '0';
            -- daca avem overflow , rezultatul e peste >=2.0,atunci exp trebuie sa creasca
            -- daca e 0 atunci bitul 46 e 1
            if v_product(47) = '1' then
                v_sig_out := v_product(47 downto 16);
                v_exp_adj_int := v_exp_adj_int + 1;
            else
                v_sig_out := v_product(46 downto 15);
            end if;
            -- daca produsul e 0 -> rez e 0
            --daca e overflow -> atunci norm e 1 setata
            --underflow (exp e negativ) -> zero
            -- totul e bine -> rez calculate
            if v_product = 0 then
                preround_exp <= (others => '0');
                preround_sig <= (others => '0');
            elsif v_exp_adj_int >= 255 then
                preround_exp <= (others => '1');
                preround_sig <= (others => '0');
                norm_overflow <= '1';
            elsif v_exp_adj_int <= 0 then
                preround_exp <= (others => '0');
                preround_sig <= (others => '0');
            else
                preround_exp <= std_logic_vector(to_unsigned(v_exp_adj_int, 8));
                preround_sig <= std_logic_vector(v_sig_out);
            end if;
        end if;
    end process;
end architecture behavioral;