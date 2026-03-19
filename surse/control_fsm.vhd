library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_fsm is
    Port ( 
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        instruction : in  STD_LOGIC_VECTOR (15 downto 0);
        
        pc_en       : out STD_LOGIC;
        reg_we      : out STD_LOGIC;
        mux_sel     : out STD_LOGIC; 
        
        addr_dest   : out STD_LOGIC_VECTOR(2 downto 0);
        addr_src1   : out STD_LOGIC_VECTOR(2 downto 0);
        addr_src2   : out STD_LOGIC_VECTOR(2 downto 0)
    );
end control_fsm;

architecture Behavioral of control_fsm is
    type state_type is (FETCH, DECODE, WAIT_EXEC, WRITE_BACK);
    signal current_state : state_type := FETCH;
    
    signal wait_counter : integer range 0 to 15 := 0;
    signal target_latency : integer := 0;
    
    alias opcode : std_logic_vector(1 downto 0) is instruction(15 downto 14);
begin

    addr_dest <= instruction(13 downto 11);
    addr_src1 <= instruction(10 downto 8);
    addr_src2 <= instruction(7 downto 5);

    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= FETCH;
            wait_counter <= 0;
            pc_en <= '0'; reg_we <= '0';
        elsif rising_edge(clk) then
            pc_en <= '0'; reg_we <= '0';
            
            case current_state is
                when FETCH =>
                    current_state <= DECODE;
                    
                when DECODE =>
                    if opcode = "00" then -- ADD
                        target_latency <= 8; 
                        mux_sel <= '0';
                        current_state <= WAIT_EXEC;
                    elsif opcode = "10" then -- MUL
                        target_latency <= 6; 
                        mux_sel <= '1';
                        current_state <= WAIT_EXEC;
                    else
                        current_state <= FETCH; -- NOP
                    end if;
                    wait_counter <= 0;

                when WAIT_EXEC =>
                    if wait_counter < target_latency then
                        wait_counter <= wait_counter + 1;
                    else
                        current_state <= WRITE_BACK;
                    end if;

                when WRITE_BACK =>
                    reg_we <= '1';
                    pc_en <= '1';
                    current_state <= FETCH;
            end case;
        end if;
    end process;
end Behavioral;