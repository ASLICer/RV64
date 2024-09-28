module instr_memory(
	input [7:0] addr,
	output [31:0]instr
);

reg [31:0] rom [255:0];



assign instr=rom[addr];

endmodule
