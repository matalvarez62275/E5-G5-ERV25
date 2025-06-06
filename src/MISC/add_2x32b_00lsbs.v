module add_2x32b_00lsbs #(
    parameter OUT_WIDTH = 13  // Set default output width
)(
    input  wire [31:0] A,
    input  wire [31:0] B,
    output wire [OUT_WIDTH-1:0] aligned_sum_out
);

    wire [31:0] sum;
    wire [31:0] aligned_sum;

    assign sum = A + B;

    // Align result to 4-byte boundary (clear bits [1:0])
    assign aligned_sum = sum & 32'hFFFFFFFC;

    // Truncate or slice lower OUT_WIDTH bits
    assign aligned_sum_out = aligned_sum[OUT_WIDTH-1:0];

endmodule