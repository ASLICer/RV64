module data_memory(
	input clk,
	input rst_n,
	input W_en,
	input R_en,
	input [31:0]addr,
	input [2:0]RW_type,
	input [31:0]WD,
	output reg [31:0]RD
);

reg [31:0]ram[255:0];

wire [31:0]RD_data;
assign RD_data=ram[addr[31:2]];

reg [31:0]wr_data_b;
reg [31:0]wr_data_h;
wire[31:0]wr_data_w;
assign wr_data_w=WD;

reg [31:0]wr_data;

always@(*)begin
	case(addr[1:0])
		2'b00:wr_data_b={RD_data[31:8],WD[7:0]};
		2'b01:wr_data_b={RD_data[31:16],WD[7:0],RD_data[7:0]};
		2'b10:wr_data_b={RD_data[31:24],WD[7:0],RD_data[15:0]};
		2'b11:wr_data_b={WD[7:0],RD_data[23:0]};
	endcase
end

always@(*)begin
	case(addr[1])
		1'b0:wr_data_h={RD_data[15:0],WD[15:0]};
		1'b1:wr_data_h={WD[15:0],RD_data[15:0]};
	endcase
end

always@(*)begin
	case(RW_type[1:0])
		2'b00:wr_data=wr_data_b;
		2'b01:wr_data=wr_data_h;
		2'b10:wr_data=wr_data_w;
	endcase
end

always@(posedge clk)begin
	if(W_en)
		ram[addr[31:2]]<=wr_data;
	else
		ram[addr[31:2]]<=ram[addr[31:2]];
end

reg [7:0] rd_data_b;
reg [15:0]rd_data_h;
wire[31:0]rd_data_w;
assign rd_data_w=RD_data;

reg [31:0]rd_data_b_ext;
reg [31:0]rd_data_h_ext;

always@(*)begin
	case(addr[1:0])
		2'b00:rd_data_b=RD_data[7:0];
		2'b01:rd_data_b=RD_data[15:8];
		2'b10:rd_data_b=RD_data[23:16];
		2'b11:rd_data_b=RD_data[31:24];
	endcase
end

always@(*)begin
	case(addr[1])
		1'b0:rd_data_h=RD_data[15:0];
		1'b1:rd_data_h=RD_data[31:16];
		endcase
end

always@(*)begin
	case(RW_type[2])
		1'b0:rd_data_b_ext={{24{rd_data_b[7]}},rd_data_b};
		1'b1:rd_data_b_ext={24'b0,rd_data_b};
		endcase
end

always@(*)begin
	case(RW_type[2])
		1'b0:rd_data_h_ext={{16{rd_data_h[15]}},rd_data_h};
		1'b1:rd_data_h_ext={16'b0,rd_data_h};
		endcase
end

always@(*)begin
	if(R_en)
		case(RW_type[1:0])
			2'b00:RD=rd_data_b_ext;
			2'b01:RD=rd_data_h_ext;
			2'b10:RD=rd_data_w;
		endcase
	else
		RD=32'b0;
end

endmodule
