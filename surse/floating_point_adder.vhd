library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity floating_point_adder is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        a_in         : in  std_logic_vector(31 downto 0);
        b_in         : in  std_logic_vector(31 downto 0);
        sum_out      : out std_logic_vector(31 downto 0);
        overflow_out : out std_logic
    );
end entity floating_point_adder;

architecture structural of floating_point_adder is

    component unpack is
        port (clk: in std_logic; rst: in std_logic; a_in: in std_logic_vector(31 downto 0); b_in: in std_logic_vector(31 downto 0); sign_a_out: out std_logic; sign_b_out: out std_logic; exp_a_out: out std_logic_vector(7 downto 0); exp_b_out: out std_logic_vector(7 downto 0); op_a_out: out std_logic_vector(31 downto 0); op_b_out: out std_logic_vector(31 downto 0));
    end component;
    component exponent_subtractor is
        port (clk: in std_logic; rst: in std_logic; exp_a_in: in std_logic_vector(7 downto 0); exp_b_in: in std_logic_vector(7 downto 0); exp_diff_out: out std_logic_vector(7 downto 0); a_gt_b_out: out std_logic);
    end component;
    component align_significand is
        port (clk: in std_logic; rst: in std_logic; sig_in: in std_logic_vector(31 downto 0); shift_amount: in std_logic_vector(7 downto 0); sig_out: out std_logic_vector(31 downto 0));
    end component;
    component carry_lookahead_adder_32 is
        port (clk: in std_logic; rst: in std_logic; a_in: in std_logic_vector(31 downto 0); b_in: in std_logic_vector(31 downto 0); c_in: in std_logic; sum_out: out std_logic_vector(31 downto 0); c_out: out std_logic);
    end component;
    component normalize_add is
        port (clk: in std_logic; rst: in std_logic; sum_in: in std_logic_vector(31 downto 0); carry_in: in std_logic; exp_in: in std_logic_vector(7 downto 0); sub_op_in: in std_logic; sum_out: out std_logic_vector(31 downto 0); exp_out: out std_logic_vector(7 downto 0); overflow_out: out std_logic);
    end component;
    component round_add is
        port (clk: in std_logic; rst: in std_logic; sum_in: in std_logic_vector(31 downto 0); exp_in: in std_logic_vector(7 downto 0); sig_out_final: out std_logic_vector(22 downto 0); exp_out_final: out std_logic_vector(7 downto 0); overflow_out: out std_logic);
    end component;
    component pack is
        port (clk: in std_logic; rst: in std_logic; sign_in: in std_logic; exp_in: in std_logic_vector(7 downto 0); sig_in: in std_logic_vector(22 downto 0); result_out: out std_logic_vector(31 downto 0));
    end component;
    
    component twos_complement is port (data_in: in std_logic_vector(31 downto 0); data_out: out std_logic_vector(31 downto 0)); end component;
    component mux2 is port (sel: in std_logic; in0: in std_logic_vector(31 downto 0); in1: in std_logic_vector(31 downto 0); out_sig: out std_logic_vector(31 downto 0)); end component;

    signal s1_sign_a, s1_sign_b : std_logic;
    signal s1_exp_a, s1_exp_b : std_logic_vector(7 downto 0);
    signal s1_op_a, s1_op_b : std_logic_vector(31 downto 0);
    
    signal s2_exp_diff : std_logic_vector(7 downto 0);
    signal s2_a_gt_b : std_logic;
    
    signal s2_op_a, s2_op_b : std_logic_vector(31 downto 0);
    signal s2_sign_a, s2_sign_b : std_logic;
    signal s2_exp_a, s2_exp_b : std_logic_vector(7 downto 0);

    
    signal s3_aligned_sig : std_logic_vector(31 downto 0);
    
    signal s3_sig_to_align, s3_sig_direct : std_logic_vector(31 downto 0);
    
    signal s3_sig_direct_delayed : std_logic_vector(31 downto 0);
    signal s3_sign_a, s3_sign_b : std_logic;
    signal s3_a_gt_b : std_logic;
    signal s3_exp_a, s3_exp_b : std_logic_vector(7 downto 0);

    
    signal s4_neg_sum, s4_pos_sum : std_logic_vector(31 downto 0);
    signal s4_neg_carry, s4_pos_carry : std_logic;
    
    signal s4_complement_out : std_logic_vector(31 downto 0);
    signal s4_mux_sum : std_logic_vector(31 downto 0);
    signal s4_mux_carry : std_logic;
    
    signal s4_sign_a, s4_sign_b : std_logic;
    signal s4_a_gt_b : std_logic;
    signal s4_exp_a, s4_exp_b : std_logic_vector(7 downto 0);

    
    signal s5_norm_sum : std_logic_vector(31 downto 0);
    signal s5_norm_exp : std_logic_vector(7 downto 0);
    signal s5_norm_ovf : std_logic;
    
    signal s5_tentative_exp : std_logic_vector(7 downto 0);
    signal s5_sub_op : std_logic;
    
    signal s5_sign_a, s5_sign_b : std_logic;
    signal s5_a_gt_b : std_logic;

    
    signal s6_sig_final : std_logic_vector(22 downto 0);
    signal s6_exp_final : std_logic_vector(7 downto 0);
    signal s6_round_ovf : std_logic;
    
    signal s6_sign_final : std_logic;
    
    signal s_final_ovf : std_logic;

