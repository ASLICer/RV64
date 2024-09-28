module datapath#(parameter DATA_WIDTH=64)
(
	input	wire clk,
	input 	wire rst_n,
	//fetch stage
		//to instr_memory
	output 	wire	[DATA_WIDTH-1:0]	pcF,
		//from instr_memory
	input  	wire 	[31:0]	instrF,

	//decode stage 
		//from controler
	input	wire			jalD,
	input	wire			jalrD,
	input	wire			luiD,
	input	wire			auipcD,
	input	wire			beqD,
	input	wire			bneD,
	input	wire			bltD,
	input	wire			bgeD,
	input	wire			bltuD,
	input	wire			bgeuD,
	input	wire			memwriteD,
		//to controler
	output 	wire	[6:0] 	opcodeD,
	output 	wire	[2:0] 	func3D,
	output 	wire			func7D,

	//execute stage
		//from controler
	input  	wire 			memtoregE,
	input  	wire 			alusrcE,
	input  	wire 			regwriteE,
	input  	wire 	[4:0]	aluctlE,
		//to controler
	output 	wire 			flushE,

	//mem stage
		//from controler
	input  	wire 			memtoregM,
	input  	wire 			regwriteM,
	input	wire			memwriteM,
	input	wire			memreadM,
	input	wire			luiM,
	input	wire			auipcM,
	input	wire			jalM,
	input	wire			jalrM,
		//to data_memory
	output 	wire 	[DATA_WIDTH-1:0]	aluoutM,
	output 	wire 	[DATA_WIDTH-1:0]	Wr_mem_dataM,
		//from data_memory
	input  	wire 	[DATA_WIDTH-1:0]	readdataM,
	
	//writeback stage 
		//from controler
	input	wire			luiW,
	input	wire			auipcW,
	input	wire			jalW,
	input	wire			jalrW,
	input  	wire 			memtoregW,
	input  	wire 			regwriteW
);
//fetch stage
wire 			stallF;
wire 	[DATA_WIDTH-1:0]	pc4F;
wire	[DATA_WIDTH-1:0]	pc_new;
//decode stage
wire 	[DATA_WIDTH-1:0]	pcD;
wire 	[DATA_WIDTH-1:0]	pc4D;
wire 	[DATA_WIDTH-1:0]	immD;
wire 	[DATA_WIDTH-1:0]	pc_immD;
wire 	[DATA_WIDTH-1:0]	pc_jalrD;
wire 	[1:0]	pc_selD;
wire 	[31:0]	instrD;
wire 			stallD;
wire			branchD;
wire 	[1:0]	forwardaD;
wire 	[1:0]	forwardbD;
wire 	[4:0]	Rs1D;
wire 	[4:0]	Rs2D;
wire 	[4:0]	RdD;
wire 	[DATA_WIDTH-1:0]	srcaD;
wire 	[DATA_WIDTH-1:0]	srca2D;
wire 	[DATA_WIDTH-1:0]	srcbD;
wire 	[DATA_WIDTH-1:0]	srcb2D;
wire 	[DATA_WIDTH-1:0]	suboutD;
//execute stage
wire 	[DATA_WIDTH-1:0]	pc4E;
wire 	[DATA_WIDTH-1:0]	immE;
wire 	[DATA_WIDTH-1:0]	pc_immE;
wire 	[1:0]	forwardaE;
wire 	[1:0]	forwardbE;
wire 	[4:0]	Rs1E;
wire 	[4:0]	Rs2E;
wire 	[4:0]	RdE;
wire 	[DATA_WIDTH-1:0]	srcaE;
wire 	[DATA_WIDTH-1:0]	srca2E;
wire 	[DATA_WIDTH-1:0]	srcbE;
wire 	[DATA_WIDTH-1:0]	srcb2E;
wire 	[DATA_WIDTH-1:0]	srcb3E;
wire 	[DATA_WIDTH-1:0]	aluoutE;
//mem stage 
wire 	[DATA_WIDTH-1:0]	pc4M;
wire 	[DATA_WIDTH-1:0]	immM;
wire 	[DATA_WIDTH-1:0]	pc_immM;
wire 	[4:0]	Rs2M;
wire 	[DATA_WIDTH-1:0]	srcb2M;
wire 	[4:0]	RdM;
wire	[DATA_WIDTH-1:0]	forward_resM;
wire	[2:0]	forward_res_selM;
//writeback stage
wire 	[4:0]	RdW;
wire 	[DATA_WIDTH-1:0]	pc4W;
wire 	[DATA_WIDTH-1:0]	immW;
wire 	[DATA_WIDTH-1:0]	pc_immW;
wire 	[DATA_WIDTH-1:0]	aluoutW;
wire 	[DATA_WIDTH-1:0]	readdataW;
wire	[3:0]	Wr_reg_selW;
wire 	[DATA_WIDTH-1:0]	resultW;


