module mux_fw_resM(
	input	[31:0]	d0,
	input	[31:0]	d1,
	input	[31:0]	d2,
	input	[31:0]	d3,

	input	[2:0]	s,
	output	[31:0]	y
);	

assign	y	=		s[2]	? 	d0	:
					s[1]	?	d1	:
					s[0]	?	d2	:	d3;

endmodule
