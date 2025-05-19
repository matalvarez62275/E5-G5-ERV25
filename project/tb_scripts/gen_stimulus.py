# generate_vectors.py

# Cada test tiene: name + instrucción (hex) + salidas esperadas
# Codificación:
#   [rd(5)][rs1(5)][rs2(5)][func3(3)][rd_en][rs1_en][rs2_en][imm_en]
#   [busA_sel][busB_sel][ALU_en][ALU_flag(2)][is_JAL][is_JALR][is_BRANCH][read_en][write_en][invalid]
#   Total = 5+5+5+3+2+1*13 = 33 bits por vector de salida
instructions = [
    0x002081b3,  # add x3, x1, x2
    0x00108093,  # addi x1, x1, 1
    0x0020a023,  # sw x2, 0(x1)
    0x00208463,  # beq x1, x2, offset
    0x000002b7,  # lui x5, 0
    0x0000006f,  # jal x0, 0
    0xFFFFFFFF   # invalid x0, 0
]


tests = [
    {
        "name": "R-TYPE (ADD)",
        "inst": instructions[0],  # add x3, x1, x2
        "rd": instructions[0] >> 7 & 0b11111,
        "rs1": instructions[0] >> 15 & 0b11111,
        "rs2": instructions[0] >> 20 & 0b11111,
        "func3": instructions[0] >> 12 & 0b111,
        
        "rd_en": 1,
        "rs1_en": 1,
        "rs2_en": 1,
        "imm_en": 0,

        "busA_sel": 1,
        "busB_sel": 1,
        "ALU_en": 1,
        "ALU_flag": 0b00, #18+9 = 27 bits
        
        "is_JAL": 0,
        "is_JALR": 0,
        "is_BRANCH": 0,
        "read_en": 0,
        "write_en": 0,
        "invalid": 0
    },
    {
        "name": "I-TYPE (ADDI)",
        "inst": instructions[1],  # addi x1, x1, 1
       "rd": instructions[1] >> 7 & 0b11111,
        "rs1": instructions[1] >> 15 & 0b11111,
        "rs2": instructions[1] >> 20 & 0b11111,
        "func3": instructions[1] >> 12 & 0b111,
        "rd_en": 1,
        "rs1_en": 1,
        "rs2_en": 0,
        "imm_en": 1,
        "busA_sel": 1,
        "busB_sel": 0,
        "ALU_en": 1,
        "ALU_flag": 0b00,
        "is_JAL": 0,
        "is_JALR": 0,
        "is_BRANCH": 0,
        "read_en": 0,
        "write_en": 0,
        "invalid": 0
    },
    {
        "name": "S-TYPE (SW)",
        "inst":instructions[2],  # sw x2, 0(x1)
        "rd": instructions[2] >> 7 & 0b11111,
        "rs1": instructions[2] >> 15 & 0b11111,
        "rs2": instructions[2] >> 20 & 0b11111,
        "func3": instructions[2] >> 12 & 0b111,
        "rd_en": 1,
        "rs1_en": 1,
        "rs2_en": 1,
        "imm_en": 1,
        "busA_sel": 0,
        "busB_sel": 0,
        "ALU_en": 0,
        "ALU_flag": 0b00,
        "is_JAL": 0,
        "is_JALR": 0,
        "is_BRANCH": 0,
        "read_en": 0,
        "write_en": 1,
        "invalid": 0
    },
    {
        "name": "B-TYPE (BEQ)",
        "inst": instructions[3],  # beq x1, x2, offset
       "rd": instructions[3] >> 7 & 0b11111,
        "rs1": instructions[3] >> 15 & 0b11111,
        "rs2": instructions[3] >> 20 & 0b11111,
        "func3": instructions[3] >> 12 & 0b111,
        "rd_en": 0,
        "rs1_en": 1,
        "rs2_en": 1,
        "imm_en": 1,
        "busA_sel": 1,
        "busB_sel": 1,
        "ALU_en": 1,
        "ALU_flag": 0b00,
        "is_JAL": 0,
        "is_JALR": 0,
        "is_BRANCH": 1,
        "read_en": 0,
        "write_en": 0,
        "invalid": 0
    },
    {
        "name": "U-TYPE (LUI)",
        "inst": instructions[4],  # lui x5, 0
       "rd": instructions[4] >> 7 & 0b11111,
        "rs1": instructions[4] >> 15 & 0b11111,
        "rs2": instructions[4] >> 20 & 0b11111,
        "func3": instructions[4] >> 12 & 0b111,
        "rd_en": 1,
        "rs1_en": 0,
        "rs2_en": 0,
        "imm_en": 1,
        "busA_sel": instructions[4] >> 5 & 0b1,
        "busB_sel": 0,
        "ALU_en": 1,
        "ALU_flag": 0b10,
        "is_JAL": 0,
        "is_JALR": 0,
        "is_BRANCH": 0,
        "read_en": 0,
        "write_en": 0,
        "invalid": 0
    },
    {
        "name": "J-TYPE (JAL)",
        "inst": instructions[5],  # jal x0, 0
        "rd": instructions[5] >> 7 & 0b11111,
        "rs1": instructions[5] >> 15 & 0b11111,
        "rs2": instructions[5] >> 20 & 0b11111,
        "func3": instructions[5] >> 12 & 0b111,
        "rd_en": 1,
        "rs1_en": 0,
        "rs2_en": 0,
        "imm_en": 1,
        "busA_sel": 0,
        "busB_sel": 0,
        "ALU_en": 0,
        "ALU_flag": 0b00,
        "is_JAL": 1,
        "is_JALR": 0,
        "is_BRANCH": 0,
        "read_en": 0,
        "write_en": 0,
        "invalid": 0
    },
     {
        "name": "INVALID INSTRUCTION",
        "inst": instructions[6],  # invalid x0, 0
       "rd": instructions[6] >> 7 & 0b11111,
        "rs1": instructions[6] >> 15 & 0b11111,
        "rs2": instructions[6] >> 20 & 0b11111,
        "func3": instructions[6] >> 12 & 0b111,
        "rd_en": 0,
        "rs1_en": 0,
        "rs2_en": 0,
        "imm_en": 0,
        "busA_sel": 0,
        "busB_sel": 0,
        "ALU_en": 0,
        "ALU_flag": 0b00,
        "is_JAL": 0,
        "is_JALR": 0,
        "is_BRANCH": 0,
        "read_en": 0,
        "write_en": 0,
        "invalid": 1
    }
]

with open("test_instructions.mem", "w") as f_inst, open("expected_outputs.mem", "w") as f_exp:
    for t in tests:
        f_inst.write(f"{t['inst']:08x}\n")
        bits = (
            (t["rd"]        << 28) |
            (t["rs1"]       << 23) |
            (t["rs2"]       << 18) |
            (t["func3"]     << 15) |
            (t["rd_en"]     << 14) |
            (t["rs1_en"]    << 13) |
            (t["rs2_en"]    << 12) |
            (t["imm_en"]    << 11) |
            (t["busA_sel"]  << 10) |
            (t["busB_sel"]  << 9)  |
            (t["ALU_en"]    << 8)  |
            (t["ALU_flag"]  << 6)  |
            (t["is_JAL"]    << 5)  |
            (t["is_JALR"]   << 4)  |
            (t["is_BRANCH"] << 3)  |
            (t["read_en"]   << 2)  |
            (t["write_en"]  << 1)  |
            (t["invalid"]   << 0)
        )
        f_exp.write(f"{bits:033b}\n")