begin

    u_unpack : component unpack
        port map (clk => clk, rst => rst, a_in => a_in, b_in => b_in, sign_a_out => s1_sign_a, sign_b_out => s1_sign_b, exp_a_out => s1_exp_a, exp_b_out => s1_exp_b, op_a_out => s1_op_a, op_b_out => s1_op_b);

    u_exp_sub : component exponent_subtractor
        port map (clk => clk, rst => rst, exp_a_in => s1_exp_a, exp_b_in => s1_exp_b, exp_diff_out => s2_exp_diff, a_gt_b_out => s2_a_gt_b);

    process(clk, rst)
    begin
        if rst = '1' then
            s2_op_a <= (others=>'0'); s2_op_b <= (others=>'0'); s2_sign_a <= '0'; s2_sign_b <= '0'; s2_exp_a <= (others=>'0'); s2_exp_b <= (others=>'0');
        elsif rising_edge(clk) then
            s2_op_a <= s1_op_a; s2_op_b <= s1_op_b; s2_sign_a <= s1_sign_a; s2_sign_b <= s1_sign_b; s2_exp_a <= s1_exp_a; s2_exp_b <= s1_exp_b;
        end if;
    end process;

    s3_sig_to_align <= s2_op_a when s2_a_gt_b = '0' else s2_op_b;
    s3_sig_direct   <= s2_op_b when s2_a_gt_b = '0' else s2_op_a;

    u_align : component align_significand
        port map (clk => clk, rst => rst, sig_in => s3_sig_to_align, shift_amount => s2_exp_diff, sig_out => s3_aligned_sig);

    process(clk, rst)
    begin
        if rst = '1' then
            s3_sig_direct_delayed <= (others=>'0'); s3_sign_a <= '0'; s3_sign_b <= '0'; s3_a_gt_b <= '0'; s3_exp_a <= (others=>'0'); s3_exp_b <= (others=>'0');
        elsif rising_edge(clk) then
            s3_sig_direct_delayed <= s3_sig_direct; s3_sign_a <= s2_sign_a; s3_sign_b <= s2_sign_b; s3_a_gt_b <= s2_a_gt_b; s3_exp_a <= s2_exp_a; s3_exp_b <= s2_exp_b;
        end if;
    end process;

    u_twos_comp : component twos_complement port map (data_in => s3_aligned_sig, data_out => s4_complement_out); 

    u_adder_neg : component carry_lookahead_adder_32
        port map (clk => clk, rst => rst, a_in => s3_sig_direct_delayed, b_in => s4_complement_out, c_in => '0', sum_out => s4_neg_sum, c_out => s4_neg_carry);

    u_adder_pos : component carry_lookahead_adder_32
        port map (clk => clk, rst => rst, a_in => s3_sig_direct_delayed, b_in => s3_aligned_sig, c_in => '0', sum_out => s4_pos_sum, c_out => s4_pos_carry);

    process(clk, rst)
    begin
        if rst = '1' then
            s4_sign_a <= '0'; s4_sign_b <= '0'; s4_a_gt_b <= '0'; s4_exp_a <= (others=>'0'); s4_exp_b <= (others=>'0');
        elsif rising_edge(clk) then
            s4_sign_a <= s3_sign_a; s4_sign_b <= s3_sign_b; s4_a_gt_b <= s3_a_gt_b; s4_exp_a <= s3_exp_a; s4_exp_b <= s3_exp_b;
        end if;
    end process;

    s5_sub_op <= s4_sign_a xor s4_sign_b;
    s4_mux_sum <= s4_neg_sum when s5_sub_op = '1' else s4_pos_sum;
    s4_mux_carry <= s4_neg_carry when s5_sub_op = '1' else s4_pos_carry;
    s5_tentative_exp <= s4_exp_b when s4_a_gt_b = '0' else s4_exp_a;

    u_norm_add : component normalize_add
        port map (clk => clk, rst => rst, sum_in => s4_mux_sum, carry_in => s4_mux_carry, exp_in => s5_tentative_exp, sub_op_in => s5_sub_op, sum_out => s5_norm_sum, exp_out => s5_norm_exp, overflow_out => s5_norm_ovf);

    process(clk, rst)
    begin
        if rst = '1' then
            s5_sign_a <= '0'; s5_sign_b <= '0'; s5_a_gt_b <= '0';
        elsif rising_edge(clk) then
            s5_sign_a <= s4_sign_a; s5_sign_b <= s4_sign_b; s5_a_gt_b <= s4_a_gt_b;
        end if;
    end process;

    u_round_add : component round_add
        port map (clk => clk, rst => rst, sum_in => s5_norm_sum, exp_in => s5_norm_exp, sig_out_final => s6_sig_final, exp_out_final => s6_exp_final, overflow_out => s6_round_ovf);

    process(clk, rst)
    begin
        if rst = '1' then
            s6_sign_final <= '0'; s_final_ovf <= '0';
        elsif rising_edge(clk) then
            if (s5_sign_a xor s5_sign_b) = '0' then 
                s6_sign_final <= s5_sign_a;
            else 
                if s5_a_gt_b = '1' then s6_sign_final <= s5_sign_a; else s6_sign_final <= s5_sign_b; end if;
            end if;
            
            s_final_ovf <= s5_norm_ovf; 
        end if;
    end process;

    u_pack : component pack
        port map (clk => clk, rst => rst, sign_in => s6_sign_final, exp_in => s6_exp_final, sig_in => s6_sig_final, result_out => sum_out);

    overflow_out <= s_final_ovf or s6_round_ovf; 

end architecture structural;