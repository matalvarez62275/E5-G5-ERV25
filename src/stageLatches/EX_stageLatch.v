module EX_stageLatch(
		input wire [31:0] result,	
		input wire [31:0] rs1_data,	
		input wire [4:0] rd,
		input wire [14:0] instFlag,
		input wire [2:0] func3,
		input wire [31:0] imm,
		input wire [31:0] PC,
		input wire alu_N,
		input wire alu_Z,

		input wire clk,
		input wire en,
		
		output reg [31:0] result_sl3,
		output reg [31:0] rs1_data_sl3,		
		output reg [4:0] rd_sl3,
		output reg [14:0] instFlag_sl3,
		output reg [2:0] func3_sl3,
		output reg [31:0] imm_sl3,
		output reg [31:0] PC_sl3,
		output reg alu_N_sl3,
		output reg alu_Z_sl3
);


always @(posedge clk) begin 
	if(en == 0)begin 
		result_sl3 <= 0;
		rs1_data_sl3 <= 0;
		rd_sl3 <= 0;
		instFlag_sl3 <= 0;
		func3_sl3 <= 0;
		imm_sl3 <= 0;
		alu_N_sl3 <= 0;
		alu_Z_sl3 <= 0;
		PC_sl3 <= 0;

	end else begin
		result_sl3 <= result;
		rs1_data_sl3 <= rs1_data;
		rd_sl3 <= rd;
		instFlag_sl3 <= instFlag;
		func3_sl3 <= func3;
		imm_sl3 <= imm;
		alu_N_sl3 <= alu_N;
		alu_Z_sl3 <= alu_Z;
		PC_sl3 <= PC;

	end
end

endmodule 