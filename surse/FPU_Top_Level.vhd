library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FPU_Top_Level is
    Port ( 
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        final_result : out STD_LOGIC_VECTOR(31 downto 0);
        pc_debug_out : out STD_LOGIC_VECTOR(7 downto 0) 
    );
end FPU_Top_Level;

architecture Structural of FPU_Top_Level is
    component Program_Counter is
        Port ( clk, rst, en : in STD_LOGIC; addr_out : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
    component Instruction_Memory is
        Port ( addr_in : in STD_LOGIC_VECTOR(7 downto 0); instr_out : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    component Register_File_8x32 is
        Port ( clk, rst, we : in STD_LOGIC; addr_a, addr_b, addr_w : in STD_LOGIC_VECTOR(2 downto 0); data_w : in STD_LOGIC_VECTOR(31 downto 0); data_a, data_b, reg7_out : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    component control_fsm is
        Port ( clk, rst : in STD_LOGIC; instruction : in STD_LOGIC_VECTOR(15 downto 0); pc_en, reg_we, mux_sel : out STD_LOGIC; addr_dest, addr_src1, addr_src2 : out STD_LOGIC_VECTOR(2 downto 0));
    end component;

    component floating_point_adder is
        Port ( clk, rst : in STD_LOGIC; a_in, b_in : in STD_LOGIC_VECTOR(31 downto 0); sum_out : out STD_LOGIC_VECTOR(31 downto 0); overflow_out : out STD_LOGIC);
    end component;
    
    component floating_point_multiplier is
        Port ( clk, rst : in STD_LOGIC; a_in, b_in : in STD_LOGIC_VECTOR(31 downto 0); d_out : out STD_LOGIC_VECTOR(31 downto 0); overflow_out : out STD_LOGIC);
    end component;

    signal pc_addr : std_logic_vector(7 downto 0);
    signal instruction : std_logic_vector(15 downto 0);
    signal pc_en, reg_we, mux_sel : std_logic;
    signal addr_dest, addr_src1, addr_src2 : std_logic_vector(2 downto 0);
    signal reg_data_a, reg_data_b : std_logic_vector(31 downto 0);
    signal adder_res, mult_res, wb_data : std_logic_vector(31 downto 0);
    signal ovf_a, ovf_m : std_logic;

begin

    PC : Program_Counter port map (clk => clk, rst => rst, en => pc_en, addr_out => pc_addr);
    pc_debug_out <= pc_addr;

    IM : Instruction_Memory port map (addr_in => pc_addr, instr_out => instruction);

    FSM : control_fsm port map (
        clk => clk, rst => rst, instruction => instruction,
        pc_en => pc_en, reg_we => reg_we, mux_sel => mux_sel,
        addr_dest => addr_dest, addr_src1 => addr_src1, addr_src2 => addr_src2
    );

    REG_FILE : Register_File_8x32 port map (
        clk => clk, rst => rst, we => reg_we,
        addr_a => addr_src1, addr_b => addr_src2, addr_w => addr_dest,
        data_w => wb_data, data_a => reg_data_a, data_b => reg_data_b,
        reg7_out => final_result
    );

    ADDER : floating_point_adder port map (clk => clk, rst => rst, a_in => reg_data_a, b_in => reg_data_b, sum_out => adder_res, overflow_out => ovf_a);
    MULTIPLIER : floating_point_multiplier port map (clk => clk, rst => rst, a_in => reg_data_a, b_in => reg_data_b, d_out => mult_res, overflow_out => ovf_m);

    wb_data <= adder_res when mux_sel = '0' else mult_res;

end Structural;