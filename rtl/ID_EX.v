module ID_EX#(parameter DATA_WIDTH = 64)
(
	input			clk				,
	input			rst_n			,
	input			clear			,
	input	[DATA_WIDTH-1:0]	i_pc4			,
	input	[4:0]	i_Rs1			,
	input	[4:0]	i_Rs2			,
	input	[4:0]	i_Rd			,
	input	[DATA_WIDTH-1:0]	i_imme			,
	input	[DATA_WIDTH-1:0]	i_pc_imm		,
	input	[DATA_WIDTH-1:0]	i_srca			,
	input	[DATA_WIDTH-1:0]	i_scrb			,
	output	[DATA_WIDTH-1:0]	o_pc4			,
	output	[4:0]	o_Rs1			,
	output	[4:0]	o_Rs2			,
	output	[4:0]	o_Rd			,
	output	[DATA_WIDTH-1:0]	o_imme			,
	output	[DATA_WIDTH-1:0]	o_pc_imm		,	
	output	[DATA_WIDTH-1:0]	o_srca			,
	output	[DATA_WIDTH-1:0]	o_scrb			
);

dff_rc #(5) r1E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_Rs1),
	.q(o_Rs1)
);
dff_rc #(5) r2E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_Rs2),
	.q(o_Rs2)
);
dff_rc #(5) r3E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_Rd),
	.q(o_Rd)
);
dff_rc #(DATA_WIDTH) r4E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_imme),
	.q(o_imme)
);
dff_rc #(DATA_WIDTH) r5E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_srca),
	.q(o_srca)
);
dff_rc #(DATA_WIDTH) r6E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_scrb),
	.q(o_scrb)
);
dff_rc #(DATA_WIDTH) r7E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_pc4),
	.q(o_pc4)
);
dff_rc #(DATA_WIDTH) r8E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_pc_imm),
	.q(o_pc_imm)
);


endmodule

