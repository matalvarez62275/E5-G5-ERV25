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
reg [31:0] branch_aux;

always @(*) begin
	ans 	= 33'b0;
   result 	= 32'b0;

	if (en == 1'b0) 
	    ans = 33'b0;
	else if (add_forced == 1'b1)	// LUI and AUIPC
	    ans = $signed({1'b0, in_a}) + $signed({1'b0, in_b});
	else if (is_JAL == 1'b1 || is_JALR == 1'b1)	// JAL and JALR
	    ans = {1'b0, in_a} + 4;
	else if (is_branch == 1'b1)	// BRANCH
		begin //fijarse func3 para los unsigned
			if(func3[2:1] == 2'b11) begin 
				branch_aux = in_a - in_b;
				ALU_N = (in_a < in_b) ? 1'b1 : 1'b0;    // Negative flag 
				end
			else begin
				branch_aux = $signed(in_a) - $signed(in_b);	
				ALU_N = branch_aux[31];    // Negative flag 
				end
    	end
	else	// ALU operations
		begin
			case (func3)
				
				3'b000:
				begin
					if (ALU_op == 1'b0)
						ans = $signed({in_a}) + $signed({in_b}); // ADD
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
		ALU_Z = (in_a == in_b) ? 1'b1 : 1'b0; // Zero flag
				
//	 if (is_branch == 1'b1)
//	 begin
//		ALU_Z = (branch_aux[31:0] == 32'b0) ? 1'b1 : 1'b0; // Zero flag
//		ALU_N = (branch_aux[31] == 1'b1) ? 1'b1 : 1'b0;    // Negative flag 
//	 end
	 
end
endmodule
