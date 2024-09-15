
module mux5 #(parameter DATA_WIDTH=64)
(
	input wire [DATA_WIDTH-1:0]d0,
	input wire [DATA_WIDTH-1:0]d1,
	input wire [DATA_WIDTH-1:0]d2,
    input wire [DATA_WIDTH-1:0]d3,
    input wire [DATA_WIDTH-1:0]d4,
	input wire [2:0]s,
	output wire[DATA_WIDTH-1:0]y
);

assign y=(s==3'b000) ? d0 :
		 (s==3'b001) ? d1 :
		 (s==3'b010) ? d2 :
         (s==3'b011) ? d3 : 
         (s==3'b100) ? d4 : d0;

endmodule
