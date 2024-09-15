module mux_wr_reg(
	input	[31:0]	d0,
	input	[31:0]	d1,
	input	[31:0]	d2,
	input	[31:0]	d3,
	input	[31:0]	d4,

	input	[3:0]	s,
	output	[31:0]	y
);	

assign	y	=		s[3]	? 	d0	:
					s[2]	?	d1	:
					s[1]	?	d2	:
					s[0]	?	d3	:	d4;

endmodule
