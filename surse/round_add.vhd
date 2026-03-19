library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity round_add is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        sum_in        : in  std_logic_vector(31 downto 0); 
        exp_in        : in  std_logic_vector(7 downto 0);
        
        sig_out_final : out std_logic_vector(22 downto 0); 
        exp_out_final : out std_logic_vector(7 downto 0); 
        overflow_out  : out std_logic
    );
end entity round_add;

architecture behavioral of round_add is
begin
    process(clk, rst)
        variable guard_bit, round_bit, sticky_bit, round_up : std_logic;
        variable significand_24bit : unsigned(23 downto 0);
        variable rounded_significand : unsigned(24 downto 0);
        variable v_exp : unsigned(8 downto 0);
        variable v_sig : unsigned(22 downto 0);
    begin
        if rst = '1' then
            sig_out_final <= (others => '0');
            exp_out_final <= (others => '0');
            overflow_out  <= '0';
        elsif rising_edge(clk) then
            significand_24bit := unsigned(sum_in(31 downto 8)); --(1.xxxx)
            guard_bit := sum_in(7); 
            round_bit := sum_in(6);
            if unsigned(sum_in(5 downto 0)) /= 0 then sticky_bit := '1'; else sticky_bit := '0'; end if;
            -- e 1 daca oricare din bitii(5-> 0) este 1
            round_up := (guard_bit and (round_bit or sticky_bit)) or 
                        (guard_bit and not round_bit and not sticky_bit and significand_24bit(0));
            -- >0.5 rotunjim in sus(g =1 iar ori r sau s =1)
            --exact 0.5 rotunjim in sus doar daca ultimul bit e impar (g=1 iar r si s =0)
            if round_up = '1' then
                rounded_significand := unsigned('0' & significand_24bit) + 1;
            else
                rounded_significand := unsigned('0' & significand_24bit);
            end if;

            v_exp := unsigned('0' & exp_in);
            overflow_out <= '0';
            -- daca adaugam +1 trebuie sa shiftam la dreapta si exp + nr de poztii
            if rounded_significand(24) = '1' then
                v_exp := v_exp + 1;
                v_sig := unsigned(rounded_significand(23 downto 1)); 
                overflow_out <= '1';
            else
                v_sig := unsigned(rounded_significand(22 downto 0));
            end if;
            -- caz in care rezultatul e foarte mare -> setam la infinit
            -- exp prea mic setam la 0
            --altfel transmitem ce am calculat
            if v_exp >= 255 then
                exp_out_final <= (others => '1');
                sig_out_final <= (others => '0');
            elsif v_exp = 0 then
                exp_out_final <= (others => '0');
                sig_out_final <= (others => '0');
            else
                exp_out_final <= std_logic_vector(v_exp(7 downto 0));
                sig_out_final <= std_logic_vector(v_sig);
            end if;
        end if;
    end process;
end architecture behavioral;