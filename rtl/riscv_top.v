module riscv_top#(parameter DATA_WIDTH = 64)
(
	input clk,
	input rst_n,
	output [7:0]rom_addr
);

//	wire [7:0]rom_addr;
	wire [DATA_WIDTH-1:0]ram_addr;
	wire [31:0]instr;
	wire [DATA_WIDTH-1:0]Rd_mem_data;
	wire [DATA_WIDTH-1:0]Wr_mem_data;
	wire W_en;
	wire R_en;
	wire [2:0]RW_type;
	wire [DATA_WIDTH-1:0]rom_addr_1;

	assign	rom_addr=rom_addr_1[9:2];
	instr_memory instr_memory_inst 
	(
    .addr(rom_addr), 
    .instr(instr)
    );

	riscv #(.DATA_WIDTH(DATA_WIDTH)) riscv_inst 
	(
    .clk(clk), 
    .rst_n(rst_n), 
    .instr(instr), 
    .Rd_mem_data(Rd_mem_data), 
    .rom_addr(rom_addr_1), 
    .Wr_mem_data(Wr_mem_data), 
    .W_en(W_en), 
    .R_en(R_en), 
    .ram_addr(ram_addr), 
    .RW_type(RW_type)
    );

	
	
	
	data_memory #(.DATA_WIDTH(DATA_WIDTH)) data_memory_inst 
	(
    .clk(clk), 
    .rst_n(rst_n), 
    .W_en(W_en),
	.R_en(R_en),
    .addr(ram_addr), 
    .RW_type(RW_type), 
    .WD(Wr_mem_data), 
    .RD(Rd_mem_data)
    );	

endmodule
