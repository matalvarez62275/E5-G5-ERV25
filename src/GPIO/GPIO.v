module GPIO (
	input wire address,
	input wire [3:0] byte_en,
	input wire [31:0] data,
	input wire read_en,
	input wire clken,
	input wire clk,
	input wire nreset,
	output reg [31:0] q,
	inout wire[7:0] port
);

reg [7:0] PDOR;		// Port Data Output Register
reg [7:0] PSOR;		// Port Set Output Register
reg [7:0] PCOR;		// Port Clear Output Register
reg [7:0] PTOR;		// Port Toggle Output Register
wire [7:0] PDIR;		// Port Data Input Register
reg [7:0] PDDR;		// Port Data Direction Register

genvar i;
generate
	for(i=0; i < 8; i = i+1) begin : generation_block
		alt_iobuf io0 (.i(PDOR[i]), .oe(PDDR[i]), .o(PDIR[i]), .io(port[i]));
		defparam io0.io_standard = "3.3-V LVCMOS";
		defparam io0.current_strength = "minimum current";
	end
endgenerate

always @ (posedge clk or negedge nreset)
begin
	if(!nreset) begin
		PDOR = 0;
		PSOR = 0;
		PCOR = 0;
		PTOR = 0;
		PDDR = 0;
	end
	else if(clken) begin
		if(read_en) begin
			if(address) q <= {16'b0, PDDR, PDIR};
			else q <= {24'b0, PDOR};
		end
		else begin
			if(address) begin
				case(byte_en)
					4'b1111: PDDR <= data[15:8];
					4'b0011: PDDR <= data[15:8];
					4'b0010: PDDR <= data[7:0];
					default: ;
				endcase
			end else begin
				case(byte_en)
				
					4'b1111: begin
						PDOR = data[7:0];
						PSOR = data[15:8];
						PCOR = data[23:16];
						PTOR = data[31:24];
					end
					
					4'b0011: begin
						PDOR = data[7:0];
						PSOR = data[15:8];
					end
					
					4'b1100: begin
						PCOR = data[7:0];
						PTOR = data[15:8];
					end
					
					4'b0001: PDOR = data[7:0];
					4'b0010: PSOR = data[7:0];
					4'b0100: PCOR = data[7:0];
					4'b1000: PTOR = data[7:0];
					default: ;
				endcase
			end
		end
	end
end
endmodule