module control#(
    parameter ISSUE_NUM = 4
)(
	input 	wire 			clk,
	input 	wire 			rst_n,

	//decode stage(rf read stage)
		//from datapath
	input 	wire	[6:0] 	opcodeD [ISSUE_NUM-1:0],
	input 	wire	[2:0] 	func3D  [ISSUE_NUM-1:0],
	input 	wire			func7D  [ISSUE_NUM-1:0],

    //execute stage
		//from datapath
	input 	wire 			flushE,
	    //to datapath
        //to  alu
    output  wire 			alusrcE     [1:0];
    output  wire 			alusrc_pcE  [1:0];
    output  wire 	[2:0]	aluopE      [1:0];
    output  wire 	[4:0]	aluctlE     [1:0];
 
        //to  mdu
    output  wire    [3:0]   mductlE,
		
        //to  bru
	output	wire			jalE,
	output	wire			jalrE,
	output	wire			beqE,
	output	wire			bneE,
	output	wire			bltE,
	output	wire			bgeE,
	output	wire			bltuE,
	output	wire			bgeuE,

	//mem stage 
		//to datapath
	output 	wire 			regwriteM,

		//to data_memory
	output 	wire 			memwriteM,
	output 	wire 			memreadM, 
	output	wire 	[2:0]	RW_typeM,

	//write back stage 
		//to datapath
	output 	wire 			regwriteW
);

//decode stage
wire 			alusrcD     [1:0];
wire 			alusrc_pcD  [1:0];
wire 	[2:0]	aluopD      [1:0];
wire 	[4:0]	aluctlD     [1:0];
wire			memwriteD   [1:0];
wire 			memreadD    [1:0];
wire	[2:0]	RW_typeD    [1:0];

//to mdu
wire 	[3:0]	mductlD ;

//to datapath bru
wire			jalD    ;
wire			jalrD   ;
wire			beqD    ;
wire			bneD    ;
wire			bltD    ;
wire			bgeD    ;
wire			bltuD   ;
wire			bgeuD   ;

wire 			regwriteD   [3:0];

//execute stage
wire	[2:0]	RW_typeE;
wire 			memwriteE;
wire 			memreadE;


//pipeline registers
dff_rc #(18) rE(
	.clk(clk),
	.rst_n(rst_n),
	.clear(flushE),
	.d({jalD,jalrD,beqD,bneD,bltD,bgeD,bltuD,bgeuD,mductlD,aluctlD,aluopD,alusrc_pcD,alusrcD,memreadD,memwriteD,RW_typeD,regwriteD}),
	.q({jalE,jalrE,beqE,bneE,bltE,bgeE,bltuE,bgeuE,mductlE,aluctlE,aluopE,alusrc_pcE,alusrcE,memreadE,memwriteE,RW_typeE,regwriteE})
);

dff_r #(11) rM(
	.clk(clk),
	.rst_n(rst_n),
	.d({RW_typeE,memtoregE,memreadE,memwriteE,regwriteE}),
	.q({RW_typeM,memtoregM,memreadM,memwriteM,regwriteM})
);

dff_r #(6) rW(
	.clk(clk),
	.rst_n(rst_n),
	.d({regwriteM}),
	.q({regwriteW})
);


main_control main_control_u0(
	.opcode(opcodeD),
	.func3(func3D),
    //to alu
	.memread(memreadD),
	.memwrite(memwriteD),
    .RW_type(RW_typeD),

    .aluop(aluopD),
    .alusrc_pc(alusrc_pcD),
    .alusrc(alusrcD),

	.jal(jalD),
	.jalr(jalrD),
	.beq(beqD),
	.bne(bneD),
	.blt(bltD),
	.bge(bgeD),
	.bltu(bltuD),
	.bgeu(bgeuD),
	
	.regwrite(regwriteD)	
);

alu_control alu_control_u0(
	.aluop(aluopD[0]),
	.func3(func3D[0]),
	.func7(func7D[0]),
	.aluctl(aluctlD[0])
);
alu_control alu_control_u1(
	.aluop(aluopD[1]),
	.func3(func3D[1]),
	.func7(func7D[1]),
	.aluctl(aluctlD[1])
);
mdu_control mdu_control_u0(
	.opcode(opcodeD[3]),
	.func3(func3D[3]),
	.mductl(mductlD)
);

endmodule
