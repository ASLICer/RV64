module	cla_adder32(
	input	[31:0]	A, 
	input	[31:0]	B, 
	input			cin, 
	output	[31:0]	result, 
	output 			cout		
);

assign {cout,result}	=	A+B+cin;
endmodule
