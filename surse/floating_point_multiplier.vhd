library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity floating_point_multiplier is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        a_in         : in  std_logic_vector(31 downto 0);
        b_in         : in  std_logic_vector(31 downto 0);
        d_out        : out std_logic_vector(31 downto 0);
        overflow_out : out std_logic
    );
end entity floating_point_multiplier;

architecture structural of floating_point_multiplier is

    component unpack_mul is
        port (clk: in std_logic; rst: in std_logic; a_in: in std_logic_vector(31 downto 0); b_in: in std_logic_vector(31 downto 0); sign_a_out: out std_logic; sign_b_out: out std_logic; exp_a_out: out std_logic_vector(7 downto 0); exp_b_out: out std_logic_vector(7 downto 0); sig_a_out: out std_logic_vector(23 downto 0); sig_b_out: out std_logic_vector(23 downto 0));
    end component;
    component carry_lookahead_adder_8_mul is
        port (clk: in std_logic; rst: in std_logic; a_in: in std_logic_vector(7 downto 0); b_in: in std_logic_vector(7 downto 0); sum_out: out std_logic_vector(7 downto 0); c_out: out std_logic);
    end component;
    component wallace_tree_24_mul is
        port (clk: in std_logic; rst: in std_logic; a_in: in std_logic_vector(23 downto 0); b_in: in std_logic_vector(23 downto 0); product_out: out std_logic_vector(47 downto 0));
    end component;
    component normalize_mul is
        port (clk: in std_logic; rst: in std_logic; product_in: in std_logic_vector(47 downto 0); exp_sum_in: in std_logic_vector(8 downto 0); preround_exp: out std_logic_vector(7 downto 0); preround_sig: out std_logic_vector(31 downto 0); norm_overflow: out std_logic);
    end component;
    component round_mul is
        port (clk: in std_logic; rst: in std_logic; preround_exp: in std_logic_vector(7 downto 0); preround_sig: in std_logic_vector(31 downto 0); postround_sig: out std_logic_vector(22 downto 0); final_exp: out std_logic_vector(7 downto 0); round_ovf: out std_logic);
    end component;
    component pack_mul is
        port (clk: in std_logic; rst: in std_logic; sign_in: in std_logic; exp_in: in std_logic_vector(7 downto 0); sig_in: in std_logic_vector(22 downto 0); result_out: out std_logic_vector(31 downto 0));
    end component;

    signal s1_sign_a, s1_sign_b : std_logic;
    signal s1_exp_a, s1_exp_b : std_logic_vector(7 downto 0);
    signal s1_sig_a, s1_sig_b : std_logic_vector(23 downto 0);
    
    signal s2_exp_sum_7 : std_logic_vector(7 downto 0);
    signal s2_exp_carry : std_logic;
    signal s2_exp_sum_8 : std_logic_vector(8 downto 0);
    signal s2_product : std_logic_vector(47 downto 0);
    
    signal reg_sign_s2 : std_logic;

    signal s3_pre_exp : std_logic_vector(7 downto 0);
    signal s3_pre_sig : std_logic_vector(31 downto 0);
    signal s3_norm_ovf : std_logic;
    
    signal reg_sign_s3 : std_logic;

    signal s4_final_sig : std_logic_vector(22 downto 0);
    signal s4_final_exp : std_logic_vector(7 downto 0);
    signal s4_round_ovf : std_logic;
    
    signal reg_sign_s4 : std_logic;
    signal reg_ovf_s4 : std_logic;
    
    signal s_final_sum_ovf : std_logic;

begin

    u_unpack : component unpack_mul
        port map (clk => clk, rst => rst, a_in => a_in, b_in => b_in, sign_a_out => s1_sign_a, sign_b_out => s1_sign_b, exp_a_out => s1_exp_a, exp_b_out => s1_exp_b, sig_a_out => s1_sig_a, sig_b_out => s1_sig_b);

    u_exp_add : component carry_lookahead_adder_8_mul
        port map (clk => clk, rst => rst, a_in => s1_exp_a, b_in => s1_exp_b, sum_out => s2_exp_sum_7, c_out => s2_exp_carry);
    
    s2_exp_sum_8 <= s2_exp_carry & s2_exp_sum_7;

    u_mult : component wallace_tree_24_mul
        port map (clk => clk, rst => rst, a_in => s1_sig_a, b_in => s1_sig_b, product_out => s2_product);

    process(clk) begin
        if rising_edge(clk) then
            if rst='1' then reg_sign_s2 <= '0'; else reg_sign_s2 <= s1_sign_a xor s1_sign_b; end if;
        end if;
    end process;

    u_norm : component normalize_mul
        port map (clk => clk, rst => rst, product_in => s2_product, exp_sum_in => s2_exp_sum_8, preround_exp => s3_pre_exp, preround_sig => s3_pre_sig, norm_overflow => s3_norm_ovf);

    process(clk) begin
        if rising_edge(clk) then
            if rst='1' then reg_sign_s3 <= '0'; else reg_sign_s3 <= reg_sign_s2; end if;
        end if;
    end process;

    u_round : component round_mul
        port map (clk => clk, rst => rst, preround_exp => s3_pre_exp, preround_sig => s3_pre_sig, postround_sig => s4_final_sig, final_exp => s4_final_exp, round_ovf => s4_round_ovf);

    process(clk) begin
        if rising_edge(clk) then
            if rst='1' then reg_sign_s4 <= '0'; reg_ovf_s4 <= '0'; else 
                reg_sign_s4 <= reg_sign_s3; 
                reg_ovf_s4 <= s3_norm_ovf; 
            end if;
        end if;
    end process;

    u_pack : component pack_mul
        port map (clk => clk, rst => rst, sign_in => reg_sign_s4, exp_in => s4_final_exp, sig_in => s4_final_sig, result_out => d_out);

    overflow_out <= reg_ovf_s4 or s4_round_ovf;

end architecture structural;