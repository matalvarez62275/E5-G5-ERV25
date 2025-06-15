module IFU_NOP_ctrl (
    input  wire clk,
    input  wire nreset,
    input  wire [2:0] instr_JMP,  // Instruction bits [6:4]
    output reg  NOP_en                // Assert to stall IF
);

    reg [1:0] stall_counter;

    wire is_jump_instr;
    assign is_jump_instr = (instr_JMP == 3'b110);  // Detect JAL, JALR, or branch

    always @(posedge clk or negedge nreset) begin
        if (!nreset) begin
            NOP_en <= 0;
            stall_counter <= 0;
        end else begin
            if (stall_counter != 0) begin
                stall_counter <= stall_counter - 1;
                NOP_en <= 1;
            end else if (is_jump_instr) begin
                stall_counter <= 2'd2; // Stall for 3 cycles after a jump
                NOP_en <= 1;
            end else begin
                NOP_en <= 0;
            end
        end
    end

endmodule
