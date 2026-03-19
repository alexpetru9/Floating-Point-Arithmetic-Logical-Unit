library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponent_subtractor is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        exp_a_in     : in  std_logic_vector(7 downto 0);
        exp_b_in     : in  std_logic_vector(7 downto 0);
        exp_diff_out : out std_logic_vector(7 downto 0);
        a_gt_b_out   : out std_logic
    );
end entity exponent_subtractor;

architecture behavioral of exponent_subtractor is
begin
    process(clk, rst)
        variable v_exp_a_signed : signed(8 downto 0);
        variable v_exp_b_signed : signed(8 downto 0);
        variable v_diff_signed  : signed(8 downto 0);
    begin
        if rst = '1' then
            exp_diff_out <= (others => '0');
            a_gt_b_out   <= '0';
        elsif rising_edge(clk) then
        --problema e dac ascad un nr mare dintr un nr mic si ar face wrap around
        -- adaug un 0 in fata si convetesc signed pe 9biti
        -- rezulta numere in valori pozitive cu semn deci garanteaza reprezentarea (-255 la +255)
            v_exp_a_signed := signed('0' & exp_a_in);
            v_exp_b_signed := signed('0' & exp_b_in);
            v_diff_signed  := v_exp_a_signed - v_exp_b_signed;
           
           -- vad care expo e mai mare pentru ca pe viitor sa shiftam pe cel mai mic 
           -- si cu cate pozitii trebuie shiftat
            if v_diff_signed < 0 then
                exp_diff_out <= std_logic_vector(v_exp_b_signed(7 downto 0) - v_exp_a_signed(7 downto 0));
            else
                exp_diff_out <= std_logic_vector(v_diff_signed(7 downto 0));
            end if;
            
            if v_diff_signed > 0 then a_gt_b_out <= '1'; else a_gt_b_out <= '0'; end if;
        end if;
    end process;
end architecture behavioral;