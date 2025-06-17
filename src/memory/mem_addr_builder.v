module mem_addr_builder (
   input  wire [31:0] rs1,
   input  wire [31:0] imm,
	output wire [31:0] mem_addr
);
   wire [31:0] sum;
   assign sum = rs1 + imm;

	// Align result to 4-byte boundary by clearing the 2 lowest order bits and
	// ensure an address multiple of 4.
   assign mem_addr = sum & 32'hFFFFFFFC;
endmodule