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
	output reg busA_sel,	// 0: PC, 1: rs1
	output reg busB_sel,	// 0: imm, 1: rs2
	output reg ALU_en,
	output reg[1:0] ALU_flag,	// Alu_flag[0]: ALU op, Alu_flag[1]: ADD forzada
	output reg is_JAL,
	output reg is_JALR,
	output reg is_BRANCH
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
			busA_sel = opcode[3];	// 0->PC
			busB_sel = 0;			//0 -> IMM	
		end else begin 
		
			case(opcode[4:2]) 
				3'b000: begin 				 //Instruccion LOAD tipo I
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
				busA_sel = opcode[3];	// 0->PC
				busB_sel = 0;			//0 -> IMM	
				end
				
				3'b001: begin			
					if(func3 == 3'b101 || func3 == 3'b001 )	begin //Instruccion ALU tipo R
					rd_en = 1;
					rs1_en = 1;
					rs2_en = 1;
					imm_en = 0;
					ALU_en = 1;
					func3_valid = 1;
					type_B_en = 0;
					type_S_en = 0;
					type_R_en = 1;
					type_I_en = 0;
					end else begin 		//Instruccion ALU tipo I		
					rd_en = 1;
					rs1_en = 1;
					rs2_en =0;
					imm_en = 1;	
					ALU_en = 1;
					func3_valid = 1;
					type_B_en = 0;
					type_S_en = 0;
					type_R_en = 0;
					type_I_en = 1;
					end
					
				end
				
				3'b011: begin				//Instruccion ALU tipo R
				rd_en = 1;
				rs1_en = 1;
				rs2_en = 1;
				imm_en = 0;
				ALU_en = 1;
				func3_valid = 1;
				type_B_en = 0;
				type_S_en = 0;
				type_R_en = 1;
				type_I_en = 0;
				end
				
				3'b010: begin 				//Instruccion Store tipo S
				rd_en = 0;
				rs1_en = 1;
				rs2_en = 1;
				imm_en = 1;
				ALU_en = 1;
				func3_valid = 1;
				type_B_en = 0;
				type_S_en = 1;
				type_R_en = 0;
				type_I_en = 0;
				end
				
				3'b110: begin 				//Instruccion Branch tipo B
				rd_en = 0;
				rs1_en = 1;
				rs2_en = 1;
				imm_en = 1;
				ALU_en = 1;
				func3_valid = 1;
				type_B_en = 1;
				type_S_en = 0;
				type_R_en = 0;
				type_I_en = 0;
				end
				
				3'b111: begin 				//Instruccion CSR tipo I
				rd_en = 1;
				rs1_en = 1;
				rs2_en = 0;
				imm_en = 1;
				ALU_en = 1;
				func3_valid = 1;
				type_B_en = 0;
				type_S_en = 0;
				type_R_en = 0;
				type_I_en = 1;
				end	
				
			endcase
		end 	
	end
	
	

	

endmodule
