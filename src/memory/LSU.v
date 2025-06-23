module LSU (
    input [1:0] access_size,
    input write_en,
    input [31:0] rs1,
	 input [31:0] imm,
    input [31:0] data,
    output reg [31:0] mem_addr,
    output reg [31:0] write_data,
    output reg [3:0] byte_en,	 
	 output reg misaligned_flag,
	 output reg misaccess_flag
);

localparam ALIGN_MASK = 32'hFFFFFFFC;
    
wire [31:0] raw_addr;
assign raw_addr = rs1 + imm;

always @(*) begin
	// 4 byte address alignment
	mem_addr = raw_addr & ALIGN_MASK;
       
   byte_en = 4'b0000;
   write_data = 32'b0;
	misaligned_flag = 1'b0;
	misaccess_flag = 1'b0;
   
   case (access_size)
		
		// 8 bits
		2'b00: begin
			case (raw_addr[1:0])
				2'b00: byte_en = 4'b0001;
            2'b01: byte_en = 4'b0010;
            2'b10: byte_en = 4'b0100;
            2'b11: byte_en = 4'b1000;
         endcase
         
			if (write_en) write_data = {4{data[7:0]}};
		end
		
		// 16 bits
      2'b01: begin
			case (raw_addr[1:0])
				2'b00: byte_en = 4'b0011;
				2'b01: byte_en = 4'b0110;
            2'b10: byte_en = 4'b1100;
            default: misaligned_flag = 1'b1;
			endcase
         
			if (write_en) begin
				case (raw_addr[1:0])
					2'b00: write_data = {16'b0, data[15:0]};
					2'b01: write_data = {8'b0, data[15:0], 8'b0};
               2'b10: write_data = {data[15:0], 16'b0};
					default: misaligned_flag = 1'b1;
				endcase
         end
		end
		
		// 32 bits
      2'b10: begin
			if (raw_addr[1:0] == 2'b00) byte_en = 4'b1111;
			else misaligned_flag = 1'b1;
			
         if (write_en) begin
				if (raw_addr[1:0] == 2'b00) write_data = data;
				else misaligned_flag = 1'b1;
			end
      end
            
      default: misaccess_flag = 1'b1;
	endcase
end
endmodule
