library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        -- Inputs
        in_a: in STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input word A
        in_b: in STD_LOGIC_VECTOR(31 DOWNTO 0); -- Input word B
        opcode : in STD_LOGIC_VECTOR(2 DOWNTO 0); -- Opcode with 3 bits.
        selec : in STD_LOGIC; -- Extra bit for handling opcodes.
        branch : in STD_LOGIC; -- Extra bit for handling opcodes.
        jal: in STD_LOGIC; -- Absolute jump flag.
        enable: in STD_LOGIC; -- Enable ALU control flag.
        -- Outputs
        out_c : out STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output word C
        out_n : out STD_LOGIC := '0'; -- Negative flag
        out_z : out STD_LOGIC := '0' -- Zero flag
    ); --TODO: add jalr
end ALU;

architecture behavioral of ALU is
    -- SIGNAL local_a, local_b, localsum : STD_LOGIC_VECTOR(32 DOWNTO 0);

BEGIN
    PROCESS (in_a, in_b, opcode, selec, jal)
        VARIABLE ans : STD_LOGIC_VECTOR(32 DOWNTO 0);
    BEGIN
        -- Check enable flag
        IF enable = '0' THEN
            ans := "000000000000000000000000000000000";
        END IF;

        -- Check jal (and other flags)
        IF jal = '1' THEN
            ans := STD_LOGIC_VECTOR(resize(unsigned(in_a), 33) + 4);
        END IF;
        
        -- Branch operations
        IF branch = '1' THEN
            CASE opcode IS
                WHEN "000" =>  -- BEQ
                    IF signed(in_a) = signed(in_b) THEN
                        ans := (others => '0'); ans(0) := '1';
                    ELSE
                        ans := (others => '0');
                    END IF;
            
                WHEN "001" =>  -- BNE
                    IF signed(in_a) /= signed(in_b) THEN
                        ans := (others => '0'); ans(0) := '1';
                    ELSE
                        ans := (others => '0');
                    END IF;
            
                WHEN "100" =>  -- BLT
                    IF signed(in_a) < signed(in_b) THEN
                        ans := (others => '0'); ans(0) := '1';
                    ELSE
                        ans := (others => '0');
                    END IF;
            
                WHEN "101" =>  -- BGE
                    IF signed(in_a) >= signed(in_b) THEN
                        ans := (others => '0'); ans(0) := '1';
                    ELSE
                        ans := (others => '0');
                    END IF;
            
                WHEN "110" =>  -- BLTU
                    IF unsigned(in_a) < unsigned(in_b) THEN
                        ans := (others => '0'); ans(0) := '1';
                    ELSE
                        ans := (others => '0');
                    END IF;
            
                WHEN "111" =>  -- BGEU
                    IF unsigned(in_a) >= unsigned(in_b) THEN
                        ans := (others => '0'); ans(0) := '1';
                    ELSE
                        ans := (others => '0');
                    END IF;
            
                WHEN OTHERS =>
                    ans := (others => '0');
            END CASE;
        ELSE -- Other operations, separated by type
            CASE opcode IS
                -- Arithmetic
                WHEN "000" =>
                    IF selec = '0' THEN
                        ans := STD_LOGIC_VECTOR(resize(signed(in_a), 33) + resize(signed(in_b), 33)); -- ADD
                    ELSE
                        ans := STD_LOGIC_VECTOR(resize(signed(in_a), 33) - resize(signed(in_b), 33)); -- SUB
                    END IF;
                -- Bitwise
                WHEN "100" => ans := STD_LOGIC_VECTOR(resize(unsigned(in_a), 33) XOR resize(unsigned(in_b), 33)); -- XOR
                WHEN "110" => ans := STD_LOGIC_VECTOR(resize(unsigned(in_a), 33) OR resize(unsigned(in_b), 33)); -- OR
                WHEN "111" => ans := STD_LOGIC_VECTOR(resize(unsigned(in_a), 33) AND resize(unsigned(in_b), 33)); -- AND
                -- Shift
                WHEN "001" => ans := STD_LOGIC_VECTOR(shift_left(resize(unsigned(in_a), 33), to_integer(unsigned(in_b(4 DOWNTO 0))))); -- SLL
                WHEN "101" =>
                    IF selec = '0' THEN
                        ans := STD_LOGIC_VECTOR(shift_right(resize(unsigned(in_a), 33), to_integer(unsigned(in_b(4 DOWNTO 0))))); -- SRL
                    ELSE
                        ans := STD_LOGIC_VECTOR(shift_right(resize(signed(in_a), 33), to_integer(unsigned(in_b(4 DOWNTO 0))))); -- SRA
                    END IF;
                -- Set
                WHEN "010" => -- SLT
                    IF signed(in_a) < signed(in_b) THEN
                        ans := (others => '0'); ans(0) := '1';
                    ELSE
                        ans := (others => '0');
                    END IF;
                WHEN "011" => -- SLTU
                    IF unsigned(in_a) < unsigned(in_b) THEN
                        ans := (others => '0'); ans(0) := '1';
                    ELSE
                        ans := (others => '0');
                    END IF;
                -- End clause
                WHEN OTHERS => ans := "000000000000000000000000000000000";
            END CASE;
        END IF;

        -- Finally assign output variables
        -- Zero flag
        IF unsigned(ans) = 0 THEN
            out_z <= '1';
        ELSE
            out_z <= '0';
        END IF;
        -- Negative flag
        IF signed(ans) < 0 THEN
            out_n <= '1';
        ELSE
            out_n <= '0';
        END IF;
        -- Output register C
        out_c <= ans(31 DOWNTO 0);
    END PROCESS;
END behavioral;