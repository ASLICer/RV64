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
`define		Iw_type			7'b0011011
`define		Rw_type			7'b0111011

//alu_control:self define,can change 
`define 	ADD  			5'b0_0001
`define 	SUB  			5'b0_0011
`define 	AND  			5'b0_0100
`define 	OR   			5'b0_0101
`define 	XOR  			5'b0_0110
`define 	SLTU 			5'b0_1000
`define 	SLT  			5'b0_1001
`define 	SLL  			5'b0_1100
`define 	SRL  			5'b0_1101
`define 	SRA  			5'b0_1110

`define 	ADDW  			5'b1_0001
`define 	SUBW  			5'b1_0011
`define 	SLLW  			5'b1_1100
`define 	SRLW  			5'b1_1101
`define 	SRAW  			5'b1_1110

