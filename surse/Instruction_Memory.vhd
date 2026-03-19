library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instruction_Memory is
    Port ( 
        addr_in   : in  STD_LOGIC_VECTOR (7 downto 0);
        instr_out : out STD_LOGIC_VECTOR (15 downto 0)
    );
end Instruction_Memory;

architecture Behavioral of Instruction_Memory is
    type rom_type is array (0 to 15) of std_logic_vector(15 downto 0);
    
    -- Instruction format: 
    -- Opcode(2) | Dest(3) | SrcA(3) | SrcB(3) | Padding(5)
    -- 00=ADD, 10=MUL
    
    constant ROM : rom_type := (
        -- Instr 0: ADD R7 = R0(1.5) + R1(2.5) ->  4.0 (x40800000)
        0 => "00" & "111" & "000" & "001" & "00000",
        
        -- Instr 1: MUL R7 = R0(1.5) * R3(3.0) ->  4.5 (x40900000)
        1 => "10" & "111" & "000" & "011" & "00000",
        
        -- Instr 2: ADD R7 = R2(-1.0) + R4(-2.0) ->  -3.0 (xC0400000)
        2 => "00" & "111" & "010" & "100" & "00000",
        
        -- Instr 3: MUL R7 = R5(1.0) * R6(2.0) ->  2.0 (x40000000)
        3 => "10" & "111" & "101" & "110" & "00000",
        
        others => (others => '0') -- NOP
    );
begin
    instr_out <= ROM(to_integer(unsigned(addr_in(3 downto 0))));
end Behavioral;