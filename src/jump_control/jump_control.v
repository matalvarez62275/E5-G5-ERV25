module jump_control (
	input [31:0] imm_DE,
	input imm_en_DE,
	input [31:0] rs1_data_DE,
	input is_JALR_DE,
	input ALU_Z,
	input ALU_N,
	
	input wire [2:0] funct3_OP,
	input wire is_branch_Alu,

	input clk,
	input en,
	input nreset,
	
	output wire branch_taken,
	output wire JALR_taken,
	output wire [31:0] JALR_address
);

wire is_jalr = en & is_JALR_DE;
wire is_branch = en & is_branch_Alu;

wire branch_BEQ_BNE = (funct3_OP[2:1] == 2'b00) && ((!funct3_OP[0]) == ALU_Z); // 0: beq, 1: bne
wire branch_other = ((funct3_OP[2:1] == 2'b10) || (funct3_OP[2:1] == 2'b11)) && (funct3_OP[0] ^ ALU_N); // 0: blt, branch si n=1, 1: bge, branch si n=0, unsigned o signed
assign branch_taken = is_branch && (branch_other || branch_BEQ_BNE);

wire [31:0] rs1plusimm = (rs1_data_DE + imm_DE) & 32'hFFFFFFFE;

assign JALR_taken = is_jalr & imm_en_DE;
 
assign JALR_address = is_jalr ? rs1plusimm : 32'b0;

endmodule
