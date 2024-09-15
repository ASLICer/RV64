module dff_rc #(parameter WIDTH=8)(
	input wire clk,
	input wire rst_n,
	input wire clear,
	input wire [WIDTH-1:0]d,
	output reg [WIDTH-1:0]q
);

always@(posedge clk,negedge rst_n)begin
	if(~rst_n)
		q<=0;
	else if(clear)
		q<=0;
	else	
		q<=d;		
end
endmodule
