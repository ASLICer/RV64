module mux5(
	input	[31:0]	data1,
	input	[31:0]	data2,
	input	[31:0]	data3,
	input	[31:0]	data4,
	input	[31:0]	data5,

	input	[3:0]	sel,
	output	[31:0]	dout
);	

assign	dout	=	sel[3]	? 	data1	:
					sel[2]	?	data2	:
					sel[1]	?	data3	:
					sel[0]	?	data4	:	data5;

endmodule
