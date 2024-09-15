module ID_EX(
	input			clk				,
	input			rst_n			,
	input			clear			,
	input	[31:0]	i_pc4			,
	input	[4:0]	i_Rs1			,
	input	[4:0]	i_Rs2			,
	input	[4:0]	i_Rd			,
	input	[31:0]	i_imme			,
	input	[31:0]	i_pc_imm		,
	input	[31:0]	i_srca			,
	input	[31:0]	i_scrb			,
	output	[31:0]	o_pc4			,
	output	[4:0]	o_Rs1			,
	output	[4:0]	o_Rs2			,
	output	[4:0]	o_Rd			,
	output	[31:0]	o_imme			,
	output	[31:0]	o_pc_imm		,	
	output	[31:0]	o_srca			,
	output	[31:0]	o_scrb			
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
dff_rc #(32) r4E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_imme),
	.q(o_imme)
);
dff_rc #(32) r5E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_srca),
	.q(o_srca)
);
dff_rc #(32) r6E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_scrb),
	.q(o_scrb)
);
dff_rc #(32) r7E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_pc4),
	.q(o_pc4)
);
dff_rc #(32) r8E(
	.clk(clk),
	.rst_n(rst_n),
	.clear(clear),
	.d(i_pc_imm),
	.q(o_pc_imm)
);


endmodule

