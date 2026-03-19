library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File_8x32 is
    Port ( 
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        we           : in  STD_LOGIC;
        
        addr_a       : in  STD_LOGIC_VECTOR (2 downto 0);
        addr_b       : in  STD_LOGIC_VECTOR (2 downto 0);
        addr_w       : in  STD_LOGIC_VECTOR (2 downto 0);
        
        data_w       : in  STD_LOGIC_VECTOR (31 downto 0);
        
        data_a       : out STD_LOGIC_VECTOR (31 downto 0);
        data_b       : out STD_LOGIC_VECTOR (31 downto 0);
        
        reg7_out     : out STD_LOGIC_VECTOR (31 downto 0) 
    );
end Register_File_8x32;

architecture Behavioral of Register_File_8x32 is
    type reg_array is array (0 to 7) of std_logic_vector(31 downto 0);
    
    signal registers : reg_array := (
        0 => x"3FC00000", -- R0: 1.5
        1 => x"40200000", -- R1: 2.5
        2 => x"BF800000", -- R2: -1.0
        3 => x"40400000", -- R3: 3.0
        4 => x"C0000000", -- R4: -2.0
        5 => x"3F800000", -- R5: 1.0
        6 => x"40000000", -- R6: 2.0
        7 => x"00000000"  -- R7: Result
    );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                registers(7) <= (others => '0');
            elsif we = '1' then
                registers(to_integer(unsigned(addr_w))) <= data_w;
            end if;
        end if;
    end process;

    data_a <= registers(to_integer(unsigned(addr_a)));
    data_b <= registers(to_integer(unsigned(addr_b)));
    reg7_out <= registers(7);

end Behavioral;