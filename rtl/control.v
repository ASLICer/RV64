module control(
	input 	wire 			clk,
	input 	wire 			rst_n,

	//decode stage
		//from datapath
	input 	wire	[6:0] 	opcodeD,
	input 	wire	[2:0] 	func3D,
	input 	wire			func7D,
		//to datapath
	output	wire			jalD,
	output	wire			jalrD,
	output	wire			luiD,
	output	wire			auipcD,
	output	wire			beqD,
	output	wire			bneD,
	output	wire			bltD,
	output	wire			bgeD,
	output	wire			bltuD,
	output	wire			bgeuD,
	output	wire			memwriteD,

	//execute stage
		//from datapath
	input 	wire 			flushE,
		//to datapath
	output 	wire 			memtoregE,
	output	wire 			regwriteE,
	output 	wire 			alusrcE,
	output 	wire 	[3:0]	aluctlE,

	//mem stage 
		//to datapath
	output 	wire 			regwriteM,
	output	wire 			memtoregM,
	output	wire			luiM,
	output	wire			auipcM,
	output	wire			jalM,
	output	wire			jalrM,
		//to data_memory
	output 	wire 			memwriteM,
	output 	wire 			memreadM, 
	output	wire 	[2:0]	RW_typeM,

	//write back stage 
		//to datapath
	output 	wire 			memtoregW,
	output 	wire 			regwriteW,
	output	wire			luiW,
	output	wire			auipcW,
	output	wire			jalW,
	output 	wire			jalrW
);

//decode stage
wire	[2:0]	RW_typeD;
wire 	[1:0]	aluopD;
wire 	[3:0]	aluctlD;
wire 			memtoregD;
wire 			memreadD;
wire 			alusrcD;
wire 			regwriteD;

//execute stage
wire			jalE;
wire			jalrE;
wire			luiE;
wire			auipcE;
wire	[2:0]	RW_typeE;
wire 			memwriteE;
wire 			memreadE;


//pipeline registers
dff_rc #(17) rE(
	.clk(clk),
	.rst_n(rst_n),
	.clear(flushE),
	.d({jalD,jalrD,luiD,auipcD,RW_typeD,aluctlD,memtoregD,memreadD,memwriteD,regwriteD,alusrcD,regwriteD}),
	.q({jalE,jalrE,luiE,auipcE,RW_typeE,aluctlE,memtoregE,memreadE,memwriteE,regwriteE,alusrcE,regwriteE})
);

dff_r #(11) rM(
	.clk(clk),
	.rst_n(rst_n),
	.d({jalE,jalrE,luiE,auipcE,RW_typeE,memtoregE,memreadE,memwriteE,regwriteE}),
	.q({jalM,jalrM,luiM,auipcM,RW_typeM,memtoregM,memreadM,memwriteM,regwriteM})
);

dff_r #(6) rW(
	.clk(clk),
	.rst_n(rst_n),
	.d({jalM,jalrM,luiM,auipcM,memtoregM,regwriteM}),
	.q({jalW,jalrW,luiW,auipcW,memtoregW,regwriteW})
);


main_control main_control_u0(
	.opcode(opcodeD),
	.func3(func3D),
	.memread(memreadD),
	.memwrite(memwriteD),
	.memtoreg(memtoregD),
	.alusrc(alusrcD),
	.regwrite(regwriteD),
	.lui(luiD),
	.auipc(auipcD),
	.jal(jalD),
	.jalr(jalrD),
	.beq(beqD),
	.bne(bneD),
	.blt(bltD),
	.bge(bgeD),
	.bltu(bltuD),
	.bgeu(bgeuD),
	.RW_type(RW_typeD),
	.aluop(aluopD)
);

alu_control alu_control_u0(
	.aluop(aluopD),
	.func3(func3D),
	.func7(func7D),
	.aluctl(aluctlD)
);

endmodule
