module datapath(
	input			clk,
	input			rst_n,
	input	[31:0]	instr,

	input			Memtoreg,
	input			ALUsrc,
	input			Regwrite,
	input			lui,
	input			auipc,
	input			jal,
	input			jalr,
	input			beq,
	input			bne,
	input			blt,
	input			bge,
	input			bltu,
	input			bgeu,
	input	[3:0]	ALUctl,
	
	input	[31:0]	Rd_mem_data,
	output	[7:0]	rom_addr,
	output	[31:0]	Wr_mem_data,
	output	[31:0]	ALU_result,
	output	[6:0]	opcode,
	output	[2:0]	func3,
	output		 	func7
);


//pc ports

wire	[31:0]	pc_new;
wire	[31:0]	pc_out;
wire	[31:0]	pc_order;
wire	[31:0]	pc_b_jal;
wire	[31:0]	pc_b_jal_order;
wire	[31:0]	pc_jalr;


//registers ports
wire	[4:0]	Rs1;
wire	[4:0]	Rs2;
wire	[4:0]	Rd;
wire	[31:0]	WB_data;
wire	[31:0]	Rd_data1;
wire	[31:0]	Rd_data2;

wire	[31:0]	imme;

//ALU ports
wire			zero;
wire	[31:0]	ALU_DB;

wire	[1:0]	jump_sel;
wire	[3:0]	Wr_reg_sel;




assign Wr_reg_sel	=	{Memtoreg,jal | jalr,lui,auipc} ;
assign Wr_mem_data	=	Rd_data2;
assign rom_addr		=	pc_out[9:2];
assign pc_jalr		=	ALU_result;

pc_reg pc_reg_inst (
.clk(clk), 
.rst_n(rst_n), 
.pc_new(pc_new), 
.pc_out(pc_out)
);


instr_decode instr_decode_inst (
.instr(instr), 
.opcode(opcode), 
.func3(func3), 
.func7(func7), 
.Rs1(Rs1), 
.Rs2(Rs2), 
.Rd(Rd), 
.imme(imme)
);

registers registers_inst (
.clk(clk),
.rst_n(rst_n),
.W_en(Regwrite), 
.Rs1(Rs1), 
.Rs2(Rs2), 
.Rd(Rd), 
.Wr_data(WB_data), 
.Rd_data1(Rd_data1), 
.Rd_data2(Rd_data2)
);


alu alu_inst (
.ALU_DA(Rd_data1), 
.ALU_DB(ALU_DB), 
.ALU_CTL(ALUctl), 
.ALU_ZERO(zero), 
.ALU_OverFlow(), 
.ALU_DC(ALU_result)
);

branch_judge branch_judge_inst (
.beq(beq), 
.bne(bne), 
.blt(blt), 
.bge(bge), 
.bltu(bltu), 
.bgeu(bgeu), 
.jal(jal),
.jalr(jalr),
.zero(zero), 
.ALU_result(ALU_result), 
.jump_sel(jump_sel)
);




//pc+4	
cla_adder32 pc_adder_4 (
.A(pc_out), 
.B(32'd4), 
.cin(1'd0), 
.result(pc_order), 
.cout()
);
	
//pc+imme
cla_adder32 pc_adder_imme (
.A(pc_out), 
.B(imme), 
.cin(1'd0), 
.result(pc_b_jal), 
.cout()
);
	

///pc_sel
mux3 pc_sel_mux (
.data1(pc_b_jal), 
.data2(pc_jalr),
.data3(pc_order),
.sel(jump_sel), 
.dout(pc_new)
);

	
	
//ALUdata_sel	
mux ALU_data_mux (
.data1(imme), 
.data2(Rd_data2), 
.sel(ALUsrc), 
.dout(ALU_DB)
);
	
//Wr_reg_sel	
mux5 Wr_reg_mux(
.data1	(Rd_mem_data),
.data2	(pc_order),
.data3	(imme),
.data4	(pc_b_jal),
.data5	(ALU_result),
.sel	(Wr_reg_sel),
.dout	(WB_data)
);	

endmodule
