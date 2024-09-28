module data_memory#(
parameter DATA_WIDTH=64
)(
	input clk,
	input rst_n,
	input W_en,
	input R_en,
	input [DATA_WIDTH-1:0]addr,
	input [2:0]RW_type,
	input [DATA_WIDTH-1:0]WD,
	output reg [DATA_WIDTH-1:0]RD
);

reg [31:0]ram[255:0];//定义存储器

wire [63:0]RD_data;//地址所在双字/字
assign RD_data={ram[addr[31:2]+1],ram[addr[31:2]]};

reg [31:0]wr_data_b;//拼接写入字节后的字
reg [31:0]wr_data_h;//拼接写入半字后的字
wire[31:0]wr_data_w;//写入的字
wire[63:0]wr_data_dw;//写入的双字

reg [63:0]wr_data;//最终写入的数据

/////////得到需要写入存储器的数据的所有可能结果（字节，半字，字，双字）//////////////
always@(*)begin//根据地址低两位写不同的字节，如0，1，2，3
	case(addr[1:0])
		2'b00:wr_data_b={RD_data[31:8],WD[7:0]};
		2'b01:wr_data_b={RD_data[31:16],WD[7:0],RD_data[7:0]};
		2'b10:wr_data_b={RD_data[31:24],WD[7:0],RD_data[15:0]};
		2'b11:wr_data_b={WD[7:0],RD_data[23:0]};
	endcase
end

always@(*)begin//根据地址第二位写不同的半字，如01，23
	case(addr[1])
		1'b0:wr_data_h={RD_data[15:0],WD[15:0]};
		1'b1:wr_data_h={WD[15:0],RD_data[15:0]};
	endcase
end

assign wr_data_w=WD[31:0];//写一个字
assign wr_data_dw=WD;//写双字

////////根据RW_type选择最终写入的数据/////////////////
always@(*)begin
	case(RW_type[1:0])
		2'b00:wr_data=wr_data_b;
		2'b01:wr_data=wr_data_h;
		2'b10:wr_data=wr_data_w;
		2'b11:wr_data=wr_data_dw;
		default:wr_data={64{1'b0}};
	endcase
end

////////写入数据////////////
integer i;
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)
		for(i=0;i<255;i=i+1)
			ram[i]<=32'b0;
	else if(W_en)begin
		ram[addr[31:2]]<=wr_data[31:0];
		if(RW_type[1:0] == 2'b11)
			ram[addr[31:2]+1]<=wr_data[63:32];
	end
	else
		ram[addr[31:2]]<=ram[addr[31:2]];
end

reg [7:0] rd_data_b;//读字节
reg [15:0]rd_data_h;//读半字
wire[31:0]rd_data_w;//读字
wire[63:0]rd_data_dw;//读双字

reg [DATA_WIDTH-1:0]rd_data_b_ext;//扩展成64bit
reg [DATA_WIDTH-1:0]rd_data_h_ext;//扩展成64bit
reg [DATA_WIDTH-1:0]rd_data_w_ext;//扩展成64bit

/////////得到需要从存储器读出的数据的所有可能结果（字节，半字，字，双字）//////////////
always@(*)begin//根据低两位地址读不同的字节，如0，1，2，3
	case(addr[1:0])
		2'b00:rd_data_b=RD_data[7:0];
		2'b01:rd_data_b=RD_data[15:8];
		2'b10:rd_data_b=RD_data[23:16];
		2'b11:rd_data_b=RD_data[31:24];
	endcase
end

always@(*)begin//根据第二位地址读不同的半字，如01，23
	case(addr[1])
		1'b0:rd_data_h=RD_data[15:0];
		1'b1:rd_data_h=RD_data[31:16];
	endcase
end

assign rd_data_w=RD_data[31:0];//读字
assign rd_data_dw=RD_data[63:0];//读双字

/////////////将读出的数据0扩展/符号扩展到数据位宽////////////
always@(*)begin
	case(RW_type[2])
		1'b0:begin
				rd_data_b_ext={{(DATA_WIDTH-8){rd_data_b[7]}},rd_data_b};//符号扩展
				rd_data_h_ext={{(DATA_WIDTH-16){rd_data_h[15]}},rd_data_h};//符号扩展
				rd_data_w_ext={{32{rd_data_w[31]}},rd_data_w};//符号扩展
			end
		1'b1:begin
				rd_data_b_ext={{(DATA_WIDTH-16){1'b0}},rd_data_b};//无符号扩展
				rd_data_h_ext={{(DATA_WIDTH-16){1'b0}},rd_data_h};//无符号扩展
			 	rd_data_w_ext={{32{1'b0}},rd_data_w};//无符号扩展
			end
	endcase
end
///////////根据RW_type选择最终读出的数据/////////////
always@(*)begin
	if(R_en)
		case(RW_type[1:0])
			2'b00:RD=rd_data_b_ext;
			2'b01:RD=rd_data_h_ext;
			2'b10:RD=rd_data_w_ext[DATA_WIDTH-1:0];
			2'b11:RD=rd_data_dw;
			default:RD={(DATA_WIDTH){1'b0}};
		endcase
	else
		RD={{(DATA_WIDTH){1'b0}}};
end

endmodule
