module halt_control(
	input wire [14:0] intFlag_OpDec,
	input wire [4:0] rs1_OpDec,
	input wire [4:0] rs2_OpDec,
	input wire [4:0] rd_OpDec,
	input wire [14:0] instFlag_sl_DE,
	input wire [4:0] rs1_sl_DE,
	input wire [31:0] rs1_data_sl_DE,
	input wire [4:0] rs2_sl_DE,
	input wire [31:0] imm_sl_DE,
	input wire [4:0] rd_sl_DE,
	input wire [14:0] instFlag_Alu,
	input wire [4:0] rd_Alu,
	input wire [14:0] instFlag_sl_EX,
	input wire [4:0] rd_sl_EX,
	input wire [31:0] rs1_data_MEM,
	input wire [31:0] imm_MEM,
	
	output reg IFU_en,
	output reg DE_en,
	output reg OP_en,
	output reg EX_en
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

// -------- Reg access has instruction that needs a register that has a pending load
//wire [12:0] addr_sl_DE;
//wire [12:0] addr_MEM;

//add_2x32b_00lsbs #(.OUT_WIDTH(13)) addr_calc_sl_DE (
//    .A(rs1_data_sl_DE),
//    .B(imm_sl_DE),
//    .aligned_sum_out(addr_sl_DE)
//);

//add_2x32b_00lsbs #(.OUT_WIDTH(13)) addr_calc_MEM (
//    .A(rs1_data_MEM),
//    .B(imm_MEM),
//    .aligned_sum_out(addr_MEM)
//);

//wire mem_hazard = instFlag_sl_DE[2] && instFlag_Alu[1] && (addr_sl_DE == addr_MEM);
// ---------


always @(decoded_blocked, regaccess_blocked) begin
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
end


endmodule