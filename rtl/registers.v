`include "./rtl/define.v"
module registers(
	input clk,
	input rst_n,
	input W_en,
	input [4:0]Rs1,
	input [4:0]Rs2,
	input [4:0]Rd,
	input [31:0]Wr_data,
	output[31:0]Rd_data1,
	output[31:0]Rd_data2
);

reg [31:0]regs[31:0];
integer i;
always@(negedge clk,negedge rst_n)begin
	if(!rst_n)
		for(i=0;i<32;i=i+1)
			regs[i]<=32'b0;
	else
		if(W_en & (Rd!=0))
			regs[Rd]<=Wr_data;
		else	
			regs[Rd]<=regs[Rd];
end

assign Rd_data1=(Rs1==5'd0)?`zero_word:regs[Rs1];
assign Rd_data2=(Rs2==5'd0)?`zero_word:regs[Rs2];

endmodule
