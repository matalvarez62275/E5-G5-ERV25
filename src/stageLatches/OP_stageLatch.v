module OP_stageLatch(
		input wire [31:0] imm,		
		input wire [4:0] rd,
		input wire [4:0] rs1,
		input wire [4:0] rs2,
		input wire [2:0] func3,
		input wire [14:0] instFlag,
		input wire [31:0] PC,
		input wire [31:0] rs1_data,
		input wire [31:0] rs2_data,

		input wire clk,
		input wire en,
		
		output reg [31:0] imm_sl2,		
		output reg [4:0] rd_sl2,
		output reg [4:0] rs1_sl2,
		output reg [4:0] rs2_sl2,
		output reg [2:0] func3_sl2,
		output reg [14:0] instFlag_sl2,
		output reg [31:0] PC_sl2,
		output reg [31:0] rs1_data_sl2,
		output reg [31:0] rs2_data_sl2

);


always @(posedge clk) begin 
	if(en == 0)begin 
		instFlag_sl2 <= 0;
		rd_sl2 <= 0;
		rs1_sl2 <= 0;
		rs2_sl2 <= 0;
		imm_sl2 <= 0;
		PC_sl2 <= 0;
		rs1_data_sl2 <= 0;
		rs2_data_sl2 <= 0;
	end else begin
		instFlag_sl2 <= instFlag;
		rd_sl2 <= rd;
		rs1_sl2 <= rs1;
		rs2_sl2 <= rs2;
		imm_sl2 <= imm;
		PC_sl2 <= PC;
		rs1_data_sl2 <= rs1_data;
		rs2_data_sl2 <= rs2_data;
	end
end


endmodule 