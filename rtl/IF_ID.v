module IF_ID#(parameter DATA_WIDTH = 64)
(
	input			clk				,
	input			rst_n			,
	input			en				,
	input			clear			,
	input	[DATA_WIDTH-1:0]	i_pc			,	
	input	[DATA_WIDTH-1:0]	i_pc4			,
	input	[31:0]	i_instr			,
	output	[DATA_WIDTH-1:0]	o_pc			,
	output	[DATA_WIDTH-1:0]	o_pc4			,
	output	[31:0]	o_instr
);
dff_enrc #(DATA_WIDTH) r1D(
			.clk	(clk)		,
			.rst_n	(rst_n)		,
			.en		(en)		,
			.clear	(clear)		,
			.d		(i_pc)		,
			.q		(o_pc)
);

dff_enrc #(DATA_WIDTH) r2D(
			.clk	(clk)		,
			.rst_n	(rst_n)		,
			.en		(en)		,
			.clear	(clear)		,
			.d		(i_pc4)		,
			.q		(o_pc4)
);
dff_enrc #(32) r3D(
			.clk	(clk)		,
			.rst_n	(rst_n)		,
			.en		(en)		,
			.clear	(clear)		,
			.d		(i_instr)	,
			.q		(o_instr)
);

endmodule
