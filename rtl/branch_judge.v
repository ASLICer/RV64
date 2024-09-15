module branch_judge#(parameter DATA_WIDTH = 64)
(
	input beq,
	input bne, 
	input blt, 
	input bge, 
	input bltu, 
	input bgeu, 
	input jal,
	input jalr,
	input [DATA_WIDTH-1:0] subout, 
	output [1:0] pc_sel
);
wire b_jal;

//target address:PC+imme
assign	b_jal	=		(beq & ~|subout) |
						(bne & |subout)	|
						((blt|bltu)	& subout[DATA_WIDTH-1])	|//bltu/bgeu:4-15,0100+0001=0101,结果是有符号数，如果只有4位，只能表示-8到7，出错了，正确结果-11不在范围内。
						((bge|bgeu)	& ~subout[DATA_WIDTH-1]) |
						jal;
assign pc_sel = {b_jal,jalr};
endmodule
