`timescale 10ns/100ps // timescale / precision

module testbench_imm;

reg [31:0] inst_tb;
reg clk_tb;
wire [31:0] imm_tb;

immBuilder DUT_IMM (
    .inst(inst_tb),
	 .clk(clk_tb),
    .imm(imm_tb)
);

reg [31:0] instr_mem [0:255];
reg [31:0] expected_mem [0:255];

initial 
begin 
clk_tb = 0;
end


parameter periodo = 20; // 10 ns
always 
begin 
	#(periodo/2) clk_tb = !clk_tb;
end

integer i, num_cases = 7;

initial begin
    $readmemh("../../imm_test.mem", instr_mem);				//busca en project/simulation/questa
    $readmemh("../../imm_expected.mem", expected_mem);	//busca en project/simulation/questa
    
    $display("== Iniciando test IMM Builder ==");

    for (i = 0; i < num_cases; i = i + 1) begin
        inst_tb = instr_mem[i];
        @(negedge clk_tb); 
        
        if (imm_tb !== expected_mem[i]) begin
            $display("	Error en vector %0d:", i);
            $display("  Instruccion: %h", instr_mem[i]);
            $display("  Esperado   : %h", expected_mem[i]);
            $display("  Obtenido   : %h", imm_tb);
            $stop;
         end else begin
            $display("Caso %0d OK", i);
        end
    end

    $display("Todos los casos pasaron correctamente.");
    $stop;
end

endmodule
