module dff_enrc #(parameter DATA_WIDTH=8)(
	input wire clk,
	input wire rst_n,
	input wire en,
	input wire clear,
	input wire [DATA_WIDTH-1:0]d,
	output reg [DATA_WIDTH-1:0]q
);

always@(posedge clk,negedge rst_n)begin
	if(~rst_n)
		q<=0;
	else if(~en)
		q<=q;
	else if (clear)
		q<=0;
	else	
		q<=d;		
end/*
always@(posedge clk,negedge rst_n)begin
	if(~rst_n)
		q<=0;
	else if (clear)
		q<=0;
	else if(en)
		q<=d;	
	else
		q<=q;		
end*/
endmodule		
