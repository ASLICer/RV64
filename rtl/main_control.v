module main_control(
	input	[6:0]	opcode,
	input	[2:0]	func3,
	output	[1:0]	aluop,
	output			memread,
	output			memtoreg,
	output			memwrite,
	output			alusrc,
	output			regwrite,
	output			lui,
	output			auipc,
	output			jal,
	output			jalr,
	output			beq,
	output			bne,
	output			blt,
	output			bge,
	output			bltu,
	output			bgeu,
	output	[2:0]	RW_type
);

wire	B_type;
wire	R_type;
wire	I_type;//here don't include load and jalr
wire	load;
wire	store;
//9 types of opcode
assign 	B_type	=(opcode==`B_type)	? 1'b1 : 1'b0;
assign 	R_type	=(opcode==`R_type) 	? 1'b1 : 1'b0;
assign 	I_type	=(opcode==`I_type)	? 1'b1 : 1'b0;
assign 	load	=(opcode==`load) 	? 1'b1 : 1'b0;
assign 	store	=(opcode==`store) 	? 1'b1 : 1'b0;

assign	jal		=(opcode==`jal)		? 1'b1 : 1'b0;
assign	jalr	=(opcode==`jalr)	? 1'b1 : 1'b0;
assign	lui		=(opcode==`lui)		? 1'b1 : 1'b0;
assign	auipc	=(opcode==`auipc)	? 1'b1 : 1'b0;

assign	beq		=B_type & (func3==3'b000);
assign	bne		=B_type & (func3==3'b001);
assign	blt		=B_type & (func3==3'b100);
assign	bge		=B_type & (func3==3'b101);
assign	bltu	=B_type & (func3==3'b110);
assign	bgeu	=B_type & (func3==3'b111);

assign	RW_type	=func3;

//enable
assign 	memread	=load;
assign 	memwrite=store;
assign 	regwrite=jal|jalr|load|I_type|R_type|lui|auipc;//S_type,B_type don't need to write back

//mux
assign 	alusrc	=load|store|I_type|jalr;//select imme as the second source data of alu
assign 	memtoreg=load;//select data_memory data to write back

//aluop(self define),R 10,I 01,B 11,load/store 00
//load/stor use alu to calculate address of data_memory
//lui/auipc/jalr/jal don't need alu
assign 	aluop[1]=R_type|B_type;
assign 	aluop[0]=I_type|B_type;

endmodule
