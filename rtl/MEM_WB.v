module MEM_WB(
	input			clk				,
	input			rst_n			,
	input	[31:0]	i_pc4			,
	input	[31:0]	i_imme			,
	input	[31:0]	i_pc_imm		,
	input	[31:0]	i_aluout		,
	input	[31:0]	i_readdata		,
	input	[4:0]	i_Rd			,
	output	[31:0]	o_pc4			,
	output	[31:0]	o_imme			,
	output	[31:0]	o_pc_imm		,	
	output	[31:0]	o_aluout		,
	output	[31:0]	o_readdata		,
	output	[4:0]	o_Rd	
);

dff_r #(32) r1W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_aluout),
	.q(o_aluout)
);
dff_r #(32) r2W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_readdata),
	.q(o_readdata)
);
dff_r #(5) r3W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_Rd),
	.q(o_Rd)
);
dff_r #(32) r4W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_pc4),
	.q(o_pc4)
);
dff_r #(32) r5W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_imme),
	.q(o_imme)
);

dff_r #(32) r6W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_pc_imm),
	.q(o_pc_imm)
);

endmodule
