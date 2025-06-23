module ALU (
    input [31:0] in_a,
    input [31:0] in_b,
    input [2:0] func3,
    input en,
    input add_forced,
    input ALU_op,
    input is_JAL,
    input is_JALR,
    input is_branch,
    output reg [31:0] result,
    output reg ALU_Z,
    output reg ALU_N
);

reg [32:0] ans;	// Extra bit to handle overflow

always @(*) begin
	ans 		= 33'b0;
   result 	= 32'b0;
	ALU_Z 	= 1'b0;
   ALU_N 	= 1'b0;

	if (en == 1'b0)
		ans = 33'b0;
		 
	// LUI and AUIPC
	else if (add_forced == 1'b1)
	    ans = $signed({1'b0, in_a}) + $signed({1'b0, in_b});
	
	// JAL and JALR
	else if (is_JAL == 1'b1 || is_JALR == 1'b1)	
	    ans = {1'b0, in_a} + 4;
		 
	// BRANCH
	else if (is_branch == 1'b1) begin
		
		// BLTU and BGEU
		if (func3[2])
			ALU_N = (in_a < in_b) ? 1'b1 : 1'b0;
		
		// BEQ, BNE, BLT and BGE
		else
			ALU_N = ($signed(in_a) < $signed(in_b)) ? 1'b1 : 1'b0;	
	end
	
	// ALU operations
	else	
		begin
			case (func3)
				
				3'b000:
				begin
					if (ALU_op == 1'b0)
						ans = $signed({1'b0, in_a}) + $signed({1'b0, in_b}); // ADD
               else
                  ans = $signed({1'b0, in_a}) - $signed({1'b0, in_b}); // SUB
            end
            
				3'b100: ans = {1'b0, in_a} ^ {1'b0, in_b}; // XOR
            3'b110: ans = {1'b0, in_a} | {1'b0, in_b}; // OR
            3'b111: ans = {1'b0, in_a} & {1'b0, in_b}; // AND
            3'b001: ans = {1'b0, in_a} << in_b[4:0];   // SLL
                
				3'b101: begin
					if (ALU_op == 1'b0)
						ans = {1'b0, in_a} >> in_b[4:0]; // SRL
					else
						ans = $signed({1'b0, in_a}) >>> in_b[4:0]; // SRA
            end

            3'b010: ans = ($signed(in_a) < $signed(in_b)) ? 33'b1 : 33'b0; // SLT
            3'b011: ans = (in_a < in_b) ? 33'b1 : 33'b0;                   // SLTU
            default: ans = 33'b0;
			endcase
		end

    result = ans[31:0];
    ALU_Z = (in_a == in_b) ? 1'b1 : 1'b0; // Zero flag
end
endmodule