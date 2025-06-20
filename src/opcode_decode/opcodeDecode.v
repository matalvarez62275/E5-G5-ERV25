module OpcodeDecode (
   input wire[31:0] inst,
	
	
	output wire[4:0] rd,		// Destination register (Bus C)
	output wire[4:0] rs1,	// Source register 1 (Bus A)
	output wire[4:0] rs2,	// Source register 2 (Bus B)
	output wire[2:0] func3,

	//instruccion flags
	output reg[14:0] instFlags
);

	// Instruction flags
	localparam RD_EN     	= 14;
   localparam RS1_EN     	= 13;	// For use in the future
   localparam RS2_EN    	= 12;	// For use in the future
   localparam IMM_EN			= 11;
   localparam ALU_INA     	= 10;	// 0: PC,  		  1: rs1
   localparam ALU_INB   	= 9;	// 0: Immediate, 1: rs2
   localparam ALU_EN       = 8;
   localparam ADD_FORCED	= 7;
   localparam ALU_OP       = 6;
   localparam IS_JAL       = 5;
   localparam IS_JALR      = 4;
   localparam IS_BRANCH    = 3;
   localparam READ_EN      = 2;
   localparam WRITE_EN     = 1;
   localparam IS_INVALID   = 0;

	assign rd 		= inst[11:7];
	assign rs1 		= inst[19:15];
	assign rs2 		= inst[24:20];
	assign func3 	= inst[14:12];
	
	wire[4:0] opcode = inst[6:2];
		
	always @(*)
	begin 
	// Instruction word size
	// ERV25 only implements RV32I extension and thus all instructions' lower bits ar
	// 5'bxxx11 - where 3'bxxx is never 3'b111
	
		if(inst[1:0] == 2'b11) begin //Tipo J, inst unica JAL
			case(opcode) 
		
				// JAL (J-type)
				5'b11011:
				begin
					instFlags[RD_EN]			= 1;
					instFlags[RS1_EN]			= 0;
					instFlags[RS2_EN]			= 0;
					instFlags[IMM_EN]			= 1;	
					instFlags[ALU_INA]		= 0;	// PC
					instFlags[ALU_INB]		= 0;	// Not used - Irrelevant	
					instFlags[ALU_EN]			= 1;
					instFlags[ADD_FORCED]	= 0;
					instFlags[ALU_OP]			= 0;
					instFlags[IS_JAL]			= 1;
					instFlags[IS_JALR]		= 0;
					instFlags[IS_BRANCH]		= 0;
					instFlags[READ_EN]		= 0;
					instFlags[WRITE_EN]		= 0;
					instFlags[IS_INVALID]	= 0;
				end
					
				// LUI, AUIPC (U-type)
				5'b01101,5'b00101:
				begin
					instFlags[RD_EN]			= 1;
					instFlags[RS1_EN]			= 0;
					instFlags[RS2_EN]			= 0;
					instFlags[IMM_EN]			= 1;
					instFlags[ALU_INA]		= opcode[3];	// AUIPC -> 0 (PC) | LUI -> 1 (rs1)
					instFlags[ALU_INB]		= 0;				// Immediate
					instFlags[ALU_EN]			= 1;
					instFlags[ADD_FORCED]	= 1;
					instFlags[ALU_OP]			= 0;
					instFlags[IS_JAL]			= 0;
					instFlags[IS_JALR]		= 0;
					instFlags[IS_BRANCH]		= 0;
					instFlags[READ_EN]		= 0;
					instFlags[WRITE_EN]		= 0;	
					instFlags[IS_INVALID]	= 0;							
				end
					
				// JALR (I-type)
				5'b11001:
				begin
					instFlags[RD_EN]			= 1;			
					instFlags[RS1_EN]	 		= 1;		
					instFlags[RS2_EN]	 		= 0;
					instFlags[IMM_EN]	 		= 1;
					instFlags[ALU_INA]	 	= 0;	// PC
					instFlags[ALU_INB]	 	= 0;	// Not used - Irrelevant
					instFlags[ALU_EN]	 		= 1;
					instFlags[ADD_FORCED]	= 0;
					instFlags[ALU_OP]			= 0;
					instFlags[IS_JAL]			= 0;
					instFlags[IS_JALR]		= 1;
					instFlags[IS_BRANCH]		= 0;
					instFlags[READ_EN]	 	= 0;
					instFlags[WRITE_EN]		= 0;
					instFlags[IS_INVALID]	= 0;			
				end
					
				// LOAD (I-type)
				5'b00000:
				begin
					instFlags[RD_EN]			= 1;
					instFlags[RS1_EN]	 		= 1;	// For use in the future
					instFlags[RS2_EN]	 		= 0;
					instFlags[IMM_EN]	 		= 1;
					instFlags[ALU_INA]	 	= 0;	// PC
					instFlags[ALU_INB]	 	= 0;	// Immediate	
					instFlags[ALU_EN]	 		= 0;
					instFlags[ADD_FORCED]	= 0;
					instFlags[ALU_OP]			= 0;
					instFlags[IS_JAL]			= 0;
					instFlags[IS_JALR]		= 0;
					instFlags[IS_BRANCH]		= 0;
					instFlags[READ_EN]	 	= 1;
					instFlags[WRITE_EN]		= 0;
					instFlags[IS_INVALID]	= 0;
				end
				
				// ALU Operations
				5'b00100,5'b01100:
				begin		
					instFlags[RD_EN]			= 1;			
					instFlags[RS1_EN]	 		= 1;				// For use in the future	
					instFlags[RS2_EN]	 		= opcode[3];	// For use in the future
					instFlags[IMM_EN]	 		= !opcode[3];	// Some instructions use ONLY registers
					instFlags[ALU_INA]	 	= 1;				// rs1
					instFlags[ALU_INB]	 	= opcode[3];	// Some instructions use ONLY registers	
					instFlags[ALU_EN]	 		= 1;
					instFlags[ADD_FORCED]	= 0;
					instFlags[ALU_OP]			= inst[30];		// when instructions with the same opcode and func3
					instFlags[IS_JAL]			= 0;
					instFlags[IS_JALR]		= 0;
					instFlags[IS_BRANCH]		= 0;
					instFlags[READ_EN]	 	= 0;
					instFlags[WRITE_EN]		= 0;
					instFlags[IS_INVALID]	= 0;
				end
				
				// STORE (S-type)
				5'b01000:
				begin
					instFlags[RD_EN]			= 0;	// Nothing to be stored in register bank
					instFlags[RS1_EN]	 		= 1;	// For use in the future
					instFlags[RS2_EN]	 		= 1;	// For use in the future
					instFlags[IMM_EN]	 		= 1;
					instFlags[ALU_INA]	 	= 0;	// PC
					instFlags[ALU_INB]	 	= 0;	// Immediate	
					instFlags[ALU_EN]	 		= 0;
					instFlags[ADD_FORCED]	= 0;
					instFlags[ALU_OP]			= 0;
					instFlags[IS_JAL]			= 0;
					instFlags[IS_JALR]		= 0;
					instFlags[IS_BRANCH]		= 0;
					instFlags[READ_EN]	 	= 0;
					instFlags[WRITE_EN]		= 1;
					instFlags[IS_INVALID]	= 0;
				end
				
				// BRANCH (B-type)
				5'b11000:
				begin
					instFlags[RD_EN]			= 0;	// ALU flags don't go to any register		
					instFlags[RS1_EN]			= 1;	// For use in the future		
					instFlags[RS2_EN]	 		= 1;	// For use in the future
					instFlags[IMM_EN]	 		= 1;
					instFlags[ALU_INA]	 	= 1;	// rs1
					instFlags[ALU_INB]	 	= 1;	// rs2	
					instFlags[ALU_EN]	 		= 1;
					instFlags[ADD_FORCED]	= 0;
					instFlags[ALU_OP]			= 0;
					instFlags[IS_JAL]			= 0;
					instFlags[IS_JALR]		= 0;
					instFlags[IS_BRANCH]		= 1;
					instFlags[READ_EN]	 	= 0;
					instFlags[WRITE_EN]		= 0;				
					instFlags[IS_INVALID]	= 0;
				end
				
				
				// CSR (I-type) TODO
					5'b11100:
					begin
						instFlags[RD_EN]			= 0;			
						instFlags[RS1_EN]	 		= 0;		
						instFlags[RS2_EN]	 		= 0;
						instFlags[IMM_EN]	 		= 0;	
						instFlags[ALU_INA]	 	= 0;
						instFlags[ALU_INB]	 	= 0;			
						instFlags[ALU_EN]	 		= 0;			
						instFlags[ADD_FORCED]	= 0;
						instFlags[ALU_OP]			= 0;
						instFlags[IS_JAL]			= 0;
						instFlags[IS_JALR]		= 0;
						instFlags[IS_BRANCH]		= 0;
						instFlags[READ_EN]	 	= 0;				
						instFlags[WRITE_EN]		= 0;				
						instFlags[IS_INVALID]	= 0;
					end
				
					// Invalid
					default:
					begin
						instFlags[RD_EN]			= 0;			
						instFlags[RS1_EN]	 		= 0;		
						instFlags[RS2_EN]	 		= 0;
						instFlags[IMM_EN]	 		= 0;	
						instFlags[ALU_INA]	 	= 0;
						instFlags[ALU_INB]	 	= 0;			
						instFlags[ALU_EN]	 		= 0;			
						instFlags[ADD_FORCED]	= 0;
						instFlags[ALU_OP]			= 0;
						instFlags[IS_JAL]			= 0;
						instFlags[IS_JALR]		= 0;
						instFlags[IS_BRANCH]		= 0;
						instFlags[READ_EN]	 	= 0;				
						instFlags[WRITE_EN]		= 0;					
						instFlags[IS_INVALID]	= 1;
					end
					
			endcase		
		end 	
		else	// Extension not implemented -> Invalid
			begin  
			instFlags[RD_EN]			= 0;			
			instFlags[RS1_EN]	 		= 0;		
			instFlags[RS2_EN]	 		= 0;
			instFlags[IMM_EN]	 		= 0;	
			instFlags[ALU_INA]	 	= 0;
			instFlags[ALU_INB]	 	= 0;			
			instFlags[ALU_EN]	 		= 0;			
			instFlags[ADD_FORCED]	= 0;
			instFlags[ALU_OP]			= 0;
			instFlags[IS_JAL]			= 0;
			instFlags[IS_JALR]		= 0;
			instFlags[IS_BRANCH]		= 0;
			instFlags[READ_EN]	 	= 0;				
			instFlags[WRITE_EN]		= 0;			
			instFlags[IS_INVALID]	= 1;
		end
	end	

endmodule
