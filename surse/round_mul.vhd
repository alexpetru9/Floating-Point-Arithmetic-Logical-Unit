library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity round_mul is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        preround_exp  : in  std_logic_vector(7 downto 0);
        preround_sig  : in  std_logic_vector(31 downto 0);
        
        postround_sig : out std_logic_vector(22 downto 0);
        final_exp     : out std_logic_vector(7 downto 0);
        round_ovf     : out std_logic
    );
end entity round_mul;

architecture behavioral of round_mul is
begin
    process(clk, rst)
        variable guard, round, sticky, round_up : std_logic;
        variable sig_24 : unsigned(23 downto 0);
        variable rounded_sig : unsigned(24 downto 0);
        variable v_exp : unsigned(8 downto 0);
        variable v_sig : unsigned(22 downto 0);
    begin
        if rst = '1' then
            postround_sig <= (others=>'0'); final_exp <= (others=>'0'); round_ovf <= '0';
        elsif rising_edge(clk) then
            sig_24 := unsigned(preround_sig(31 downto 8));
            guard := preround_sig(7); round := preround_sig(6);
            if unsigned(preround_sig(5 downto 0)) /= 0 then sticky := '1'; else sticky := '0'; end if;
            
            round_up := (guard and (round or sticky)) or (guard and not round and not sticky and sig_24(0));
            if round_up = '1' then rounded_sig := unsigned('0' & sig_24) + 1; else rounded_sig := unsigned('0' & sig_24); end if;
            -- daca guard e 0 nu rotunjim e nr mai mic
            -- g=1 si (r sau s =0) -> rotunjim in sus
            --g =1 dar r sis =0 -> ultimul bit daca e 1 adunam 1, daca e par nimic
            v_exp := unsigned('0' & preround_exp);
            round_ovf <= '0';
            
            if rounded_sig(24) = '1' then
                v_exp := v_exp + 1;
                v_sig := unsigned(rounded_sig(23 downto 1)); 
                round_ovf <= '1';
            else
                v_sig := unsigned(rounded_sig(22 downto 0));
            end if;
            --overflow-> infinit, underflow -> 0 ,normal-> ce am calculat
            if v_exp >= 255 then
                final_exp <= (others => '1'); postround_sig <= (others => '0');
            elsif v_exp = 0 then
                final_exp <= (others => '0'); postround_sig <= (others => '0');
            else
                final_exp <= std_logic_vector(v_exp(7 downto 0)); postround_sig <= std_logic_vector(v_sig);
            end if;
        end if;
    end process;
end architecture behavioral;