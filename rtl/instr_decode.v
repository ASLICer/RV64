`include "./rtl/define.v"
module instr_decode#(
	parameter DATA_WIDTH = 64,
	parameter DECODE_NUM = 4
)
(
	input  [31:0]instr [DECODE_NUM-1:0],
	output [6:0] opcode [DECODE_NUM-1:0],
	output [2:0] func3 [DECODE_NUM-1:0],
	output func7 [DECODE_NUM-1:0],
	output [4:0] Rs1 [DECODE_NUM-1:0],
	output [4:0] Rs2 [DECODE_NUM-1:0],
	output [4:0] Rd [DECODE_NUM-1:0],
	output [DATA_WIDTH-1:0] imme [DECODE_NUM-1:0],

	output  [DECODE_NUM-1:0]instr_prs1_v,//指令是否有来自源寄存器1操作数(R/I/S/B有，U/J没有)
	output  [DECODE_NUM-1:0]instr_prs2_v,//指令是否有来自源寄存器2操作数(R/S/B有，I/U/J没有)  
    output  [DECODE_NUM-1:0]instr_prd_v//指令是否有目的寄存器(R/I/U/J有，S/B_type没有)
);
wire R_type [DECODE_NUM-1:0];
wire I_type [DECODE_NUM-1:0];
wire U_type [DECODE_NUM-1:0];
wire J_type [DECODE_NUM-1:0];
wire B_type [DECODE_NUM-1:0];
wire S_type [DECODE_NUM-1:0];

wire [DATA_WIDTH-1:0]I_imme [DECODE_NUM-1:0];
wire [DATA_WIDTH-1:0]U_imme [DECODE_NUM-1:0];
wire [DATA_WIDTH-1:0]J_imme [DECODE_NUM-1:0];
wire [DATA_WIDTH-1:0]B_imme [DECODE_NUM-1:0];
wire [DATA_WIDTH-1:0]S_imme [DECODE_NUM-1:0];

generate
	genvar i;
	for(i=0;i<DECODE_NUM;i=i+1)begin:decode_group
		assign opcode[i]=instr[i][6:0];
		assign func3 [i]=instr[i][14:12];
		assign func7 [i]=instr[i][30];
		assign Rs1	 [i]=instr[i][19:15];
		assign Rs2	 [i]=instr[i][24:20];
		assign Rd	 [i]=instr[i][11:7];
		
		assign R_type[i]=(instr[i][6:0]==`R_type) | (instr[i][6:0]==`Rw_type);
		assign I_type[i]=(instr[i][6:0]==`jalr)|(instr[i][6:0]==`load)|(instr[i][6:0]==`I_type)|(instr[i][6:0]==`Iw_type);
		assign U_type[i]=(instr[i][6:0]==`lui)|(instr[i][6:0]==`auipc);
		assign J_type[i]=(instr[i][6:0]==`jal);
		assign B_type[i]=(instr[i][6:0]==`B_type);
		assign S_type[i]=(instr[i][6:0]==`store);
		
		assign I_imme[i]={{(DATA_WIDTH-12){instr[i][31]}},instr[i][31:20]}; 
		assign U_imme[i]={{(DATA_WIDTH-32){instr[i][31]}},instr[i][31:12],{12{1'b0}}};
		assign J_imme[i]={{(DATA_WIDTH-20){instr[i][31]}},instr[i][19:12],instr[i][20],instr[i][30:21],1'b0};   
		assign B_imme[i]={{(DATA_WIDTH-12){instr[i][31]}},instr[i][7],instr[i][30:25],instr[i][11:8],1'b0};
		assign S_imme[i]={{(DATA_WIDTH-12){instr[i][31]}},instr[i][31:25],instr[i][11:7]};
		
		assign   imme[i]=I_type[i] ? I_imme[i]:
					 	 U_type[i] ? U_imme[i]:
					 	 J_type[i] ? J_imme[i]:
				 	 	 B_type[i] ? B_imme[i]:
					 	 S_type[i] ? S_imme[i]:{(DATA_WIDTH){1'b0}};
		assign instr_prs1_v[i] = R_type[i] | I_type[i] | S_type[i] | B_type[i];
		assign instr_prs2_v[i] = R_type[i] | S_type[i] | B_type[i];
		assign instr_prd_v [i] = R_type[i] | I_type[i] | U_type[i] | J_type[i];
	end
endgenerate


endmodule
