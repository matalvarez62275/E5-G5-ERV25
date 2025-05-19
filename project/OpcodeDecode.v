module OpcodeDecode (
   input wire[31:0] inst,
	
	
	output wire[4:0] rd,
	output wire[4:0] rs1,
	output wire[4:0] rs2,
	output wire[2:0] func3,

	//instruccion flags
	output reg[14:0] instFlags
	
	/*
	output reg rd_en,		 	//index - 14	
	output reg rs1_en,			//index - 13
	output reg rs2_en,			//index - 12 
	output reg imm_en,			//index - 11 	
	output reg busA_sel,		//index - 10 - 0: PC, 1: rs1, de la ALU
	output reg busB_sel,		//index - 9 - 0: imm, 1: rs2, de la ALU
	output reg ALU_en,			//index - 8 - ALU_en	
								//index - 7 - ALU_flag[1]: ADD forzada
	output reg[1:0] ALU_flag,	//index - 6 - Alu_flag[0]: ALU op
	output reg is_JAL,			//index - 5
	output reg is_JALR,			//index - 4
	output reg is_BRANCH,		//index - 3
	output reg read_en,			//index - 2
	output reg write_en,		//index - 1
	output reg is_invalid 		//index - 0
	*/
);

	assign rd = inst[11:7];
	assign rs1 = inst[19:15];
	assign rs2 = inst[24:20];
	assign func3 = inst[14:12];
	
	wire[4:0] opcode = inst[6:2];
		
	always @(*)
	begin 
	if(inst[1:0] == 2'b11) begin //Tipo J, inst unica JAL
		case(opcode) 
			5'b11011: begin	//Tipo J, inst unica JAL
				instFlags[14] = 1;
				instFlags[13] = 0;
				instFlags[12] = 0;
				instFlags[11] = 1;
				instFlags[10] = 0;	//0->PC
				instFlags[9] = 0;	//1->rs2 en disable -> 0x00000000	
				instFlags[8] = 0;
				instFlags[7] = 0;	// ALU op
				instFlags[6] = 0;	// ADD forzada
				instFlags[5] = 1;
				instFlags[4] = 0;
				instFlags[3] = 0;
				instFlags[2] = 0;
				instFlags[1] = 0;
				instFlags[0] = 0;
			end
			5'b01101,5'b00101:begin     //Tipo U, inst unicas LUI, AUIPC
			instFlags[14]	= 1;
			instFlags[13]	 = 0;
			instFlags[12]	 = 0;
			instFlags[11]	 = 1;
			instFlags[10]	 = opcode[3];	// 0->PC
			instFlags[9]	 = 0;			//0 -> IMM	
			instFlags[8]	 = 1;
			instFlags[7]	 = 1;	// ADD forzada
			instFlags[6]	 = 0;	// ALU op
			instFlags[5]	 = 0;
			instFlags[4]	= 0;
			instFlags[3]	 = 0;
			instFlags[2]	 = 0;
			instFlags[1]	 = 0;	
			instFlags[0]	 = 0;							
			end
			5'b11001: begin		// JALR tipo I
			instFlags[14]	= 1;			
			instFlags[13]	 = 1;		
			instFlags[12]	 = 0;
			instFlags[11]	 = 1;
			instFlags[10]	 = 0;				// 0->PC, 1->rs1
			instFlags[9]	 = 1;				//0 -> IMM, 1->rs2	
			instFlags[8]	 = 0;
			instFlags[7]	= 0;			// ADD forzada
			instFlags[6]	= 0;			// ALU op
			instFlags[5]	 = 0;
			instFlags[4]	= 1;
			instFlags[3]	 = 0;
			instFlags[2]	 = 0;
			instFlags[1]	= 0;
			instFlags[0]	 = 0;			
			end
			5'b00000: begin 				 //Instruccion LOAD tipo I
			instFlags[14]	= 1;			//rd enable ? o es interno del manejo de memoria? 0-> la ALU no escribe en Rd
			instFlags[13]	 = 1;			//enable necesario?
			instFlags[12]	 = 0;
			instFlags[11]	 = 1;			//enable necesario?
			instFlags[10]	 = 0;	// 0->PC
			instFlags[9]	 = 0;	//0 -> IMM	
			instFlags[8]	 = 0;
			instFlags[7]	 = 0;	// ADD forzada
			instFlags[6]	 = 0;	// ALU op
			instFlags[5]	 = 0;
			instFlags[4]	= 0;
			instFlags[3]	 = 0;
			instFlags[2]	 = 1;
			instFlags[1]	= 0;
			instFlags[0]	 = 0;
			end
			
			5'b00100,5'b01100: begin	//Operaciones de la ALU.		
			instFlags[14]= 1;			
			instFlags[13] = 1;		
			instFlags[12] = opcode[3];
			instFlags[11] = !opcode[3];	
			instFlags[10] = 1;				// 0->PC, 1->rs1
			instFlags[9]	 = opcode[3];	//0 -> IMM, 1->rs2	
			instFlags[8]	 = 1;
			instFlags[7]	= 0;			// ADD forzada
			instFlags[6]	= inst[30];	// ALU op
			instFlags[5]	 = 0;
			instFlags[4]	= 0;
			instFlags[3]	 = 0;
			instFlags[2]	 = 0;
			instFlags[1]	= 0;
			instFlags[0]	 = 0;
			end
			
			5'b01000: begin 				//Instruccion Store tipo S
			instFlags[14]	= 1;			//rd enable ? o es interno del manejo de memoria?
			instFlags[13]	 = 1;			//enable necesario?
			instFlags[12]	 = 1;			//salen datos
			instFlags[11]	 = 1;			//enable necesario?
			instFlags[10]	= 0;	// 0->PC
			instFlags[9]	 = 0;	//0 -> IMM	
			instFlags[8]	= 0;
			instFlags[7]	 = 0;	// ADD forzada
			instFlags[6]	 = 0;	// ALU op
			instFlags[5]	= 0;
			instFlags[4]		= 0;
			instFlags[3]		 = 0;
			instFlags[2]		= 0;
			instFlags[1]		 = 1;
			instFlags[0]		= 0;
			end
			
			5'b11000: begin 				//Instruccion Branch tipo B 
			instFlags[14]= 0;			
			instFlags[13] = 1;		
			instFlags[12] = 1;
			instFlags[11] = 1;	
			instFlags[10] = 1;				// 0->PC, 1->rs1
			instFlags[9]	 = 1;			//0 -> IMM, 1->rs2	
			instFlags[8]	 = 1;
			instFlags[7]	 = 0;			// ADD forzada	
			instFlags[6]	 = 0;			// ALU op
			instFlags[5]	 = 0;
			instFlags[4]	= 0;
			instFlags[3]	 = 1;
			instFlags[2]	 = 0;
			instFlags[1]	= 0;				
			instFlags[0]	 = 0;
			end
			
			5'b11100: begin 				//Instruccion CSR tipo I. TO DO
			instFlags[14]= 0;			
			instFlags[13] = 0;		
			instFlags[12] = 0;
			instFlags[11] = 0;	
			instFlags[10] = 0;
			instFlags[9] = 0;			// ALU op
			instFlags[8] = 0;			// ADD forzada
			instFlags[7]	 = 0;
			instFlags[6]= 0;
			instFlags[5] = 0;
			instFlags[4] = 0;
			instFlags[3]= 0;
			instFlags[2] = 0;				// 0->PC, 1->rs1
			instFlags[1]= 0;				//0 -> IMM, 1->rs2	
			instFlags[0] = 0;
			end
		
			default: begin 				//agregar is_valid? TO DO
				instFlags[14]= 0;			
			instFlags[13] = 0;		
			instFlags[12] = 0;
			instFlags[11] = 0;	
			instFlags[10] = 0;
			instFlags[9] = 0;			// ALU op
			instFlags[8] = 0;			// ADD forzada
			instFlags[7]	 = 0;
			instFlags[6]= 0;
			instFlags[5] = 0;
			instFlags[4] = 0;
			instFlags[3]= 0;
			instFlags[2] = 0;				// 0->PC, 1->rs1
			instFlags[1]= 0;				//0 -> IMM, 1->rs2	
			instFlags[0] = 1;
			end
		endcase
	end else begin 
		//is invalid 
		instFlags[14]= 0;			
			instFlags[13] = 0;		
			instFlags[12] = 0;
			instFlags[11] = 0;	
			instFlags[10] = 0;
			instFlags[9] = 0;			// ALU op
			instFlags[8] = 0;			// ADD forzada
			instFlags[7]	 = 0;
			instFlags[6]= 0;
			instFlags[5] = 0;
			instFlags[4] = 0;
			instFlags[3]= 0;
			instFlags[2] = 0;				// 0->PC, 1->rs1
			instFlags[1]= 0;				//0 -> IMM, 1->rs2	
			instFlags[0] = 1;
	end	
end
	
	

	

endmodule
