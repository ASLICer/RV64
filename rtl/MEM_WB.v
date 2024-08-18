module MEM_WB#(parameter DATA_WIDTH = 64)
(
	input			clk				,
	input			rst_n			,
	input	[DATA_WIDTH-1:0]	i_pc4			,
	input	[DATA_WIDTH-1:0]	i_imme			,
	input	[DATA_WIDTH-1:0]	i_pc_imm		,
	input	[DATA_WIDTH-1:0]	i_aluout		,
	input	[DATA_WIDTH-1:0]	i_readdata		,
	input	[4:0]	i_Rd			,
	output	[DATA_WIDTH-1:0]	o_pc4			,
	output	[DATA_WIDTH-1:0]	o_imme			,
	output	[DATA_WIDTH-1:0]	o_pc_imm		,	
	output	[DATA_WIDTH-1:0]	o_aluout		,
	output	[DATA_WIDTH-1:0]	o_readdata		,
	output	[4:0]	o_Rd	
);

dff_r #(DATA_WIDTH) r1W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_aluout),
	.q(o_aluout)
);
dff_r #(DATA_WIDTH) r2W(
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
dff_r #(DATA_WIDTH) r4W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_pc4),
	.q(o_pc4)
);
dff_r #(DATA_WIDTH) r5W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_imme),
	.q(o_imme)
);

dff_r #(DATA_WIDTH) r6W(
	.clk(clk),
	.rst_n(rst_n),
	.d(i_pc_imm),
	.q(o_pc_imm)
);

endmodule
