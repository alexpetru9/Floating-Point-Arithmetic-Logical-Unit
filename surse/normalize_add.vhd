library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity normalize_add is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        sum_in       : in  std_logic_vector(31 downto 0);
        carry_in     : in  std_logic;
        exp_in       : in  std_logic_vector(7 downto 0);
        sub_op_in    : in  std_logic;
        
        sum_out      : out std_logic_vector(31 downto 0);
        exp_out      : out std_logic_vector(7 downto 0);
        overflow_out : out std_logic
    );
end entity normalize_add;

architecture behavioral of normalize_add is
begin
    process(clk, rst)
        variable v_sum : unsigned(31 downto 0);
        variable v_exp : unsigned(7 downto 0);
        variable v_shift_count : integer;
        variable v_sum_33bit : unsigned(32 downto 0);
        variable v_overflow_handled : boolean;
    begin
        if rst = '1' then
            sum_out <= (others => '0');
            exp_out <= (others => '0');
            overflow_out <= '0';
        elsif rising_edge(clk) then
            v_sum := unsigned(sum_in);
            v_exp := unsigned(exp_in);
            overflow_out <= '0';
            v_overflow_handled := false;
            -- am avut overflow la adunare ( e de forma 1x.xx) si il shiftam iar exp+1
            if (carry_in = '1') and (sub_op_in = '0') then
                v_sum_33bit := unsigned(carry_in & sum_in);
                v_sum := unsigned(shift_right(v_sum_33bit, 1)(31 downto 0));
                
                if v_exp < 255 then
                    v_exp := v_exp + 1;
                else
                    v_exp := "11111111";
                end if;
                
                overflow_out <= '1';
                v_overflow_handled := true; 
            end if;
            -- normalizare dupa scadere ( 0.01xxx), vedem cand gasim primul 1 si 
            --shiftam cu nr de pozitii la stanga
            --exp - nr de pozitii
            if (v_overflow_handled = false) and (v_sum(31) = '0') and (v_sum /= 0) then
                v_shift_count := 0;
                for i in 30 downto 0 loop 
                    if v_sum(i) = '1' then
                        v_shift_count := 31 - i;
                        exit;
                    end if;
                end loop;
                
                if v_shift_count > 0 then
                    v_sum := shift_left(v_sum, v_shift_count);
                    if to_integer(v_exp) > v_shift_count then
                        v_exp := v_exp - v_shift_count;
                    else
                        v_exp := (others => '0');
                    end if;
                end if;
            end if;
            
            sum_out <= std_logic_vector(v_sum);
            exp_out <= std_logic_vector(v_exp);
        end if;
    end process;
end architecture behavioral;