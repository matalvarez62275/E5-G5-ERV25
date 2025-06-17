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
        forced_sum: in STD_LOGIC; -- Forced add flag.
        is_jal: in STD_LOGIC; -- Absoulte Jump flag.
        is_jalr: in STD_LOGIC; -- Absolute Jump flag.
        enable: in STD_LOGIC; -- Enable ALU control flag.
        -- Outputs
        out_c : out STD_LOGIC_VECTOR(31 DOWNTO 0); -- Output word C
        out_n : out STD_LOGIC := '0'; -- Negative flag
        out_z : out STD_LOGIC := '0' -- Zero flag
    );
end ALU;

architecture behavioral of ALU is
    -- SIGNAL local_a, local_b, localsum : STD_LOGIC_VECTOR(32 DOWNTO 0);

BEGIN
    PROCESS (enable, in_a, in_b, opcode, selec, forced_sum, is_jal, is_jalr, branch)
        VARIABLE ans : STD_LOGIC_VECTOR(32 DOWNTO 0);
        VARIABLE force_N : STD_LOGIC; -- for unsigned operations forcing N flag
    BEGIN
        -- Check enable flag
        IF enable = '0' THEN
            ans := "000000000000000000000000000000000";
            force_N := '0';
        END IF;

        -- Check forced_sum (and other flags)
        IF forced_sum = '1' THEN
            ans := STD_LOGIC_VECTOR(resize(signed(in_a), 33) + resize(signed(in_b), 33));
       

        ELSIF is_jal = '1' THEN
            ans := STD_LOGIC_VECTOR(resize(unsigned(in_a), 33) + 4);
        

        ELSIF is_jalr = '1' THEN
            ans := STD_LOGIC_VECTOR(resize(unsigned(in_a), 33) + 4);
        
        -- Branch operations
        ELSIF branch = '1' THEN
            CASE opcode IS
                WHEN "000" =>  -- BEQ
                    -- A equals B then the substraction is 0, flag Z is set
                    ans := STD_LOGIC_VECTOR(resize(signed(in_a), 33) - resize(signed(in_b), 33));
            
                WHEN "001" =>  -- BNE
                    -- A is not equal to B then the substraction is not 0, flag Z is not set
                    ans := STD_LOGIC_VECTOR(resize(signed(in_a), 33) - resize(signed(in_b), 33));
            
                WHEN "100" =>  -- BLT
                    -- A is less than B then the substraction is less than 0, flag N is set
                    ans := STD_LOGIC_VECTOR(resize(signed(in_a), 33) - resize(signed(in_b), 33));
            
                WHEN "101" =>  -- BGE
                    -- A is more than or equal to B then the substraction is more than 0, flag N is not set
                    ans := STD_LOGIC_VECTOR(resize(signed(in_a), 33) - resize(signed(in_b), 33));
            
                WHEN "110" =>  -- BLTU
                    -- A is less than B then the flag N is set and the output is the substraction
                    IF unsigned(in_a) < unsigned(in_b) THEN
                        force_N := '1';
                    ELSE
                        force_N := '0';
                    END IF;
                    ans := STD_LOGIC_VECTOR(resize(unsigned(in_a), 33) - resize(unsigned(in_b), 33));
            
                WHEN "111" =>  -- BGEU
                    -- A is equal or greater than B then the output MSB is set to 0, flag N is not set
                    IF unsigned(in_a) >= unsigned(in_b) THEN
                        force_N := '0';
                    ELSE
                        force_N := '1';
                    END IF;
                    ans := STD_LOGIC_VECTOR(resize(unsigned(in_a), 33) - resize(unsigned(in_b), 33));
            
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
        IF (force_N = '1') OR (signed(ans) < 0) THEN
            out_n <= '1';
            force_N := '0';
        ELSE
            out_n <= '0';
        END IF;
        -- Output register C
        out_c <= ans(31 DOWNTO 0);
    END PROCESS;
END behavioral;