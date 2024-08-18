module EX_MEM#(parameter DATA_WIDTH = 64)
(
	input			clk				,
	input			rst_n			,
	input	[DATA_WIDTH-1:0]	i_pc4			,
	input	[DATA_WIDTH-1:0]	i_imme			,
	input	[DATA_WIDTH-1:0]	i_pc_imm		,
	input	[DATA_WIDTH-1:0]	i_aluout		,
	input	[DATA_WIDTH-1:0]	i_wr_mem_data	,
	input	[4:0]	i_Rd			,
	input	[4:0]	i_Rs2			,
	output	[DATA_WIDTH-1:0]	o_pc4			,
	output	[DATA_WIDTH-1:0]	o_imme			,
	output	[DATA_WIDTH-1:0]	o_pc_imm		,	
	output	[DATA_WIDTH-1:0]	o_aluout		,
	output	[DATA_WIDTH-1:0]	o_wr_mem_data	,
	output	[4:0]	o_Rd			,
	output	[4:0]	o_Rs2
);

dff_r #(DATA_WIDTH) r1M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_aluout),
	.q(o_aluout)
);
dff_r #(DATA_WIDTH) r2M(
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

dff_r #(DATA_WIDTH) r4M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_pc4),
	.q(o_pc4)
);
dff_r #(DATA_WIDTH) r5M(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_imme),
	.q(o_imme)
);

dff_r #(DATA_WIDTH) r6M(
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
