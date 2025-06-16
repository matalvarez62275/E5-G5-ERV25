module immBuilder(
	input wire [31:0] inst,
	output reg [31:0] imm
);
	wire[4:0] opcode = inst[6:2];
	
	always @(*)
	begin
		case(opcode)
		
			// J-Type (Jump instructions)
			5'b11011:
				imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
			
			// U-type (Upper immediate instructions)
			5'b01101, 5'b00101:
				imm = {inst[31:12], 12'h000};
			
			// B-type (Branch instructions)
			5'b11000:
				imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
			
			// S-Type (Store instructions)
			5'b01000:
				imm = {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]};
			
			// I-Type (Immediate instructions)
			5'b00000, 5'b11100, 5'b11001:
				imm = {{21{inst[31]}}, inst[30:20]};
				
			// Special case for opcode 00100
			5'b00100:
			begin
				if(inst[14:12] == 3'b101 || inst[14:12] == 3'b001)
					// R-Type shift instructions (shamt field)
					imm = {27'b0,inst[24:20]};
				else
					// I-Type
					imm = {{21{inst[31]}}, inst[30:20]};
			end
			
			// Default case for unsupported opcodes
			default:
				imm = 32'b0;

		endcase
	end
endmodule