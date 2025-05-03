module register_bank #(
   parameter REG_WIDTH = 32,
   parameter NUM_REGS = 32,
   parameter SEL_WIDTH = $clog2(NUM_REGS) // Calculate selector width
)(
	input en,
	input clk,
   input reset,
   input wire [SEL_WIDTH-1:0] busASelector,
   input wire [SEL_WIDTH-1:0] busBSelector,
   input wire [SEL_WIDTH-1:0] busCSelector,
	input [REG_WIDTH-1:0] busC,
   output [REG_WIDTH-1:0] busA,
   output [REG_WIDTH-1:0] busB
);
reg [REG_WIDTH-1:0] register_bank[NUM_REGS-1:0];
integer i; // Loop variable

assign busA = register_bank[busASelector];
assign busB = register_bank[busBSelector];

always @(posedge clk, negedge reset) begin
	//Reset logic
   if (!reset) begin
      for (i = 0; i < NUM_REGS; i = i + 1) begin
			register_bank[i] = 0;
		end
   end
   // Clock gating 
	else if (en) begin
		if (busCSelector != 0) register_bank[busCSelector] <= busC;
   end
end

endmodule