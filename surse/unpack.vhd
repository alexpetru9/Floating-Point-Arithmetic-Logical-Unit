library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unpack_mul is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        a_in          : in  std_logic_vector(31 downto 0);
        b_in          : in  std_logic_vector(31 downto 0);
        
        sign_a_out    : out std_logic;
        sign_b_out    : out std_logic;
        exp_a_out     : out std_logic_vector(7 downto 0);
        exp_b_out     : out std_logic_vector(7 downto 0);
        sig_a_out     : out std_logic_vector(23 downto 0); 
        sig_b_out     : out std_logic_vector(23 downto 0)
    );
end entity unpack_mul;

architecture behavioral of unpack_mul is
begin
    process(clk, rst)
        variable v_exp_a, v_exp_b : std_logic_vector(7 downto 0);
        variable v_hidden_a, v_hidden_b : std_logic;
    begin
        if rst = '1' then
            sign_a_out <= '0'; sign_b_out <= '0';
            exp_a_out <= (others=>'0'); exp_b_out <= (others=>'0');
            sig_a_out <= (others=>'0'); sig_b_out <= (others=>'0');
        elsif rising_edge(clk) then
            sign_a_out <= a_in(31);
            v_exp_a    := a_in(30 downto 23);
            exp_a_out  <= v_exp_a;
            if v_exp_a = "00000000" then v_hidden_a := '0'; else v_hidden_a := '1'; end if;
            sig_a_out  <= v_hidden_a & a_in(22 downto 0);

            sign_b_out <= b_in(31);
            v_exp_b    := b_in(30 downto 23);
            exp_b_out  <= v_exp_b;
            if v_exp_b = "00000000" then v_hidden_b := '0'; else v_hidden_b := '1'; end if;
            sig_b_out  <= v_hidden_b & b_in(22 downto 0);
        end if;
    end process;
end architecture behavioral;