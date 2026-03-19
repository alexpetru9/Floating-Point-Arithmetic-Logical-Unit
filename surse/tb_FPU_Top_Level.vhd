library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_FPU_Top_Level is
end tb_FPU_Top_Level;

architecture Behavioral of tb_FPU_Top_Level is
    
    component FPU_Top_Level is
        Port ( 
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            final_result : out STD_LOGIC_VECTOR(31 downto 0);
            pc_debug_out : out STD_LOGIC_VECTOR(7 downto 0) 
        );
    end component;

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal final_result : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_view : STD_LOGIC_VECTOR(7 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
begin
    DUT: FPU_Top_Level 
        port map (
            clk => clk, 
            rst => rst, 
            final_result => final_result,
            pc_debug_out => pc_view
        );

    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2; clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        rst <= '1'; wait for 20 ns; rst <= '0';
        wait for 200 ns;
        wait;
    end process;
end Behavioral;