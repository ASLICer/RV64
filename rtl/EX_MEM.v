module EX_MEM(
	input			clk				,
	input			rst_n			,
	input	[31:0]	i_pc4			,
	input	[31:0]	i_imme			,
	input	[31:0]	i_pc_imm		,
	input	[31:0]	i_aluout		,
	input	[31:0]	i_wr_mem_data	,
	input	[4:0]	i_Rd			,
	input	[4:0]	i_Rs2			,
	output	[31:0]	o_pc4			,
	output	[31:0]	o_imme			,
	output	[31:0]	o_pc_imm		,	
	output	[31:0]	o_aluout		,
	output	[31:0]	o_wr_mem_data	,
	output	[4:0]	o_Rd			,
	output	[4:0]	o_Rs2
);

dff_r #(32) r1M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_aluout),
	.q(o_aluout)
);
dff_r #(32) r2M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_wr_mem_data),
	.q(o_wr_mem_data)
);
dff_r #(5) r3M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_Rd),
	.q(o_Rd)
);

dff_r #(32) r4M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_pc4),
	.q(o_pc4)
);
dff_r #(32) r5M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_imme),
	.q(o_imme)
);

dff_r #(32) r6M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_pc_imm),
	.q(o_pc_imm)
);
dff_r #(5) r7M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_Rs2),
	.q(o_Rs2)
);
endmodule
