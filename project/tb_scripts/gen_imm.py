def sign_extend(val, bits):
    if val & (1 << (bits - 1)):
        return val | (~0 << bits)  # Sign extend
    return val

tests = [
    # Tipo I: ADDI x4, x0, 0x000 → imm = 0
    (0x00000213, sign_extend(0x000, 12)),

    # Tipo I: ADDI x4, x0, -1 (0xFFF) → imm = -1
    (0xFFF00213, sign_extend(0xFFF, 12)),
    
    # Tipo R: SLLI x1, x2, 3 → imm = 3
    # Formato: func7 + shamt[5:0] + rs1 + funct3 + rd + opcode
    ((0b0000000 << 25) | (0b00011 << 20) | (2 << 15) | (0b001 << 12) | (1 << 7) | 0b0010011,
     sign_extend(0x003, 12)),

    # Tipo S: SW x3, 0x0AB(x4)
    # imm = 0xAB (000010101011)
    # imm[11:5] = 0x05 = 000000101
    # imm[4:0]  = 0x0B = 01011
    # opcode = 0100011 (store), funct3 = 010
    # rs1 = x4, rs2 = x3, imm = 0xAB
    # Formato: imm[11:5] + rs2 + rs1 + funct3 + imm[4:0] + opcode
    ((0x05 << 25) | (3 << 20) | (4 << 15) | (2 << 12) | (0x0B << 7) | 0b0100011,
     sign_extend(0x0AB, 12)),

    # Tipo B: BEQ x1, x2, 0x1A4 (debe ser múltiplo de 2)
    # imm' = 0x1A4 = 00 011010 0100 0 -> numero real = 0x1A4 * 2 = 0x348
    # Formato: imm[12|10:5|4:1|11]
    # imm[12] = 0, imm[10:5] = 011010, imm[4:1] = 0100, imm[11] = 0

    ((0 << 31) | (0b011010 << 25) | (2 << 20) | (1 << 15) | (1 << 12) | (0b0100 << 8) | (0 << 7) | 0b1100011,
     sign_extend( 0x0348, 12)),

    # Tipo U: LUI x5, 0x12345 → imm = 0x12345000
    # Formato: imm[31:12] + rd + opcode 
    ((0x12345 << 12) | (5 << 7) | 0b0110111,
     (0x12345 << 12) & 0xFFFFF000),

    # Tipo J: JAL x1, 0x00AB0
    # JAL formato: imm[20|10:1|11|19:12] + 0
    # 0x00AB0 = 0 00000001 0 1010110000 (en binario) + 0 = 
    # imm[20] = 0, [10:1]=1010110000, [11]=0, [19:12]=00000001
    # Formato: imm[20] + imm[10:1] + imm[11] + imm[19:12] + rd + opcode
    ((0 << 31) | (0x2B0 << 21) | (0 << 20) | (0x1 << 12) | (1 << 7) | 0b1101111,
     sign_extend(0x01560, 21)),
]

with open("imm_test.mem", "w") as f_instr, open("imm_expected.mem", "w") as f_out:
    for instr, imm in tests:
        f_instr.write(f"{instr:08x}\n")
        f_out.write(f"{imm & 0xFFFFFFFF:08x}\n")
