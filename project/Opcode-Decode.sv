module Opcode-Decode (
   input wire[31:0] inst,
	
	output wire[4:0] rd,
	output wire[4:0] rs1,
	output wire[4:0] rs2,
	output wire[2:0] func_3,
	output wire ALU_flag;

	output reg rd_en,		
	output reg rs1_en,	
	output reg rs2_en,	
	output reg imm_en,	
	output reg ALU_en,
	output reg func3_valid,
	output reg type_B_en,
	output reg type_S_en,
	output reg type_R_en,
	output reg type_I_en;
);

	assign rd = inst[11:7];
	assign rs1 = inst[19:15];
	assign rs2 = inst[24:20];
	assign func_3 = inst[14:12];
	assign ALU_flag = inst[30];
	
	wire[4:0] opcode = inst[6:2];
		
	always @(opcode)
	begin 
		if(opcode == 5'b11011) begin //Tipo J, inst unica JAL
			rd_en = 1;
			rs1_en = 0;
			rs2_en = 0;
			imm_en = 1;
			ALU_en = 0;
			func3_valid = 0;
			type_B_en = 0;
			type_S_en = 0;
			type_R_en = 0;
			type_I_en = 0;
		end else if (opcode == 5'b01101 || opcode == 5'b00101) begin //Tipo U, inst unicas LUI, AUIPC
			rd_en = 1;
			rs1_en = 0;
			rs2_en = 0;
			imm_en = 1;
			ALU_en = 0;
			func3_valid = 0;
			type_B_en = 0;
			type_S_en = 0;
			type_R_en = 0;
			type_I_en = 0;
		end else begin 
		
			case(opcode[6:4]) 
				3'b000: begin 				 //Instruccion LOAD tipo I
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
				
				3'b001: begin			
					if(funct3 == 3'b101 || funct3 == 3'b001 )	begin //Instruccion ALU tipo R
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
				
			end case
		end 	
	end
	
	

	

endmodule
