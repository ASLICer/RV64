module tb_rename#(
	parameter ARF_WIDTH = 5,
    parameter PRF_WIDTH = 6,
	parameter DECODE_NUM = 4
)();
	reg clk;
	reg rst;
    //源寄存器的逻辑寄存器编号
    reg [ARF_WIDTH-1:0] instr0_rs1;
    reg [ARF_WIDTH-1:0] instr0_rs2;
    reg [ARF_WIDTH-1:0] instr1_rs1;
    reg [ARF_WIDTH-1:0] instr1_rs2;
    reg [ARF_WIDTH-1:0] instr2_rs1;
    reg [ARF_WIDTH-1:0] instr2_rs2;
    reg [ARF_WIDTH-1:0] instr3_rs1;
    reg [ARF_WIDTH-1:0] instr3_rs2;
    //目的寄存器的逻辑寄存器编号
    reg [ARF_WIDTH-1:0] instr0_rd;
    reg [ARF_WIDTH-1:0] instr1_rd;
    reg [ARF_WIDTH-1:0] instr2_rd;
    reg [ARF_WIDTH-1:0] instr3_rd;

	reg [DECODE_NUM-1:0]instr_prs1_v;//指令是否有来自源寄存器1操作数
    reg [DECODE_NUM-1:0]instr_prs2_v;//指令是否有来自源寄存器2操作数  
    reg [DECODE_NUM-1:0]instr_prd_v;//指令是否有目的寄存器
    //源寄存器的物理寄存器编号
    wire [PRF_WIDTH-1:0] instr0_prs1;
    wire [PRF_WIDTH-1:0] instr0_prs2;
    wire [PRF_WIDTH-1:0] instr1_prs1;
    wire [PRF_WIDTH-1:0] instr1_prs2;
    wire [PRF_WIDTH-1:0] instr2_prs1;
    wire [PRF_WIDTH-1:0] instr2_prs2;
    wire [PRF_WIDTH-1:0] instr3_prs1;
    wire [PRF_WIDTH-1:0] instr3_prs2;
    //目的寄存器的物理寄存器编号
    wire [PRF_WIDTH-1:0] instr0_prd;
    wire [PRF_WIDTH-1:0] instr1_prd;
    wire [PRF_WIDTH-1:0] instr2_prd;
    wire [PRF_WIDTH-1:0] instr3_prd; 
    //目的寄存器的旧物理寄存器编号
    wire [PRF_WIDTH-1:0] instr0_preprd;
    wire [PRF_WIDTH-1:0] instr1_preprd;
    wire [PRF_WIDTH-1:0] instr2_preprd;
    wire [PRF_WIDTH-1:0] instr3_preprd;

	reg  [PRF_WIDTH-1:0] reg_rat [31:0];//暂存写入新映射关系前的RAT，用于打印
integer i,j;
initial  begin
	forever #10 clk = ~clk;
end
initial  begin
	#10
	for(i=0;i<3;i=i+1)begin
		#1
		$display("================================== Cycle %2d ==================================",i);	
		$display("instruction0 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",instr0_rd,instr0_rs1,instr0_rs2,instr0_prd,instr0_prs1,instr0_prs2,instr0_preprd);	
		$display("instruction1 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",instr1_rd,instr1_rs1,instr1_rs2,instr1_prd,instr1_prs1,instr1_prs2,instr1_preprd);	
		$display("instruction2 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",instr2_rd,instr2_rs1,instr2_rs2,instr2_prd,instr2_prs1,instr2_prs2,instr2_preprd);	
		$display("instruction3 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",instr3_rd,instr3_rs1,instr3_rs2,instr3_prd,instr3_prs1,instr3_prs2,instr3_preprd);
		reg_rat = rename_u0.rat;
		#15
				$display("+-----------+  =====>>>>  +-----------+");
				$display("| ARF | PRF |  =====>>>>  | ARF | PRF |");
				$display("+-----------+  =====>>>>  +-----------+");
		for(j=0;j<32;j=j+1)
				$display("| R%2d | P%2d |  =====>>>>  | R%2d | P%2d | ",j,reg_rat[j],j,rename_u0.rat[j]);
		#4 ;
	end