assign	branchD=beqD|bneD|bltD|bltuD|bgeD|bgeuD;
//hazard detection
hazard h(
	//fetch stage
	.stallF(stallF),
	//decode stage
	.Rs1D(Rs1D),
	.Rs2D(Rs2D),
	.branchD(branchD),
	.jalD(jalD),
	.jalrD(jalrD),
	.luiD(luiD),
	.memwriteD(memwriteD),
	.auipcD(auipcD),
	.forwardaD(forwardaD),
	.forwardbD(forwardbD),
	.stallD(stallD),
	//execute stage
	.Rs1E(Rs1E),
	.Rs2E(Rs2E),
	.RdE(RdE),
	.regwriteE(regwriteE),
	.memtoregE(memtoregE),
	.forwardaE(forwardaE),
	.forwardbE(forwardbE),
	.flushE(flushE),
	//mem stage
	.Rs2M(Rs2M),
	.RdM(RdM),
	.regwriteM(regwriteM),
	.memtoregM(memtoregM),
	.memwriteM(memwriteM),
	.memreadM(memreadM),
	.forwardM(forwardM),
	//write back stage
	.RdW(RdW),
	.regwriteW(regwriteW)
);

//next PC logic  
mux_pc #(.DATA_WIDTH(DATA_WIDTH))
mux_pc_u0 (
	.d0(pc_immD), 
	.d1(pc_jalrD),
	.d2(pc4F),
	.s(pc_selD), 
	.y(pc_new)
);


 
pc_reg  #(.DATA_WIDTH(DATA_WIDTH))
pc_reg_u0(
	 .clk(clk),
	 .rst_n(rst_n),
	 .en(~stallF),
	 .pc_new(pc_new),
	 .pc_out(pcF)
);
//fetch stage
adder #(.DATA_WIDTH(DATA_WIDTH))
add_pc4(
	.a(pcF),
	.b({{(DATA_WIDTH-3){1'b0}},3'b100}),
	.y(pc4F)
);


IF_ID #(.DATA_WIDTH(DATA_WIDTH))
IF_ID_u0(
		.clk		(clk)			,
		.rst_n		(rst_n)			,
		.en			(~stallD)		,
		.clear		(|pc_selD)		,
		.i_pc		(pcF)			,
		.i_pc4		(pc4F)			,
		.i_instr	(instrF)		,
		.o_pc		(pcD)			,
		.o_pc4		(pc4D)			,
		.o_instr	(instrD)
);
//decode stage
instr_decode #(.DATA_WIDTH(DATA_WIDTH))
instr_decode_u0 (
		.instr		(instrD)		, 
		.opcode		(opcodeD)		, 
		.func3		(func3D)		, 
		.func7		(func7D)		, 
		.Rs1		(Rs1D)			, 
		.Rs2		(Rs2D)			, 
		.Rd			(RdD)			, 
		.imme		(immD)
);

//registers (operates in decode and write stage)
registers #(.DATA_WIDTH(DATA_WIDTH))
registers_u0 (
		.clk(clk),
		.rst_n(rst_n),
		.W_en(regwriteW), 
		.Rs1(Rs1D), 
		.Rs2(Rs2D), 
		.Rd(RdW), 
		.Wr_data(resultW), 
		.Rd_data1(srcaD), 
		.Rd_data2(srcbD)
);
adder #(.DATA_WIDTH(DATA_WIDTH))
add_pc_imm(
		.a(immD),
		.b(pcD),
		.y(pc_immD)
);
adder #(.DATA_WIDTH(DATA_WIDTH))
add_pc_jalr(
		.a(srca2D),
		.b(immD),
		.y(pc_jalrD)
);
mux3 #(.DATA_WIDTH(DATA_WIDTH))
forwardamux(
	.d0(srcaD),
	.d1(resultW),
	.d2(forward_resM),
	.s(forwardaD),
	.y(srca2D)
);
mux3 #(.DATA_WIDTH(DATA_WIDTH))
forwardbmux(
	.d0(srcbD),
	.d1(resultW),
	.d2(forward_resM),
	.s(forwardbD),
	.y(srcb2D)
);

adder #(.DATA_WIDTH(DATA_WIDTH))
sub_branch_u0(
	.a(srca2D),
	.b(~srcb2D+1),
	.y(suboutD)
);
branch_judge #(.DATA_WIDTH(DATA_WIDTH))
branch_judge_u0 (
	.beq(beqD), 
	.bne(bneD), 
	.blt(bltD), 
	.bge(bgeD), 
	.bltu(bltuD), 
	.bgeu(bgeuD), 
	.jal(jalD),
	.jalr(jalrD),
	.subout(suboutD), 
	.pc_sel(pc_selD)
);

ID_EX #(.DATA_WIDTH(DATA_WIDTH))
ID_EX_u0(
	.clk	(clk)		,
	.rst_n	(rst_n)		,
	.clear	(flushE)	,
	.i_pc4	(pc4D)		,
	.i_Rs1	(Rs1D)		,
	.i_Rs2	(Rs2D)		,
	.i_Rd	(RdD)		,
	.i_imme	(immD)		,
	.i_pc_imm(pc_immD)	,
	.i_srca	(srcaD)		,
	.i_scrb	(srcbD)		,
	.o_pc4	(pc4E)		,
	.o_Rs1	(Rs1E)		,
	.o_Rs2	(Rs2E)		,
	.o_Rd	(RdE)		,
	.o_imme	(immE)		,
	.o_pc_imm(pc_immE)	,
	.o_srca	(srcaE)		,
	.o_scrb	(srcbE)		
);

//execute stage
mux3 #(.DATA_WIDTH(DATA_WIDTH))
forwardaemux(
	.d0(srcaE),
	.d1(resultW),
	.d2(forward_resM),
	.s(forwardaE),
	.y(srca2E)
);
mux3 #(.DATA_WIDTH(DATA_WIDTH))
forwardbemux(
	.d0(srcbE),
	.d1(resultW),
	.d2(forward_resM),
	.s(forwardbE),
	.y(srcb2E)
);
mux2 #(.DATA_WIDTH(DATA_WIDTH))
srcbmux(
	.d0(srcb2E),
	.d1(immE),
	.s(alusrcE),
	.y(srcb3E)
);
alu #(.DATA_WIDTH(DATA_WIDTH))
alu_inst 
(
	.ALU_DA(srca2E), 
	.ALU_DB(srcb3E), 
	.ALU_CTL(aluctlE), 
	.ALU_ZERO(), 
	.ALU_OverFlow(), 
	.ALU_DC(aluoutE)
);


 EX_MEM #(.DATA_WIDTH(DATA_WIDTH))
 EX_MEM_u0(
	.clk			(clk),				
	.rst_n			(rst_n),
	.i_pc4			(pc4E),
	.i_imme			(immE),
	.i_pc_imm		(pc_immE),
	.i_aluout		(aluoutE),
	.i_wr_mem_data	(srcb2E),
	.i_Rd			(RdE),
	.i_Rs2			(Rs2E),
	.o_pc4			(pc4M),
	.o_imme			(immM),
	.o_pc_imm		(pc_immM),
	.o_aluout		(aluoutM),
	.o_wr_mem_data	(srcb2M),
	.o_Rd			(RdM),
	.o_Rs2			(Rs2M)
);

assign forward_res_selM={jalM|jalrM,luiM,auipcM};
mux_fw_resM #(.DATA_WIDTH(DATA_WIDTH))
mux_fw_resM_u0(
	.d0		(pc4M),
	.d1		(immM),
	.d2		(pc_immM),
	.d3		(aluoutM),
	.s		(forward_res_selM),
	.y		(forward_resM)
);	

mux2 #(.DATA_WIDTH(DATA_WIDTH))
wr_mem_data_mux(
	.d0(srcb2M),
	.d1(resultW),
	.s(forwardM),
	.y(Wr_mem_dataM)
);

MEM_WB #(.DATA_WIDTH(DATA_WIDTH))
MEM_WB_u0(
	.clk			(clk),
	.rst_n			(rst_n),
	.i_pc4			(pc4M),
	.i_imme			(immM),
	.i_pc_imm		(pc_immM),
	.i_aluout		(aluoutM),
	.i_readdata		(readdataM),
	.i_Rd			(RdM),
	.o_pc4			(pc4W),
	.o_imme			(immW),
	.o_pc_imm		(pc_immW),
	.o_aluout		(aluoutW),
	.o_readdata		(readdataW),
	.o_Rd			(RdW)
);

//write back stage
assign Wr_reg_selW={memtoregW,jalW|jalrW,luiW,auipcW};
mux_wr_reg #(.DATA_WIDTH(DATA_WIDTH))
mux_wr_reg_u0(
	.d0		(readdataW),
	.d1		(pc4W),
	.d2		(immW),
	.d3		(pc_immW),
	.d4		(aluoutW),
	.s		(Wr_reg_selW),
	.y		(resultW)
);	

endmodule

