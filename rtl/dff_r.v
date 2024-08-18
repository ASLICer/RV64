module dff_r #(parameter DATA_WIDTH=8)
(
	input wire clk,
	input wire rst_n,
	input wire [DATA_WIDTH-1:0]d,
	output reg [DATA_WIDTH-1:0]q
);

always@(posedge clk,negedge rst_n)begin
	if(~rst_n)
		q<=0;
	else	
		q<=d;		
end
endmodule
