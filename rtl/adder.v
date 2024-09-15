module adder#(parameter DATA_WIDTH = 64)
(
	input wire [DATA_WIDTH-1:0]a,
	input wire [DATA_WIDTH-1:0]b,
	output wire[DATA_WIDTH-1:0]y
);

assign y=a+b;
endmodule
