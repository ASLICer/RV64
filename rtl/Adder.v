module Adder#(parameter DATA_WIDTH=64)
(
	input	[DATA_WIDTH-1:0]	A,
    input	[DATA_WIDTH-1:0]	B,
	input 			Cin,
	input	[4:0]	ALU_CTL,
	output 			ADD_carry,
	output 			ADD_OverFlow,
	output 			ADD_zero,
	output	[DATA_WIDTH-1:0] 	ADD_result
);


assign {ADD_carry,ADD_result}=A+B+Cin;
assign ADD_zero 	=	~(|ADD_result);
assign ADD_OverFlow	=	((ALU_CTL==`ADD) & ~A[DATA_WIDTH-1]& ~B[DATA_WIDTH-1]& ADD_result[DATA_WIDTH-1]) 
                      | ((ALU_CTL==`ADD) & A[DATA_WIDTH-1] & B[DATA_WIDTH-1] & ~ADD_result[DATA_WIDTH-1])
                      | ((ALU_CTL==`SUB) & A[DATA_WIDTH-1] & ~B[DATA_WIDTH-1]& ~ADD_result[DATA_WIDTH-1]) 
					  | ((ALU_CTL==`SUB) & ~A[DATA_WIDTH-1]& B[DATA_WIDTH-1] & ADD_result[DATA_WIDTH-1]);
endmodule