end
/*always@(posedge clk)begin
	instr0_rd = {$random}%32;instr0_rs1 = {$random}%32;instr0_rs2 = {$random}%32;//第一条指令
	instr1_rd = {$random}%32;instr1_rs1 = {$random}%32;instr1_rs2 = {$random}%32;//第二条指令
	instr2_rd = {$random}%32;instr2_rs1 = {$random}%32;instr2_rs2 = {$random}%32;//第三条指令
	instr3_rd = {$random}%32;instr3_rs1 = {$random}%32;instr3_rs2 = {$random}%32;//第四条指令	
end
*/
initial begin
	clk = 1'b0;
	rst = 1'b1;
	instr_prs1_v = {DECODE_NUM{1'b1}};//指令是否有来自源寄存器1操作数
    instr_prs2_v = {DECODE_NUM{1'b1}};//指令是否有来自源寄存器2操作数  
    instr_prd_v  = {DECODE_NUM{1'b1}};//指令是否有目的寄存器

	#5 rst = 1'b0;
	//WAW,RAW,WAR
	instr0_rd = 7;instr0_rs1 = 1;instr0_rs2 = 2;//第一条指令
	instr1_rd = 7;instr1_rs1 = 3;instr1_rs2 = 7;//第二条指令
	instr2_rd = 5;instr2_rs1 = 4;instr2_rs2 = 6;//第三条指令
	instr3_rd = 7;instr3_rs1 = 8;instr3_rs2 = 9;//第四条指令

	#25 
	//WAW,RAW,WAR
	instr_prs1_v = {DECODE_NUM{1'b1}};//指令是否有来自源寄存器1操作数
    instr_prs2_v = {DECODE_NUM{1'b1}};//指令是否有来自源寄存器2操作数  
    instr_prd_v  = {(DECODE_NUM){1'b1}};//指令是否有目的寄存器

	instr0_rd = 5;instr0_rs1 = 3;instr0_rs2 = 2;//第一条指令
	instr1_rd = 6;instr1_rs1 = 4;instr1_rs2 = 2;//第二条指令
	instr2_rd = 4;instr2_rs1 = 7;instr2_rs2 = 1;//第三条指令
	instr3_rd = 6;instr3_rs1 = 6;instr3_rs2 = 1;//第四条指令
	#20
	instr0_rd = 1;instr0_rs1 = 2;instr0_rs2 = 3;//第一条指令
	instr1_rd = 1;instr1_rs1 = 1;instr1_rs2 = 4;//第二条指令
	instr2_rd = 1;instr2_rs1 = 1;instr2_rs2 = 5;//第三条指令
	instr3_rd = 1;instr3_rs1 = 1;instr3_rs2 = 6;//第四条指令


	#100 $finish;
end

rename #(
	ARF_WIDTH,
    PRF_WIDTH,
	DECODE_NUM
)rename_u0
	(
	clk,
	rst,
    //源寄存器的逻辑寄存器编号
    instr0_rs1,
    instr0_rs2,
    instr1_rs1,
    instr1_rs2,
    instr2_rs1,
    instr2_rs2,
    instr3_rs1,
    instr3_rs2,
    //目的寄存器的逻辑寄存器编号
    instr0_rd,
    instr1_rd,
    instr2_rd,
    instr3_rd,

	instr_prs1_v,//指令是否有来自源寄存器1操作数
    instr_prs2_v,//指令是否有来自源寄存器2操作数  
    instr_prd_v,//指令是否有目的寄存器
    //源寄存器的物理寄存器编号
    instr0_prs1,
    instr0_prs2,
    instr1_prs1,
    instr1_prs2,
    instr2_prs1,
    instr2_prs2,
    instr3_prs1,
    instr3_prs2,
    //目的寄存器的物理寄存器编号
    instr0_prd,
    instr1_prd,
    instr2_prd,
    instr3_prd, 
    //目的寄存器的旧物理寄存器编号
    instr0_preprd,
    instr1_preprd,
    instr2_preprd,
    instr3_preprd   
);

initial begin
	$vcdpluson;
	$vcdplusmemon;
end

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0,tb_rename,"+all");
end

endmodule
