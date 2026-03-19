library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity tb_floating_point_adder is
end entity tb_floating_point_adder;

architecture behavioral of tb_floating_point_adder is
    component floating_point_adder is
        port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            a_in         : in  std_logic_vector(31 downto 0);
            b_in         : in  std_logic_vector(31 downto 0);
            sum_out      : out std_logic_vector(31 downto 0);
            overflow_out : out std_logic
        );
    end component floating_point_adder;
    
    signal clk            : std_logic := '0';
    signal rst            : std_logic := '0';
    signal s_a_in         : std_logic_vector(31 downto 0) := (others => '0');
    signal s_b_in         : std_logic_vector(31 downto 0) := (others => '0');
    signal s_sum_out      : std_logic_vector(31 downto 0);
    signal s_overflow_out : std_logic;

    constant CLK_PERIOD : time := 10 ns;
    constant LATENCY    : integer := 7;

begin

    DUT : component floating_point_adder
        port map (
            clk          => clk,
            rst          => rst,
            a_in         => s_a_in,
            b_in         => s_b_in,
            sum_out      => s_sum_out,
            overflow_out => s_overflow_out
        );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    stimulus_process : process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 10 ns; 

        -- Case 1: 1.5 + 2.5 = 4.0
        s_a_in <= x"3FC00000"; 
        s_b_in <= x"40200000"; 
        --40800000
        wait for LATENCY * CLK_PERIOD; 
        wait for 2 ns;       
        
        -- Case 2: 4.0 + (-1.5) = 2.5 
        s_a_in <= x"40800000"; 
        s_b_in <= x"BFC00000"; 
        --40200000
        wait for LATENCY * CLK_PERIOD;
        wait for 2 ns;
       
        -- Case 3: -1.0 + 3.0 = 2.0 
        s_a_in <= x"BF800000"; 
        s_b_in <= x"40400000"; 
        --40000000
        wait for LATENCY * CLK_PERIOD;
        wait for 2 ns;
        
        -- Case 4: -1.0 + (-3.0) = -4.0
        s_a_in <= x"BF800000"; 
        s_b_in <= x"C0400000"; 
        --C0800000
        wait for LATENCY * CLK_PERIOD;
        wait for 2 ns;
        
        -- Case 5: +Inf + +Inf = +Inf
        s_a_in <= x"7F800000"; 
        s_b_in <= x"7F800000"; 
        --7F800000
        wait for LATENCY * CLK_PERIOD;
        wait for 2 ns;
        
        -- Case 6: -Inf + -Inf = -Inf
        s_a_in <= x"FF800000"; 
        s_b_in <= x"FF800000"; 
        --FF800000
        wait for LATENCY * CLK_PERIOD;
        wait for 2 ns;
        
        -- Case 7: 1.0 + Inf = Inf
        s_a_in <= x"3F800000"; 
        s_b_in <= x"7F800000"; 
        --7F800000
        wait for LATENCY * CLK_PERIOD;
        wait for 2 ns;
        
        -- Case 8: +Inf + (-Inf)
        s_a_in <= x"7F800000"; 
        s_b_in <= x"FF800000"; 
        --FF800000
        wait for LATENCY * CLK_PERIOD;
        wait for 2 ns;
        
        wait;
    end process stimulus_process;
end architecture behavioral;