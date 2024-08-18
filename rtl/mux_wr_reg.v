module mux_wr_reg#(parameter DATA_WIDTH=64)
(
	input	[DATA_WIDTH-1:0]	d0,
	input	[DATA_WIDTH-1:0]	d1,
	input	[DATA_WIDTH-1:0]	d2,
	input	[DATA_WIDTH-1:0]	d3,
	input	[DATA_WIDTH-1:0]	d4,

	input	[3:0]	s,
	output	[DATA_WIDTH-1:0]	y
);	

assign	y	=		s[3]	? 	d0	:
					s[2]	?	d1	:
					s[1]	?	d2	:
					s[0]	?	d3	:	d4;

endmodule
