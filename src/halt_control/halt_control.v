module halt_control(
	input wire [14:0] intFlag_OpDec,
	input wire [4:0] rs1_OpDec,
	input wire [4:0] rs2_OpDec,
	input wire [4:0] rd_OpDec,
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
	input wire inst_is_jalr,
	input wire inst_is_branch,
	input wire clk,
	input wire nreset,
	
	output reg IFU_en,
	output reg DE_en,
	output reg OP_en,
	output reg EX_en,
	output wire IFU_flush
);



// -------- Decoder has instruction that needs a register that will be written
wire decoded_needs_regaccess_write = instFlag_sl_DE[14] && (rd_sl_DE != 5'b0) && ((rs1_OpDec === rd_sl_DE) || (rs2_OpDec === rd_sl_DE));
wire decoded_needs_alu_write = instFlag_Alu[14] && (rd_Alu != 5'b0) && ((rs1_OpDec === rd_Alu) || (rs2_OpDec === rd_Alu));
wire decoded_needs_postalu_write = instFlag_sl_EX[14] && (rd_sl_EX != 5'b0) && ((rs1_OpDec === rd_sl_EX) || (rs2_OpDec === rd_sl_EX));

wire decoded_blocked;
assign decoded_blocked = decoded_needs_regaccess_write || decoded_needs_alu_write || decoded_needs_postalu_write;
// ---------

// -------- Reg access has instruction that needs a register that will be written
wire regaccess_needs_alu_write = instFlag_Alu[14] && (rd_Alu != 5'b0) && ((rs1_sl_DE === rd_Alu) || (rs2_sl_DE === rd_Alu));
wire regaccess_needs_postalu_write = instFlag_sl_EX[0] && (rd_sl_EX != 5'b0) & ((rs1_sl_DE === rd_sl_EX) || (rs2_sl_DE === rd_sl_EX));

wire regaccess_blocked;
assign regaccess_blocked = regaccess_needs_alu_write || regaccess_needs_postalu_write;
// ---------

// -------- JALR y branch control
wire jalr_rs1_dep = 
		~instFlag_sl_EX[4] && inst_is_jalr && (
		(rs1_OpDec != rs1_sl_DE) ||
		(rs1_sl_DE != rs1_Alu) ||
		(rs1_Alu != rs1_sl_EX)
	);
wire branch_rs_dep =
		~instFlag_sl_EX[3] && inst_is_branch && (
        ((rs1_OpDec != rs1_sl_DE) && (rs2_OpDec != rs2_sl_DE)) ||
        ((rs1_OpDec != rs1_Alu) && (rs2_OpDec != rs2_Alu)) || 
		  ((rs1_Alu != rs1_sl_EX) && (rs2_Alu != rs2_sl_EX))
	);
wire jump_stall;
assign jump_stall = jalr_rs1_dep || branch_rs_dep;
//

always @(decoded_blocked, regaccess_blocked, jump_stall) begin
	IFU_en <= 1;
	DE_en <= 1;
	OP_en <= 1;
	EX_en <= 1;
	
	// hazard in decoding stage
	if(decoded_blocked) begin
		DE_en <= 0;
		IFU_en <= 0;
	end 
	// hazard in operand stage
	else if(regaccess_blocked) begin
		OP_en <= 0;
		DE_en <= 0;
		IFU_en <= 0;
	end
	else if(jump_stall) begin
		IFU_en <= 0;
	end
end

//Flush instrucciones de salto
reg jump_stall_prev;
reg flushing;

always @(posedge clk or negedge nreset) begin
	if (!nreset) begin
		jump_stall_prev <= 0;
		flushing <= 0;
	end else begin
		jump_stall_prev <= jump_stall;

		// encender flushing un ciclo después de que jump_stall se prende
		if (~jump_stall_prev & jump_stall)
			flushing <= 1;

		// apagar cuando jump_stall se apaga
		else if (~jump_stall)
			flushing <= 0;
	end
end

assign IFU_flush = flushing;

endmodule