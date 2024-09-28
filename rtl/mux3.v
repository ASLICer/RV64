module mux3 #(parameter DATA_WIDTH=64)
(
	input wire [DATA_WIDTH-1:0]d0,
	input wire [DATA_WIDTH-1:0]d1,
	input wire [DATA_WIDTH-1:0]d2,
	input wire [1:0]s,
	output wire[DATA_WIDTH-1:0]y
);

assign y=(s==2'b00) ? d0 :
		 (s==2'b01) ? d1 :
		 (s==2'b10) ? d2 : d0;

endmodule
