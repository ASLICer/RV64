module control(
	input [6:0]opcode,
	input [2:0]func3,
	input func7,
	output Memread,
	output Memwrite,
	output Memtoreg,
	output ALUsrc,
	output Regwrite,
	output lui,
	output auipc,
	output jal,
	output jalr,
	output beq,
	output bne,
	output blt,
	output bge,
	output bltu,
	output bgeu,
	output [2:0]RW_type,
	output [3:0]ALUctl
);

wire [1:0]ALUop;

main_control main_control_inst(
	.opcode(opcode),
	.func3(func3),
	.Memread(Memread),
	.Memwrite(Memwrite),
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
	.RW_type(RW_type),
	.ALUop(ALUop)
);

alu_control alu_control_inst(
	.ALUop(ALUop),
	.func3(func3),
	.func7(func7),
	.ALUctl(ALUctl)
);

endmodule
