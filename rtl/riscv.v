module riscv(
	input			clk,
	input 			rst_n,
	input	[31:0]	instr,
	input 	[31:0]	Rd_mem_data,
	
	output 	[31:0]	rom_addr,
	
	output 	[31:0]	Wr_mem_data,
	output 			W_en,
	output 			R_en,
	output 	[31:0]	ram_addr,
	output 	[2:0]	RW_type
);
//decode stage
wire			jalD;
wire			jalrD;
wire			luiD;
wire			auipcD;
wire			beqD;
wire			bneD;
wire			bltD;
wire			bgeD;
wire			bltuD;
wire			bgeuD;
wire			memwriteD;
wire	[6:0] 	opcodeD;
wire	[2:0] 	func3D;
wire			func7D;
//execute stage
wire 			memtoregE;
wire 			alusrcE;
wire 			regwriteE;
wire 	[3:0]	aluctlE;
wire 			flushE;
//mem stage
wire 			memtoregM;
wire 			regwriteM;
wire			luiM;
wire			auipcM;
wire			jalM;
wire			jalrM;
//writeback stage 
wire			luiW;
wire			auipcW;
wire			jalW;
wire			jalrW;
wire 			memtoregW;
wire 			regwriteW;



control control_u0(
	.clk(clk),
	.rst_n(rst_n),
	//decode stage
	.opcodeD(opcodeD),
	.func3D(func3D),
	.func7D(func7D),
	.jalD(jalD),
	.jalrD(jalrD),
	.luiD(luiD),
	.auipcD(auipcD),
	.beqD(beqD),
	.bneD(bneD),
	.bltD(bltD),
	.bgeD(bgeD),
	.bltuD(bltuD),
	.bgeuD(bgeuD),
	.memwriteD(memwriteD),
	//execute stage
	.flushE(flushE),
	.memtoregE(memtoregE),
	.regwriteE(regwriteE),
	.alusrcE(alusrcE),
	.aluctlE(aluctlE),

	//mem stage 
	.memtoregM(memtoregM),
	.memwriteM(W_en),
	.memreadM(R_en),
	.regwriteM(regwriteM),
	.RW_typeM(RW_type),
	.luiM(luiM),
	.auipcM(auipcM),
	.jalrM(jalrM),
	.jalM(jalM),

	//write back stage 
	.memtoregW(memtoregW),
	.regwriteW(regwriteW),
	.luiW(luiW),
	.auipcW(auipcW),
	.jalW(jalW),
	.jalrW(jalrW)
);

datapath datapath_u0(
	.clk(clk),
	.rst_n(rst_n),
	//fetch stage
	.pcF(rom_addr),
	.instrF(instr),
	//decode stage
	.jalD(jalD),
	.jalrD(jalrD),
	.luiD(luiD),
	.auipcD(auipcD),
	.beqD(beqD),
	.bneD(bneD),
	.bltD(bltD),
	.bgeD(bgeD),
	.bltuD(bltuD),
	.bgeuD(bgeuD),
	.memwriteD(memwriteD),
	.opcodeD(opcodeD),
	.func3D(func3D),
	.func7D(func7D),
	//execute stage
	.memtoregE(memtoregE),
	.alusrcE(alusrcE),
	.regwriteE(regwriteE),
	.aluctlE(aluctlE),
	.flushE(flushE),
	//mem stage
	.memtoregM(memtoregM),
	.regwriteM(regwriteM),
	.memwriteM(W_en),
	.memreadM(R_en),
	.aluoutM(ram_addr),
	.Wr_mem_dataM(Wr_mem_data),
	.readdataM(Rd_mem_data),
	.luiM(luiM),
	.auipcM(auipcM),
	.jalrM(jalrM),
	.jalM(jalM),

	//writeback stage 
	.luiW(luiW),
	.auipcW(auipcW),
	.jalW(jalW),
	.jalrW(jalrW),
	.memtoregW(memtoregW),
	.regwriteW(regwriteW)
);


endmodule
