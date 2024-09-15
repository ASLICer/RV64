module riscv(
	input			clk,
	input 			rst_n,
	input	[31:0]	instr,
	input 	[31:0]	Rd_mem_data,
	
	output 	[7:0]	rom_addr,
	
	output 	[31:0]	Wr_mem_data,
	output 			W_en,
	output 			R_en,
	output 	[31:0]	ram_addr,
	output 	[2:0]	RW_type
);

wire [6:0]	opcode;
wire [2:0]	func3;
wire 		func7;
wire 		Memtoreg;
wire 		ALUsrc;
wire 		Regwrite;
wire 		lui;
wire		auipc;
wire 		jal;
wire 		jalr;
wire 		beq;
wire 		bne;
wire 		blt;
wire 		bge;
wire 		bltu;
wire 		bgeu;
wire [3:0]	ALUctl;



control control_inst (
	.opcode(opcode), 
	.func3(func3), 
	.func7(func7), 
	.Memread(R_en), 
	.Memtoreg(Memtoreg), 
	.Memwrite(W_en), 
	.ALUsrc(ALUsrc), 
	.Regwrite(Regwrite), 
	.lui(lui),
	.auipc(auipc),
	.jal(jal), 
	.jalr(jalr), 
	.beq(beq), 
	.bne(bne), 
	.blt(blt), 
	.bge(bge), 
	.bltu(bltu), 
	.bgeu(bgeu), 
	.RW_type(RW_type), 
	.ALUctl(ALUctl)
);

datapath datapath_inst (
	.clk(clk), 
	.rst_n(rst_n), 
	.instr(instr), 
	.Memtoreg(Memtoreg), 
	.ALUsrc(ALUsrc), 
	.Regwrite(Regwrite), 
	.lui(lui),
	.auipc(auipc),
	.jal(jal), 
	.jalr(jalr), 
	.beq(beq), 
	.bne(bne), 
	.blt(blt), 
	.bge(bge), 
	.bltu(bltu), 
	.bgeu(bgeu), 
	.ALUctl(ALUctl), 
	.Rd_mem_data(Rd_mem_data), 
	.rom_addr(rom_addr), 
	.Wr_mem_data(Wr_mem_data),
	.ALU_result(ram_addr),
	.opcode(opcode),
	.func3(func3),
	.func7(func7)
);

endmodule
