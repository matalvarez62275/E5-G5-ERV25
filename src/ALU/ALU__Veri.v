module ALU_Veri (
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
	ans 	= 33'b0;
   result 	= 32'b0;
	ALU_Z 	= 1'b0;
   ALU_N 	= 1'b0;

	if (en == 1'b0) 
	    ans = 33'b0;
	else if (add_forced == 1'b1)	// LUI and AUIPC
	    ans = $signed({1'b0, in_a}) + $signed({1'b0, in_b});
	else if (is_JAL == 1'b1 || is_JALR == 1'b1)	// JAL and JALR
	    ans = {1'b0, in_a} + 4;
	else if (is_branch == 1'b1)	// BRANCH
		begin
			case (func3)
				3'b000: ans = ($signed(in_a) == $signed(in_b)) ? 33'b1 : 33'b0;	// BEQ
            3'b001: ans = ($signed(in_a) != $signed(in_b)) ? 33'b1 : 33'b0; // BNE
            3'b100: ans = ($signed(in_a) < $signed(in_b)) ? 33'b1 : 33'b0;  // BLT
            3'b101: ans = ($signed(in_a) >= $signed(in_b)) ? 33'b1 : 33'b0; // BGE
            3'b110: ans = (in_a < in_b) ? 33'b1 : 33'b0;                    // BLTU
            3'b111: ans = (in_a >= in_b) ? 33'b1 : 33'b0;                   // BGEU
            default: ans = 33'b0;
        	endcase
    	end
	else	// ALU operations
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
                
				3'b101:
				begin
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
    ALU_Z = (ans[31:0] == 32'b0) ? 1'b1 : 1'b0; // Zero flag
    ALU_N = (ans[32] == 1'b1) ? 1'b1 : 1'b0;    // Negative flag
end
endmodule