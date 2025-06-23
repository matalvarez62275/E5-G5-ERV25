module LSU_sign (
    input read_en,
    input sign,
    input [3:0] byte_en,
    input [31:0] read_data,
    input [1:0] access_size,
    output reg [31:0] data,
    output reg misaligned_flag,
    output reg misaccess_flag
);
    
always @(*) begin
	data = 32'b0;
   
   if (read_en) begin
		case (access_size)
			
			// 8 bits
			2'b00: begin
				case (byte_en)
					4'b0001: data = sign ? {{24{read_data[7]}}, read_data[7:0]} : {24'b0, read_data[7:0]};
               4'b0010: data = sign ? {{24{read_data[15]}}, read_data[15:8]} : {24'b0, read_data[15:8]};
               4'b0100: data = sign ? {{24{read_data[23]}}, read_data[23:16]} : {24'b0, read_data[23:16]};
               4'b1000: data = sign ? {{24{read_data[31]}}, read_data[31:24]} : {24'b0, read_data[31:24]};
               default: misaligned_flag = 1'b1;
            endcase
         end
         
			// 16 bits
         2'b01: begin
				case (byte_en)
					4'b0011: data = sign ? {{16{read_data[15]}}, read_data[15:0]} : {16'b0, read_data[15:0]};
					4'b0110: data = sign ? {{16{read_data[23]}}, read_data[23:8]} : {16'b0, read_data[23:8]};
               4'b1100: data = sign ? {{16{read_data[31]}}, read_data[31:16]} : {16'b0, read_data[31:16]};
               default: misaligned_flag = 1'b1;
				endcase
         end
         
			// 32 bits
         2'b10: begin
				if (byte_en == 4'b1111) data = read_data;
            else misaligned_flag = 1'b1;
         end
			
         default: misaccess_flag = 1'b1;
		endcase
	end
end
endmodule
