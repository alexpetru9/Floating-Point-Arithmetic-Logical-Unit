library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_floating_point_multiplier is
end entity tb_floating_point_multiplier;

architecture behavioral of tb_floating_point_multiplier is

    component floating_point_multiplier is
        port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            a_in         : in  std_logic_vector(31 downto 0);
            b_in         : in  std_logic_vector(31 downto 0);
            d_out        : out std_logic_vector(31 downto 0);
            overflow_out : out std_logic
        );
    end component floating_point_multiplier;

    signal clk            : std_logic := '0';
    signal rst            : std_logic := '0';
    signal s_a_in         : std_logic_vector(31 downto 0) := (others => '0');
    signal s_b_in         : std_logic_vector(31 downto 0) := (others => '0');
    signal s_d_out        : std_logic_vector(31 downto 0);
    signal s_overflow_out : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT : component floating_point_multiplier
        port map (
            clk          => clk,
            rst          => rst,
            a_in         => s_a_in,
            b_in         => s_b_in,
            d_out        => s_d_out,
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

        -- Case 1: 2.5 * 3.0 = 7.5 
        s_a_in <= x"40200000"; -- 2.5
        s_b_in <= x"40400000"; -- 3.0
        --40F00000
        wait for 100 ns; 
       
        -- Case 2: 2.5 * (-3.0) = -7.5 
        s_a_in <= x"40200000"; -- 2.5
        s_b_in <= x"C0400000"; -- -3.0
        --C0F00000 
        wait for 100 ns;
        
        -- Case 3: 2.5 * 0.0 = 0.0 
        s_a_in <= x"40200000"; -- 2.5
        s_b_in <= x"00000000"; -- 0.0
        --00000000 
        wait for 100 ns;
        
        -- Case 4: 2.5 * Infinit = Infinit 
        s_a_in <= x"40200000"; -- 2.5
        s_b_in <= x"7F800000"; -- +Inf
        --7F800000 
        wait for 100 ns;

        -- Case 5: OVERFLOW (Mare * Mare = Infinit)
        s_a_in <= x"71800000"; -- aprox 2^100
        s_b_in <= x"5F800000"; -- aprox 2^64
        --7F800000 
        wait for 100 ns;

        -- Case 6: UNDERFLOW (Mic * Mic = Zero)
        s_a_in <= x"0D800000"; -- aprox 2^-100
        s_b_in <= x"1F800000"; -- aprox 2^-64
        --00000000 
        wait for 100 ns;

        wait; 
    end process stimulus_process;
end architecture behavioral;