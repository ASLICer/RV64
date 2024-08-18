module mux_fw_resM#(parameter DATA_WIDTH=64)
(
	input	[DATA_WIDTH-1:0]	d0,
	input	[DATA_WIDTH-1:0]	d1,
	input	[DATA_WIDTH-1:0]	d2,
	input	[DATA_WIDTH-1:0]	d3,

	input	[2:0]	s,
	output	[DATA_WIDTH-1:0]	y
);	

assign	y	=		s[2]	? 	d0	:
					s[1]	?	d1	:
					s[0]	?	d2	:	d3;

endmodule
