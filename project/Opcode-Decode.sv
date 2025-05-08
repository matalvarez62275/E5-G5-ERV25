module OpcodeDecode (
   input wire[31:0] inst,
	
	output wire[4:0] rd,
	output wire[4:0] rs1,
	output wire[4:0] rs2,
	output wire[2:0] func3,

	output reg rd_en,		
	output reg rs1_en,	
	output reg rs2_en,	
	output reg imm_en,	
	output reg busA_sel,	// 0: PC, 1: rs1, de la ALU
	output reg busB_sel,	// 0: imm, 1: rs2, de la ALU
	output reg ALU_en,
	output reg[1:0] ALU_flag,	// Alu_flag[0]: ALU op, Alu_flag[1]: ADD forzada
	output reg is_JAL,
	output reg is_JALR,
	output reg is_BRANCH
	output reg read_en,
	output reg write_en
	
);

	assign rd = inst[11:7];
	assign rs1 = inst[19:15];
	assign rs2 = inst[24:20];
	assign func3 = inst[14:12];
	assign ALU_flag[0] = inst[30];
	
	wire[4:0] opcode = inst[6:2];
		
	always @(*)
	begin 
		if(opcode == 5'b11011) begin //Tipo J, inst unica JAL
			rd_en = 0;
			rs1_en = 0;
			rs2_en = 0;
			imm_en = 1;
			ALU_en = 0;
			ALU_flag[0] = 0;	// ALU op
			ALU_flag[1] = 1;	// ADD forzada
			is_JAL = 1;
			is_JALR = 0;
			is_BRANCH = 0;
			read_en = 0;
			write_en = 0;
			busA_sel = 0;	//0->PC
			busB_sel = 1;	//1->rs2 en disable -> 0x00000000	

		end else if (opcode == 5'b01101 || opcode == 5'b00101) begin //Tipo U, inst unicas LUI, AUIPC
			rd_en = 1;
			rs1_en = 0;
			rs2_en = 0;
			imm_en = 1;
			ALU_en = 1;
			ALU_flag[0] = 0;	// ALU op
			ALU_flag[1] = 1;	// ADD forzada
			is_JAL = 0;
			is_JALR = 0;
			is_BRANCH = 0;
			read_en = 0;
			write_en = 0;	
			busA_sel = opcode[3];	// 0->PC
			busB_sel = 0;			//0 -> IMM	
		end else if (opcode == 5'b11001) begin // JALR tipo I
			rd_en = 0;			
			rs1_en = 1;		
			rs2_en = 0;
			imm_en = 1;
			ALU_en = 1;
			ALU_flag[0] = 0;			// ALU op
			ALU_flag[1] = 1;			// ADD forzada
			is_JAL = 0;
			is_JALR = 1;
			is_BRANCH = 0;
			read_en = 0;
			write_en = 0;
			busA_sel = 0;				// 0->PC, 1->rs1
			busB_sel = 1;				//0 -> IMM, 1->rs2	

		end else begin 
		
			case(opcode[4:2]) 
				3'b000: begin 				 //Instruccion LOAD tipo I
				rd_en = 1;			//rd enable ? o es interno del manejo de memoria?
				rs1_en = 1;			//enable necesario?
				rs2_en = 0;
				imm_en = 1;			//enable necesario?
				ALU_en = 0;
				ALU_flag[0] = 0;	// ALU op
				ALU_flag[1] = 0;	// ADD forzada
				is_JAL = 0;
				is_JALR = 0;
				is_BRANCH = 0;
				read_en = 1;
				write_en = 0;
				busA_sel = 0;	// 0->PC
				busB_sel = 0;	//0 -> IMM	
				end
				
				3'b001,3'b011: begin	//Operaciones de la ALU.		
					rd_en = 1;			
					rs1_en = 1;		
					rs2_en = opcode[3];
					imm_en = !opcode[3];	
					ALU_en = 1;
					ALU_flag[0] = inst[30];	// ALU op
					ALU_flag[1] = 0;			// ADD forzada
					is_JAL = 0;
					is_JALR = 0;
					is_BRANCH = 0;
					read_en = 0;
					write_en = 0;
					busA_sel = 1;				// 0->PC, 1->rs1
					busB_sel = opcode[3];	//0 -> IMM, 1->rs2	
					
				end
				
				3'b010: begin 				//Instruccion Store tipo S
					rd_en = 1;			//rd enable ? o es interno del manejo de memoria?
					rs1_en = 1;			//enable necesario?
					rs2_en = 1;			//salen datos
					imm_en = 1;			//enable necesario?
					ALU_en = 0;
					ALU_flag[0] = 0;	// ALU op
					ALU_flag[1] = 0;	// ADD forzada
					is_JAL = 0;
					is_JALR = 0;
					is_BRANCH = 0;
					read_en = 0;
					write_en = 1;
					busA_sel = 0;	// 0->PC
					busB_sel = 0;	//0 -> IMM	
					
				end
				
				3'b110: begin 				//Instruccion Branch tipo B 
					rd_en = 0;			
					rs1_en = 1;		
					rs2_en = 1;
					imm_en = 1;	
					ALU_en = 1;
					ALU_flag[0] = 0;			// ALU op
					ALU_flag[1] = 0;			// ADD forzada
					is_JAL = 0;
					is_JALR = 0;
					is_BRANCH = 1;
					read_en = 0;
					write_en = 0;
					busA_sel = 1;				// 0->PC, 1->rs1
					busB_sel = 1;				//0 -> IMM, 1->rs2	
					
				end
				
				3'b111: begin 				//Instruccion CSR tipo I. TO DO
					rd_en = 0;			
					rs1_en = 0;		
					rs2_en = 0;
					imm_en = 0;	
					ALU_en = 0;
					ALU_flag[0] = 0;			// ALU op
					ALU_flag[1] = 0;			// ADD forzada
					is_JAL = 0;
					is_JALR = 0;
					is_BRANCH = 0;
					read_en = 0;
					write_en = 0;
					busA_sel = 0;				// 0->PC, 1->rs1
					busB_sel = 0;				//0 -> IMM, 1->rs2	
					
				end	
				
			endcase
		end 	
	end
	
	

	

endmodule
