library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Program_Counter is
    Port ( 
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        en       : in  STD_LOGIC;
        addr_out : out STD_LOGIC_VECTOR (7 downto 0)
    );
end Program_Counter;

architecture Behavioral of Program_Counter is
    signal count : unsigned(7 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            count <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                count <= count + 1;
            end if;
        end if;
    end process;
    addr_out <= std_logic_vector(count);
end Behavioral;