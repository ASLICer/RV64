module mux3(
	input	[31:0]	data1,
	input	[31:0]	data2,
	input	[31:0]	data3,

	input	[1:0]	sel,
	output	[31:0]	dout
);	

assign	dout	=	sel[1]	? 	data1	:
					sel[0]	?	data2	:	data3;

endmodule
