module EX_stageLatch(
		input wire [31:0] result,		
		input wire [4:0] rd,
		input wire [14:0] instFlag,

		input wire clk,
		input wire en,
		
		output reg [31:0] result_sl3,		
		output reg [4:0] rd_sl3,
		output reg [14:0] instFlag_sl3
);


always @(posedge clk) begin 
	if(en == 0)begin 
		result_sl3 <= 0;
		rd_sl3 <= 0;
		instFlag_sl3 <= 0;

	end else begin
		result_sl3 <= result;
		rd_sl3 <= rd;
		instFlag_sl3 <= instFlag;

	end
end

endmodule 