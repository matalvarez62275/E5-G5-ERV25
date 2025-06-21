module jump_control (
   input wire        is_JAL,
   input wire        is_JALR,
   input wire        is_branch,
   input wire [2:0]  func3,
   input wire        imm_en,
   input wire [31:0]	imm,
   input wire [31:0] rs1_data,
   input wire        ALU_Z,
   input wire        ALU_N,
	
	input en,
	
	output wire [31:0] 	JALR_address,
   output wire				JALR_taken,
   output wire				branch_taken
);

localparam ALIGN_MASK = 32'hFFFFFFFE;

wire is_jalr_en 	= en & is_JALR;
wire is_branch_en = en & is_branch;

wire branch_zero= (func3[2:1] == 2'b00) && ((!func3[0]) == ALU_Z);
wire branch_negative = ((func3[2:1] == 2'b10) || (func3[2:1] == 2'b11)) && (func3[0] ^ ALU_N);
assign branch_taken = is_branch_en && (branch_negative || branch_zero);

assign JALR_taken = is_jalr_en & imm_en;
assign JALR_address = is_jalr_en ? ((rs1_data + imm) & ALIGN_MASK) : 32'b0;	// Align to 2-byte boundary
endmodule