`include "./rtl/define.v"
module pc_reg(
	input		clk,
	input		rst_n,
	input		en,
	input 		[31:0]pc_new,
	output	reg	[31:0]pc_out
);

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		pc_out<=`zero_word;
	else if(en)
		pc_out<=pc_new;	
	else
		pc_out<=pc_out;
end

endmodule
