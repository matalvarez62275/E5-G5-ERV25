// -----------------------------------------------------------------------------
// Module: add32b_align4by_truncate
// Description: This module performs a 32-bit addition of two inputs, aligns the
//              result to a 4-byte boundary by clearing the two least significant
//              bits, and outputs a truncated version of the aligned result.
// Parameters:
//   - OUT_WIDTH: Width of the output signal (default is 13 bits).
// -----------------------------------------------------------------------------
module add32b_align4by_truncate #(
   parameter OUT_WIDTH = 13
)(
   input  wire [31:0] A,
   input  wire [31:0] B,
   output wire [OUT_WIDTH-1:0] aligned_sum_out
);
   wire [31:0] sum;
   wire [31:0] aligned_sum;

   assign sum = A + B;

	// Align result to 4-byte boundary by clearing the 2 lowest order bits and
	// ensure an address multiple of 4.
   assign aligned_sum = sum & 32'hFFFFFFFC;
   assign aligned_sum_out = aligned_sum[OUT_WIDTH-1:0];

endmodule