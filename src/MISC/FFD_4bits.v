module FFD_4bits(
		input wire [3:0] d,
		input wire clk,
		input wire en,
		
		output reg [3:0] q	

);


always @(posedge clk) begin 
	if(en == 0)begin 
		q <= 0;

	end else begin
		q <= d;

	end
end



endmodule 