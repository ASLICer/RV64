module branch_judge(
	input			beq,
	input			bne, 
	input			blt, 
	input			bge, 
	input			bltu, 
	input			bgeu, 
	input			jal,
	input			jalr,
	input	[31:0]	subout, 
	output	[1:0]	pc_sel
);
wire b_jal;

//target address:PC+imme
assign	b_jal	=		(beq	&	~|subout)			|
						(bne	&	|subout)			|
						((blt|bltu)	&	subout[31])		|
						((bge|bgeu)	&	~subout[31])	|
						jal;
assign pc_sel = {b_jal,jalr};
endmodule
