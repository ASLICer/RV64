module mux2 #(parameter DATA_WIDTH=64)
(
	input wire [DATA_WIDTH-1:0]d0,
	input wire [DATA_WIDTH-1:0]d1,
	input wire s,
	output wire[DATA_WIDTH-1:0]y
);

assign y=s ? d1 : d0;

endmodule

