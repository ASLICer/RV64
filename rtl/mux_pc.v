module mux_pc#(parameter DATA_WIDTH=64)
(
	input	[DATA_WIDTH-1:0]	d0,
	input	[DATA_WIDTH-1:0]	d1,
	input	[DATA_WIDTH-1:0]	d2,

	input	[1:0]	s,
	output	[DATA_WIDTH-1:0]	y
);	

assign	y	=		s[1]	? 	d0	:
					s[0]	?	d1	:	d2;

endmodule
