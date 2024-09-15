module main_control(
	input	[6:0]	opcode,
	input	[2:0]	func3,
	output	reg [2:0]	aluop,
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
wire	Rw_type;
wire	Iw_type;
//9 types of opcode
assign 	B_type	=(opcode==`B_type)	? 1'b1 : 1'b0;
assign 	R_type	=(opcode==`R_type) 	? 1'b1 : 1'b0;
assign 	I_type	=(opcode==`I_type)	? 1'b1 : 1'b0;
assign 	load	=(opcode==`load) 	? 1'b1 : 1'b0;
assign 	store	=(opcode==`store) 	? 1'b1 : 1'b0;
assign 	Rw_type	=(opcode==`Rw_type) ? 1'b1 : 1'b0;
assign 	Iw_type	=(opcode==`Iw_type)	? 1'b1 : 1'b0;


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
assign 	regwrite=jal|jalr|load|I_type|R_type|lui|auipc|Rw_type|Iw_type;//S_type,B_type don't need to write back

//mux
assign 	alusrc	=load|store|I_type|jalr|Iw_type;//select imme as the second source data of alu
assign 	memtoreg=load;//select data_memory data to write back

//aluop(self define)
//load/store use alu to calculate address of data_memory
//lui/auipc/jalr/jal don't need alu
always@(*)begin
	case({R_type,I_type,B_type,Rw_type|Iw_type,load|store})	
		5'b10000:aluop = 3'b000;
		5'b01000:aluop = 3'b001;
		5'b00100:aluop = 3'b010;
		5'b00010:aluop = 3'b011;
		5'b00001:aluop = 3'b100;
		default:aluop = 3'b100;
	endcase
end

endmodule
