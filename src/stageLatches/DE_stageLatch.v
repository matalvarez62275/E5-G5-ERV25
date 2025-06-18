module DE_stageLatch(
		input wire [31:0] imm,		
		input wire [4:0] rd,
		input wire [4:0] rs1,
		input wire [4:0] rs2,
		input wire [2:0] func3,
		input wire [14:0] instFlag,
		input wire [31:0] PC,
		input wire predicted_taken_IFU,

		input wire clk,
		input wire en,
		
		output reg [31:0] imm_sl1,		
		output reg [4:0] rd_sl1,
		output reg [4:0] rs1_sl1,
		output reg [4:0] rs2_sl1,
		output reg [2:0] func3_sl1,
		output reg [14:0] instFlag_sl1,
		output reg [31:0] PC_sl1,
		output reg predicted_taken_sl1
		

);


always @(posedge clk) begin 
	if(en == 0)begin 
		instFlag_sl1 <= 0;
		rd_sl1 <= 0;
		rs1_sl1 <= 0;
		rs2_sl1 <= 0;
		imm_sl1 <= 0;
		PC_sl1 <= 0;
		func3_sl1 <= 0;
		predicted_taken_sl1 <= 0;

	end else begin
		instFlag_sl1 <= instFlag;
		rd_sl1 <= rd;
		rs1_sl1 <= rs1;
		rs2_sl1 <= rs2;
		imm_sl1 <= imm;
		PC_sl1 <= PC;
		func3_sl1 <= func3;
		predicted_taken_sl1 <= predicted_taken_IFU;

	end
end



endmodule 