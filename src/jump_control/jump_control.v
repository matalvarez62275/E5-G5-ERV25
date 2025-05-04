module jump_control (
    input wire        is_JAL,
    input wire        is_JALR,
    input wire        is_branch,
    input wire [2:0]  branch,
    input wire        imm_en,
    input wire [31:0] imm,
    input wire [31:0] rs1,
    input wire        ALU_Z,
    input wire        ALU_N,
	 output reg [31:0] JALR_address,
    output reg        JALR_en,
    output reg        jump
);

    reg branch_taken;

    always @(*) begin
        // Evaluar condición solo si es una instrucción de tipo BRANCH
        if (is_branch) begin
            case (branch)
                3'b000: branch_taken = ALU_Z;        // BEQ
                3'b001: branch_taken = ~ALU_Z;       // BNE
                3'b100: branch_taken = ALU_N;        // BLT
                3'b101: branch_taken = ~ALU_N;       // BGE
                3'b110: branch_taken = ALU_N;        // BLTU
                3'b111: branch_taken = ~ALU_N;       // BGEU
                default: branch_taken = 1'b0;
            endcase
        end else begin
            branch_taken = 1'b0;
        end

        // Determinar si hay salto
        jump = imm_en & (is_JAL | (is_branch & branch_taken));

        // Habilitación y dirección de JALR
        JALR_en = is_JALR & imm_en;
        JALR_address = is_JALR ? ((rs1 + imm) & 32'hFFFFFFFE) : 32'b0;
    end

endmodule
