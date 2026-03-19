library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity align_significand is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        sig_in       : in  std_logic_vector(31 downto 0);
        shift_amount : in  std_logic_vector(7 downto 0); 
        sig_out      : out std_logic_vector(31 downto 0)
    );
end entity align_significand;

architecture behavioral of align_significand is
begin
    process(clk, rst)
        variable v_shift_val : integer;
    begin
        if rst = '1' then
            sig_out <= (others => '0');
        elsif rising_edge(clk) then
            v_shift_val := to_integer(unsigned(shift_amount));
            if v_shift_val >= 32 then
                sig_out <= (others => '0');
            else
                sig_out <= std_logic_vector(shift_right(unsigned(sig_in), v_shift_val));
                -- shiftam mantisa cea mai mica cu nr de pozitii si astfel creste exponentul
            end if;
        end if;
    end process;
end architecture behavioral;