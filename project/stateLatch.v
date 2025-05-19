module stateLatch(
		input wire [31:0] imm,		
		input wire [4:0] rd,
		input wire [4:0] rs1,
		input wire [4:0] rs2,
		input wire [2:0] func3,
		input wire [14:0] instFrag,

		input wire clk,
		input wire en,
		
		output reg [31:0] imm_sl1,		
		output reg [4:0] rd_sl1,
		output reg [4:0] rs1_sl1,
		output reg [4:0] rs2_sl1,
		output reg [2:0] func3_sl1,
		output reg [14:0] instFrag_sl1

);


always @(posedge clk) begin 
	if(en == 0)begin 
		instFrag_sl1 <= 0;
		rd_sl1 <= 0;
		rs1_sl1 <= 0;
		rs2_sl1 <= 0;
		imm_sl1 <= 0;
	end else begin
		instFrag_sl1 <= instFrag;
		rd_sl1 <= rd;
		rs1_sl1 <= rs1;
		rs2_sl1 <= rs2;
		imm_sl1 <= imm;
	end
end



endmodule 