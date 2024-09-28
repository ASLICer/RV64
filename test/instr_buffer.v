module instr_buffer#(
	parameter DECODE_NUM = 4
)(
	input clk,
	input rst,
	output reg  [31:0]instr [DECODE_NUM-1:0]
);
reg [31:0] instr_buffer [63:0];

reg [7:0] rd_addr;
reg [7:0] wr_addr;
always@(posedge clk or posedge rst )begin
	if(rst)
		rd_addr <= 1'b0;
	else	
		rd_addr <= rd_addr + 4;
end


generate
	genvar i;
	for(i=0;i<DECODE_NUM;i=i+1)begin:gen_instr
		assign instr[i] = instr_buffer[rd_addr-4+i];
	end

endgenerate
endmodule
