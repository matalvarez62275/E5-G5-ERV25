module immBuilder(
		input wire [31:0] inst,
		
		output reg [31:0] imm
		);
		
	
	wire[4:0] opcode = inst[6:2];
	
	always @(*)
	begin
	
		case(opcode)
		5'b11011: begin						//Tipo J
			imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
		end
		5'b01101, 5'b00101: begin			//Tipo U
			imm = {inst[31:12], 12'h000};
		end
		5'b11000: begin						//Tipo B
			imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:18], 1'b0};
		end
		5'b01000: begin						//Tipo S
			imm = {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]};
		end
		5'b00000, 5'b11100: begin			//Tipo I
			imm = {{21{inst[31]}}, inst[30:20]};
		end
		5'b00100: begin
			if(inst[14:12] == 3'b101 || inst[14:12] == 3'b001) begin		//tipo R shamt
				//formar imm
			end else begin																//tipo I
				//formar imm
			end
		default:
			imm = 32'b0;
			
		
		endcase
	
	
	end