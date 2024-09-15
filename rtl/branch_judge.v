module branch_judge(
	input			beq,
	input			bne, 
	input			blt, 
	input			bge, 
	input			bltu, 
	input			bgeu, 
	input			jal,
	input			jalr,
	input			zero, 
	input	[31:0]	ALU_result, 
	output	[1:0]	jump_sel
);
wire b_jal;

//target address:PC+imme
assign	b_jal	=		(beq	&	zero)			|
						(bne	&	~zero)			|
						((blt|bltu)	&	ALU_result)	|
						((bge|bgeu)	&	~ALU_result)|
						jal;
assign jump_sel = {b_jal,jalr};
endmodule
