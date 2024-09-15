`define		zero_word		32'b0

//opcode:RISC-V define,can't change 
`define		lui				7'b0110111
`define		auipc			7'b0010111
`define		jal				7'b1101111
`define		jalr			7'b1100111
`define		B_type			7'b1100011
`define		load			7'b0000011
`define		store			7'b0100011
`define		I_type			7'b0010011
`define		R_type			7'b0110011

//alu_control:self define,can change 
`define 	ADD  			4'b0001
`define 	SUB  			4'b0011
`define 	AND  			4'b0100
`define 	OR   			4'b0101
`define 	XOR  			4'b0110
`define 	SLTU 			4'b1000
`define 	SLT  			4'b1001
`define 	SLL  			4'b1100
`define 	SRL  			4'b1101
`define 	SRA  			4'b1110
