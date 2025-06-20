module jump_control (
	input [31:0] imm_EX,
	input imm_en_EX,
	input [31:0] rs1_data_EX,
	input is_JALR_EX,
	input ALU_Z_EX,
	input ALU_N_EX,
	
	input wire [2:0] funct3_EX,
	input wire is_branch_EX,

	input clk,
	input en,
	input nreset,
	
	output wire branch_taken,
	output wire JALR_taken,
	output wire [31:0] JALR_address
);

wire is_jalr = en & is_JALR_EX;
wire is_branch = en & is_branch_EX;

wire branch_BEQ_BNE = (funct3_EX[2:1] == 2'b00) && ((!funct3_EX[0]) == ALU_Z_EX); // 0: beq, 1: bne
wire branch_other = ((funct3_EX[2:1] == 2'b10) || (funct3_EX[2:1] == 2'b11)) && (funct3_EX[0] ^ ALU_N_EX); // 0: blt, branch si n=1, 1: bge, branch si n=0, unsigned o signed
assign branch_taken = is_branch && (branch_other || branch_BEQ_BNE);

wire [31:0] rs1plusimm = (rs1_data_EX + imm_EX) & 32'hFFFFFFFE;

assign JALR_taken = is_jalr & imm_en_EX;
 
assign JALR_address = is_jalr ? rs1plusimm : 32'b0;

endmodule
