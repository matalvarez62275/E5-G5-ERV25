module IFU_NOP_ctrl (
    input  wire clk,
    input  wire nreset,
    input  wire [2:0] instr_JMP, 	// instruction[6:4]
	 
    output reg  NOP_en
);

reg [1:0] stall_counter;

// Instruction is JAL, JALR, or BRANCH
wire is_jump_instr = (instr_JMP == 3'b110);

always @(posedge clk or negedge nreset) begin
	if (!nreset) begin
		NOP_en <= 0;
      stall_counter <= 0;
   end else begin
		if (stall_counter != 0) begin
			stall_counter <= stall_counter - 1;
         NOP_en <= 1;
      end else if (is_jump_instr) begin
			stall_counter <= 2'd2;	// Stall for 3 cycles after a jump
         NOP_en <= 1;
      end else
			NOP_en <= 0;
   end
end
endmodule