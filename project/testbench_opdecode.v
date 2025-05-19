`timescale 10ns/100ps // timescale / precision

module testbench_opdecode;

//input test - son reg del DUT
reg clk_tb;
reg [31:0]inst_tb;

//output test - son wire del DUT
wire[4:0] rd_tb;
wire[4:0] rs1_tb;
wire[4:0] rs2_tb;
wire[2:0] func3_tb;

wire rd_en_tb;
wire rs1_en_tb;	
wire rs2_en_tb;	
wire imm_en_tb;	
wire busA_sel_tb;	// 0: PC, 1: rs1, de la ALU
wire busB_sel_tb;	// 0: imm, 1: rs2, de la ALU
wire ALU_en_tb;
wire[1:0] ALU_flag_tb;	// Alu_flag[0]: ALU op, Alu_flag[1]: ADD forzada
wire is_JAL_tb;
wire is_JALR_tb;
wire is_BRANCH_tb;
wire read_en_tb;
wire write_en_tb;
wire is_invalid_tb;

wire [32:0] output_bus;

assign output_bus = {
    rd_tb,         
    rs1_tb,        
    rs2_tb,        
    func3_tb,       
    rd_en_tb,      
    rs1_en_tb,     
    rs2_en_tb,     
    imm_en_tb,     
    busA_sel_tb,   
    busB_sel_tb,   
    ALU_en_tb,     
    ALU_flag_tb,  
    is_JAL_tb,     
    is_JALR_tb,    
    is_BRANCH_tb,  
    read_en_tb,    
    write_en_tb,   
    is_invalid_tb  
};


initial 
begin 
clk_tb = 0;
end


parameter periodo = 20; // 10 ns
always 
begin 
	#(periodo/2) clk_tb = !clk_tb;
end

OpcodeDecode OD_test
(
	//input
	.inst(inst_tb),
	.clk(clk_tb),
	
	//output
	.rd(rd_tb),
	.rs1(rs1_tb),
	.rs2(rs2_tb),
	.func3(func3_tb),	
	
	.rd_en(rd_en_tb),
	.rs1_en(rs1_en_tb),
	.rs2_en(rs2_en_tb),
	.imm_en(imm_en_tb),	
	
	.busA_sel(busA_sel_tb),
	.busB_sel(busB_sel_tb),
	.ALU_en(ALU_en_tb),
	.ALU_flag(ALU_flag_tb),
	
	.is_JAL(is_JAL_tb),
	.is_JALR(is_JALR_tb),
	.is_BRANCH(is_BRANCH_tb),

	.read_en(read_en_tb),
	.write_en(write_en_tb),
	.is_invalid(is_invalid_tb)
);


// Memoria de prueba
reg [31:0] inst_mem [0:255];
reg [32:0] exp_mem [0:255];

integer i, num_cases = 7; //numero de casos generado por python 
initial begin
    // Leer archivos de prueba
    $readmemh("../../test_instructions.mem", inst_mem); 		//busca en project/simulation/questa
    $readmemb("../../expected_outputs.mem", exp_mem);

    $display("Comenzando prueba con %0d instrucciones...", num_cases);

    for (i = 0; i < num_cases; i = i + 1) begin

			//@(posedge clk_tb); // Verificar en el flanco descendente      
			inst_tb = inst_mem[i];
        //expected_tb = exp_mem[i];

        @(negedge clk_tb); // Verificar en el flanco descendente

        if (output_bus !== exp_mem[i]) begin
            $display("X Falla en vector %0d:", i);
            $display("   Instruccion: %h", inst_tb);
            $display("   Esperado   : %b", exp_mem[i]);
            $display("   Obtenido   : %b", output_bus);
            $stop;
        end else begin
            $display("Caso %0d OK", i);
        end
    end

    $display("Todas las pruebas completadas correctamente.");
    $stop;
end

endmodule
