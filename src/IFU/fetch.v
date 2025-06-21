module fetch(
	input[31:0] curr_PC,
	input clk,
	input nreset,
	input en,
	
	output[31:0] nxt_PC
);

reg[31:0] programcounter;

always @(posedge clk or negedge nreset) begin
	if(!nreset) programcounter <= 0;
	else if(en) programcounter <= curr_PC + 4;
end
	
assign nxt_PC = programcounter;

endmodule