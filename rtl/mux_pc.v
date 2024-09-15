module mux_pc(
	input	[31:0]	d0,
	input	[31:0]	d1,
	input	[31:0]	d2,

	input	[1:0]	s,
	output	[31:0]	y
);	

assign	y	=		s[1]	? 	d0	:
					s[0]	?	d1	:	d2;

endmodule
