module halt_control(
	input wire [4:0] rs1_OpDec,
	input wire [4:0] rs2_OpDec,
	input wire [14:0] instFlag_sl_DE,
	input wire [4:0] rs1_sl_DE,
	input wire [4:0] rs2_sl_DE,
	input wire [4:0] rd_sl_DE,
	input wire [14:0] instFlag_Alu,
	input wire [4:0] rs1_Alu,
	input wire [4:0] rs2_Alu,
	input wire [4:0] rd_Alu,
	input wire [14:0] instFlag_sl_EX,
	input wire [4:0] rs1_sl_EX,
	input wire [4:0] rs2_sl_EX,
	input wire [4:0] rd_sl_EX,
	input wire is_JALR,
	input wire is_branch,
	
	input wire clk,
	input wire nreset,
	
	output reg IFU_en,
	output reg DE_en,
	output reg OP_en,
	output reg EX_en,
	output wire IFU_flush,
	output wire decoded_blocked,
	output wire regaccess_blocked,
	output wire jump_stall
);

/*
Remember:
	- Destination register (rd) will be written if and only if instFlag[14] == 1'b1 (rd_en)
	- Register x0 is a hard-wired zero by design thus the check for rd != 5'b0
	- If any of the source registers (rs1, rs2) from the decoded instruction are the same as one of the destination registers (rd)
	in the pipeline from previous instructions, the pipeline should be halted to allow for consistncy.
*/

// Decoder has an instruction that needs a register that will be written
wire decoded_needs_regaccess_write =
		instFlag_sl_DE[14] && (rd_sl_DE != 5'b0) && (
			(rs1_OpDec === rd_sl_DE) ||
			(rs2_OpDec === rd_sl_DE)
		);
wire decoded_needs_alu_write =
		instFlag_Alu[14] && (rd_Alu != 5'b0) && (
			(rs1_OpDec === rd_Alu) ||
			(rs2_OpDec === rd_Alu)
		);
wire decoded_needs_postalu_write =
		instFlag_sl_EX[14] && (rd_sl_EX != 5'b0) && (
			(rs1_OpDec === rd_sl_EX) ||
			(rs2_OpDec === rd_sl_EX)
		);

assign decoded_blocked = decoded_needs_regaccess_write || decoded_needs_alu_write || decoded_needs_postalu_write;

// Register access has an instruction that needs a register that will be written
wire regaccess_needs_alu_write =
		instFlag_Alu[14] && (rd_Alu != 5'b0) && (
			(rs1_sl_DE === rd_Alu) ||
			(rs2_sl_DE === rd_Alu)
		);
wire regaccess_needs_postalu_write =
		instFlag_sl_EX[0] && (rd_sl_EX != 5'b0) && (
			(rs1_sl_DE === rd_sl_EX) ||
			(rs2_sl_DE === rd_sl_EX)
		);

assign regaccess_blocked = regaccess_needs_alu_write || regaccess_needs_postalu_write;

// JALR or BRANCH instruction needs a register that will be written
wire jalr_rs1_dep = 
		~instFlag_sl_EX[4] && is_JALR && (
			(rs1_OpDec != rs1_sl_DE) ||
			(rs1_sl_DE != rs1_Alu) ||
			(rs1_Alu != rs1_sl_EX)
		);
wire branch_rs_dep =
		~instFlag_sl_EX[3] && is_branch && (
			((rs1_OpDec != rs1_sl_DE) && (rs2_OpDec != rs2_sl_DE)) ||
			((rs1_OpDec != rs1_Alu) && (rs2_OpDec != rs2_Alu)) || 
			((rs1_Alu != rs1_sl_EX) && (rs2_Alu != rs2_sl_EX))
		);

assign jump_stall = jalr_rs1_dep || branch_rs_dep;

reg jump_stall_start;
always @(decoded_blocked, regaccess_blocked) begin
	// Default: All stages enabled
	IFU_en <= 1;
	DE_en <= 1;
	OP_en <= 1;
	EX_en <= 1;
	jump_stall_start <= 0;
	
	// Hazard in decoding stage
	if(decoded_blocked) begin
		DE_en <= 0;
		IFU_en <= 0;
	end
	
	// Hazard in operand stage
	else if(regaccess_blocked) begin
			OP_en <= 0;
			DE_en <= 0;
			IFU_en <= 0;
	end
	
	// Don't fetch any instructions until the jump is resolved
	else if(jump_stall) begin
		IFU_en <= 0;
		jump_stall_start <= 1;
	end
end

// Flushing
reg jump_stall_prev;
reg flushing;
always @(posedge clk or negedge nreset) begin
	if (!nreset) begin
		jump_stall_prev <= 0;
		flushing <= 0;
	end else if (jump_stall_start) begin
		jump_stall_prev <= jump_stall;

		// encender flushing un ciclo después de que jump_stall se prende
		if (~jump_stall_prev & jump_stall)
			flushing <= 1;

		// apagar cuando jump_stall se apaga
		else if (~jump_stall)
			flushing <= 0;
	end else if (~jump_stall_start) begin
		jump_stall_prev <= 0;
		flushing <= 0;
	end		
end

assign IFU_flush = flushing;
endmodule