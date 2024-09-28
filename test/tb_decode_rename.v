module tb_decode_rename#(
    parameter DATA_WIDTH = 64,
    parameter ARF_WIDTH = 5,
    parameter PRF_WIDTH = 6,
	parameter DECODE_NUM = 4,
	parameter ISSUE_NUM = 4,
    parameter RETIRE_NUM = 4,
    parameter IMME = DATA_WIDTH
)
(

);
	reg clk;
	reg rst;
initial begin
	$readmemb("./test/decode_rename.c", instr_buffer_u0.instr_buffer);
end

/////////////////////////from decode to rename and issue/////////////////////
wire [31:0]instr [DECODE_NUM-1:0];
wire [6:0] opcode[DECODE_NUM-1:0];
wire [2:0] func3 [DECODE_NUM-1:0];
wire       func7 [DECODE_NUM-1:0];
wire [4:0] Rs1   [DECODE_NUM-1:0];
wire [4:0] Rs2   [DECODE_NUM-1:0];
wire [4:0] Rd    [DECODE_NUM-1:0];
wire [DATA_WIDTH-1:0] imme [DECODE_NUM-1:0];
wire [DECODE_NUM-1:0] instr_prs1_v;//指令是否有来自源寄存器1操作数(R/I/S/B有，U/J没有)
wire [DECODE_NUM-1:0] instr_prs2_v;//指令是否有来自源寄存器2操作数(R/S/B有，I/U/J没有)  
wire [DECODE_NUM-1:0] instr_prd_v ; //指令是否有目的寄存器(R/I/U/J有，S/B_type没有)

/////////////////////////from rob to rename/////////////////////
//指令退休 && 退休的指令存在目的寄存器>>释放指令的旧目的寄存器
reg [RETIRE_NUM-1:0] retire;                    //四条最旧指令是否可以退休
reg [RETIRE_NUM-1:0] rob_areg_v;                //最旧四条指令是否存在目的寄存器
reg [PRF_WIDTH-1:0]  rob_opreg [RETIRE_NUM-1:0];//最旧四条指令的opreg

//////////////////from rename to issue ///////////////////////////////
//源寄存器的物理寄存器编号
wire [PRF_WIDTH-1:0] instr0_prs1;
wire [PRF_WIDTH-1:0] instr0_prs2;
wire [PRF_WIDTH-1:0] instr1_prs1;
wire [PRF_WIDTH-1:0] instr1_prs2;
wire [PRF_WIDTH-1:0] instr2_prs1;
wire [PRF_WIDTH-1:0] instr2_prs2;
wire [PRF_WIDTH-1:0] instr3_prs1;
wire [PRF_WIDTH-1:0] instr3_prs2;
//////////////////from rename to issue and rob///////////////////////////////
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

/*
//////////////////iq///////////////
//////////to rf read////
wire [PRF_WIDTH-1:0] issue_prs1  [ISSUE_NUM-1:0] ;//被发射指令的源寄存器1对应的物理寄存器编号   
wire [PRF_WIDTH-1:0] issue_prs2  [ISSUE_NUM-1:0] ;//被发射指令的源寄存器2对应的物理寄存器编号  
wire [OPCODE-1:0]    issue_op    [DECODE_NUM-1:0];//指令的opcode
wire [FUN3-1:0]      issue_func3 [ISSUE_NUM-1:0] ;//指令的func3
wire                 issue_func7 [ISSUE_NUM-1:0] ;//指令的func7
wire [IMME-1:0]      issue_imme  [ISSUE_NUM-1:0] ;//指令的立即数
wire [PRF_WIDTH-1:0] issue_prd   [ISSUE_NUM-1:0] ;//被发射指令的目的寄存器对应的物理寄存器编号 

///////////////////rf read/////////////////
wire [PRF_WIDTH-1:0] rf_prs1  [ISSUE_NUM-1:0] ;//被发射指令的源寄存器1对应的物理寄存器编号   
wire [PRF_WIDTH-1:0] rf_prs2  [ISSUE_NUM-1:0] ;//被发射指令的源寄存器2对应的物理寄存器编号
/////to controller  
wire [OPCODE-1:0]    rf_op    [DECODE_NUM-1:0];//指令的opcode
wire [FUN3-1:0]      rf_func3 [ISSUE_NUM-1:0] ;//指令的func3
wire                 rf_func7 [ISSUE_NUM-1:0] ;//指令的func7
///////to execute
wire [IMME-1:0]      rf_imme [ISSUE_NUM-1:0];//rf read阶段指令的立即数
wire [PRF_WIDTH-1:0] rf_prd  [ISSUE_NUM-1:0];//rf read阶段被发射指令的目的寄存器对应的物理寄存器编号 

wire [DATA_WIDTH-1:0]rf_src1 [ISSUE_NUM-1:0];//rf read阶段fu的操作数1
wire [DATA_WIDTH-1:0]rf_src2 [ISSUE_NUM-1:0];//rf read阶段fu的操作数2

//////////execute//////////
wire [DATA_WIDTH-1:0]ex_src1 [ISSUE_NUM-1:0];//ex阶段fu的操作数1
wire [DATA_WIDTH-1:0]ex_src2 [ISSUE_NUM-1:0];//ex阶段fu的操作数2
wire [IMME-1:0]      ex_imme [ISSUE_NUM-1:0];//ex阶段指令的立即数
wire [PRF_WIDTH-1:0] ex_prd  [ISSUE_NUM-1:0];//ex阶段被发射指令的目的寄存器对应的物理寄存器编号 

wire [DATA_WIDTH-1:0] fu0_src1;//ALU0的操作数1
wire [DATA_WIDTH-1:0] fu0_src2;//ALU0的操作数2
wire [DATA_WIDTH-1:0] fu1_src1;//ALU1的操作数1
wire [DATA_WIDTH-1:0] fu1_src2;//ALU1的操作数2
wire [DATA_WIDTH-1:0] fu2_src1;//MUL/DIV的操作数1
wire [DATA_WIDTH-1:0] fu2_src2;//MUL/DIV的操作数2
wire [DATA_WIDTH-1:0] fu3_src1;//BRU的操作数1
wire [DATA_WIDTH-1:0] fu3_src2;//BRU的操作数2

wire [2:0] fu0_src1_sel;//ALU0的操作数1选择控制信号
wire [2:0] fu0_src2_sel;//ALU0的操作数2选择控制信号
wire [2:0] fu1_src1_sel;//ALU1的操作数1选择控制信号
wire [2:0] fu1_src2_sel;//ALU1的操作数2选择控制信号
wire [2:0] fu2_src1_sel;//MUL/DIV的操作数1选择控制信号
wire [2:0] fu2_src2_sel;//MUL/DIV的操作数2选择控制信号
wire [2:0] fu3_src1_sel;//BRU的操作数1选择控制信号
wire [2:0] fu3_src2_sel;//BRU的操作数2选择控制信号

wire [DATA_WIDTH-1:0] ex_aluout0;
wire [DATA_WIDTH-1:0] ex_aluout1;
wire [DATA_WIDTH-1:0] ex_mduout;
wire [DATA_WIDTH-1:0] ex_bruout;
/////////to writeback(单周期指令可以)//////////
wire [PRF_WIDTH-1:0] wb_prd [ISSUE_NUM-1:0];//wb阶段被发射指令的目的寄存器对应的物理寄存器编号 
wire [DATA_WIDTH-1:0]wb_data[ISSUE_NUM-1:0];//wb阶段写回目的寄存器的数据
*/
instr_buffer #(
	DECODE_NUM
)
instr_buffer_u0(
	clk,
	rst,
	instr
);

///////////////////////instr_decode stage//////////////////////
instr_decode #(
	DATA_WIDTH ,
	DECODE_NUM 
)
instr_decode_u0(   
    //input
    .instr  (instr ),

    //output
    .opcode (opcode),
    .func3  (func3 ),
    .func7  (func7 ),
    .Rs1    (Rs1   ),
    .Rs2    (Rs2   ),
    .Rd     (Rd    ),
	.imme	(imme  ),

    .instr_prs1_v(instr_prs1_v),//指令是否有来自源寄存器1操作数(R/I/S/B有，U/J没有)
    .instr_prs2_v(instr_prs2_v),//指令是否有来自源寄存器2操作数(R/S/B有，I/U/J没有)  
    .instr_prd_v (instr_prd_v)   //指令是否有目的寄存器(R/I/U/J有，S/B_type没有)
);

rename #(
	ARF_WIDTH ,
    PRF_WIDTH ,
	DECODE_NUM,
    RETIRE_NUM
)
rename_u0(  
    //input
    .clk(clk),   
    .rst(rst),
    ///////////////////from instr_decode////////////////////
    //源寄存器的逻辑寄存器编号
    .instr0_rs1(Rs1[0]),
    .instr0_rs2(Rs2[0]),
    .instr1_rs1(Rs1[1]),
    .instr1_rs2(Rs2[1]),
    .instr2_rs1(Rs1[2]),
    .instr2_rs2(Rs2[2]),
    .instr3_rs1(Rs1[3]),
    .instr3_rs2(Rs2[3]),
    //目的寄存器的逻辑寄存器编号
    .instr0_rd(Rd[0]),
    .instr1_rd(Rd[1]),
    .instr2_rd(Rd[2]),
    .instr3_rd(Rd[3]),
    //寄存器有效性    
    .instr_prs1_v(instr_prs1_v),//指令是否有来自源寄存器1操作数
    .instr_prs2_v(instr_prs2_v),//指令是否有来自源寄存器2操作数  
    .instr_prd_v (instr_prd_v) ,//指令是否有目的寄存器
        
    /////////////////////////from rob/////////////////////
    //指令退休 && 退休的指令存在目的寄存器>>释放指令的旧目的寄存器
    .retire      (retire)    ,//四条最旧指令是否可以退休
    .rob_areg_v  (rob_areg_v),//最旧四条指令是否存在目的寄存器
    .rob_opreg   (rob_opreg) ,//最旧四条指令的opreg

    //output
    //////////////////to issue ///////////////////////////////
    //源寄存器的物理寄存器编号
   .instr0_prs1(instr0_prs1),
   .instr0_prs2(instr0_prs2),
   .instr1_prs1(instr1_prs1),
   .instr1_prs2(instr1_prs2),
   .instr2_prs1(instr2_prs1),
   .instr2_prs2(instr2_prs2),
   .instr3_prs1(instr3_prs1),
   .instr3_prs2(instr3_prs2),
    //////////////////to issue and rob///////////////////////////////
    //目的寄存器的物理寄存器编号
   .instr0_prd(instr0_prd),
   .instr1_prd(instr1_prd),
   .instr2_prd(instr2_prd),
   .instr3_prd(instr3_prd), 
   //目的寄存器的旧物理寄存器编号
   .instr0_preprd(instr0_preprd),
   .instr1_preprd(instr1_preprd),
   .instr2_preprd(instr2_preprd),
   .instr3_preprd(instr3_preprd)   
);

	reg  [PRF_WIDTH-1:0] reg_rat [31:0];//暂存写入新映射关系前的RAT，用于打印
integer i,j,k;
initial  begin
	forever #10 clk = ~clk;
end
initial  begin
	#11
	for(i=0;i<13;i=i+1)begin
		#1//上升沿后1s
		$display("================================== Cycle %2d ==================================",i);	
		$display("instruction0 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",Rd[0],Rs1[0],Rs2[0],instr0_prd,instr0_prs1,instr0_prs2,instr0_preprd);	
		$display("instruction1 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",Rd[1],Rs1[1],Rs2[1],instr1_prd,instr1_prs1,instr1_prs2,instr1_preprd);	
		$display("instruction2 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",Rd[2],Rs1[2],Rs2[2],instr2_prd,instr2_prs1,instr2_prs2,instr2_preprd);	
		$display("instruction3 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",Rd[3],Rs1[3],Rs2[3],instr3_prd,instr3_prs1,instr3_prs2,instr3_preprd);
		reg_rat = rename_u0.rat;//写如新映射关系前的rat
		#19//新映射关系已经写入rat(下降沿写入)
				$display("+-----------+  =====>>>>  +-----------+");
				$display("| ARF | PRF |  =====>>>>  | ARF | PRF |");
				$display("+-----------+  =====>>>>  +-----------+");
		for(j=0;j<32;j=j+1)
				$display("| R%2d | P%2d |  =====>>>>  | R%2d | P%2d | ",j,reg_rat[j],j,rename_u0.rat[j]);
	end
end


initial begin
	clk = 1'b0;
	rst = 1'b1;

	#5 rst = 1'b0;
	#500 $finish;
end
initial begin
	$vcdpluson;
	$vcdplusmemon;
end

initial begin
    $fsdbDumpfile("./test/decode_rename.fsdb");
    $fsdbDumpvars(0,tb_decode_rename,"+all");
end

/*
commit_retire #(
    DATA_WIDTH,     
    DECODE_NUM,
    ISSUE_NU,
    RETIRE_NUM,

    COMPLETE,
    AREG_V,
    AREG,
    PREG,
    OPREG,
    PC,
    EXCEPTION,
    TYPE,
    ROB_WIDTH,

    COMPLETE_B,
    AREG_V_B,
    AREG_LSB,
    OPREG_MSB,
    PC_LSB,
    PC_MSB,
    EXCEPTION_B,
    TYPE_LSB,
    TYPE_MSB
)
commit_retire_u0(
    .clk(clk),
    .rst(rst),
   
    //from execute
    .instr_iaddr,()//指令在rename阶段开始就跟着指令流动的ROB编号，传到write back阶段，说明指令执行完毕

    //from rename and decode
    .areg_v   (instr_prd_v),//指令存在目的寄存器
    .areg     (Rd),//逻辑目的寄存器
    .preg     ({instr3_prd,instr2_prd,instr1_prd,instr0_prd}),//物理目的寄存器
    .opreg    ({instr3_preprd,instr2_prerd,instr1_prerd,instr0_prerd}),//旧物理目的寄存器
    .pc       (),//指令pc值，用于中断或者异常，重新执行程序
    .exception(),//异常类型
    .type     (),//指令类型，退休时，不同类型指令有不同动作

    //rob >> issue >> execute >> write back >> rob
    .instr_oaddr (),//指令在rob的地址跟随指令流动

    //to freelist,指令退休 && 指令存在目的寄存器>>释放指令的旧目的寄存器（后面的指令不会再使用这个物理寄存器）
    .retire      (retire),//四条最旧指令是否可以退休
    .retire_num  (),//本周期退休指令数量，退休几条则free list写地址加几
    .rob_areg_v  (rob_areg_v),//最旧四条指令是否存在目的寄存器
    .rob_opreg   (rob_opreg) //最旧四条指令的opreg
);
*/
/*
/////////////////////issue stage///////////////////////////
issue #(
    DECODE_NUM,
    ISSUE_NUM,
    CIQ_DEPTH,
    DATA_WIDTH,

    OPCODE,
    FUN3,
    FUN7,
    IMME,


    PRF_WIDTH,
    VALID,
    READY,
    ISSUED_WIDTH,
    FREE_WIDTH,
    AGE_WIDTH,
    IQ_WIDTH,

    FREE,
    ISSUED,
    AGE_LSB,
    AGE_MSB,
    PRDV,
    PRD_LSB,
    PRD_MSB,
    PRS2_RDY,
    PRS2_V,
    PRS2_LSB,
    PRS2_MSB,
    PRS1_RDY,
    PRS1_V,
    PRS1_LSB,
    PRS1_MSB, 
    IMME_LSB,
    IMME_MSB,
    FUN7_B,
    FUN3_LSB,
    FUN3_MSB,
    OP_LSB,
    OP_MSB

)
issue_u0(
    .clk(clk),
    .rst(rst),
    //////////指令进入发射队列//////////
    //from instr_decode  
    .instr_op    (opcode),//指令的opcode
    .instr_func3 (func3),//指令的func3
	.instr_func7 (func7),//指令的func7
    .instr_imme  (imme),//指令的立即数
    
    .instr_prs1_v(instr_prs1_v),//指令是否有来自源寄存器1操作数
    .instr_prs2_v(instr_prs2_v),//指令是否有来自源寄存器2操作数  
    .instr_prd_v (instr_prd_v),//指令是否有目的寄存器   

    //from rename   
    .instr_prs1  (instr_prs1),//源寄存器1对应的物理寄存器编号
    .instr_prs2  (instr_prs1),//源寄存器2对应的物理寄存器编号  
    .instr_prd   (instr_prd),//目的寄存器对应的物理寄存器编号

     //from rob
    .age         (age),//指令的年龄

    //////////被选中的指令离开发射队列//////////
    .//to register file
    .issue_prs1  (issue_prs1),//被发射指令的源寄存器1对应的物理寄存器编号   
    .issue_prs2  (issue_prs1),//被发射指令的源寄存器2对应的物理寄存器编号  

    //to control
    .issue_op    (issue_op),//指令的opcode
    .issue_func3 (issue_func3),//指令的func3
    .issue_func7 (issue_func7),//指令的func7
    //to FU
    .issue_imme  (issue_imme),//指令的立即数
   
    //to RF read >> execute >> writeback
    .issue_prd   (issue_prd)//被发射指令的目的寄存器对应的物理寄存器编号  

);

////////////////////iq to rf read/////////////////////
dff_rc #(18) iq2rf(
	.clk(clk),
	.rst_n(rst_n),
	.clear(flushE),
	.d({issue_prs1,issue_prs2,issue_prd,issue_op,issue_func3,issue_func7,issue_imme}),
	.q({rf_prs1   ,rf_prs2   ,rf_prd   ,rf_op   ,rf_func3   ,rf_func7   ,rf_imme})
);

/////////////////////rf read stage///////////////////
registers #(
    DATA_WIDTH,
    ISSUE_NUM
)
registers_u0(
	.clk     (clk),
	.rst_n   (rst_n),
	.W_en    (wb_wen),
	.Rs1     (rf_prs1),
	.Rs2     (rf_prs2),
	.Rd      (wb_prd),
	.Wr_data (wb_data),
	.Rd_data1(rf_src1),
	.Rd_data2(rf_src2)
);

///////////////////rf to ex read///////////////
dff_rc #(18) rf2ex(
	.clk(clk),
	.rst_n(rst_n),
	.clear(flushE),
	.d({rf_src1   ,rf_src2   ,rf_prd   ,rf_imme}),
	.q({ex_src1   ,ex_src2   ,ex_prd   ,ex_imme})
);

//////////////////////execute stage//////////////////
///////////ALU0///////////
mux5 #(.DATA_WIDTH(DATA_WIDTH))//选择ALU0的操作数1，来源于寄存器/其他FU的旁路
fu0_src1_mux(
	.d0(ex_src1[0]) ,//from register
	.d1(wb_data[0]) ,//from FU0
	.d2(wb_data[1]) ,//from FU1
    .d3(wb_data[2]) ,//from FU2
    .d4(wb_data[3]) ,//from FU3
	.s(fu0_src1_sel),
	.y(fu0_src1)
);

mux6 #(.DATA_WIDTH(DATA_WIDTH))//选择ALU0的操作数2，来源于寄存器/其他FU的旁路/立即数
fu0_src2_mux(
	.d0(ex_src2[0]) ,//from register
	.d1(wb_data[0]) ,//from FU0
	.d2(wb_data[1]) ,//from FU1
    .d3(wb_data[2]) ,//from FU2
    .d4(wb_data[3]) ,//from FU3
    .d5(ex_imme[0]) ,//from imme
	.s(fu0_src2_sel),
	.y(fu0_src2)
);

alu #(.DATA_WIDTH(DATA_WIDTH))
alu_u0 
(
	.ALU_DA(fu0_src1), 
	.ALU_DB(fu0_src2), 
	.ALU_CTL(ex_aluctl0), 
	.ALU_ZERO(), 
	.ALU_OverFlow(), 
	.ALU_DC(ex_aluout0)
);
//////////////////

///////////ALU1///////////
mux5 #(.DATA_WIDTH(DATA_WIDTH))//选择ALU1的操作数1，来源于寄存器/其他FU的旁路
fu1_src1_mux(
	.d0(ex_src1[1]) ,//from register
	.d1(wb_data[0]) ,//from FU0
	.d2(wb_data[1]) ,//from FU1
    .d3(wb_data[2]) ,//from FU2
    .d4(wb_data[3]) ,//from FU3
	.s(fu1_src1_sel),
	.y(fu1_src1)
);

mux6 #(.DATA_WIDTH(DATA_WIDTH))//选择ALU1的操作数2，来源于寄存器/其他FU的旁路/立即数
fu1_src2_mux(
	.d0(ex_src2[1]) ,//from register
	.d1(wb_data[0]) ,//from FU0
	.d2(wb_data[1]) ,//from FU1
    .d3(wb_data[2]) ,//from FU2
    .d4(wb_data[3]) ,//from FU3
    .d5(ex_imme[1]) ,//from imme
	.s(fu1_src2_sel),
	.y(fu1_src2)
);

alu #(.DATA_WIDTH(DATA_WIDTH))
alu_u1 
(
	.ALU_DA(fu1_src1), 
	.ALU_DB(fu1_src2), 
	.ALU_CTL(ex_aluctl1), 
	.ALU_ZERO(), 
	.ALU_OverFlow(), 
	.ALU_DC(ex_aluout1)
);
//////////////////
///////////MDU///////////
mux5 #(.DATA_WIDTH(DATA_WIDTH))//选择MDU的操作数1，来源于寄存器/其他FU的旁路,乘除法没有立即数
fu2_src1_mux(
	.d0(ex_src1[2]) ,//from register
	.d1(wb_data[0]) ,//from FU0
	.d2(wb_data[1]) ,//from FU1
    .d3(wb_data[2]) ,//from FU2
    .d4(wb_data[3]) ,//from FU3
	.s(fu2_src1_sel),
	.y(fu2_src1)
);

mux5 #(.DATA_WIDTH(DATA_WIDTH))//选择MDU的操作数2，来源于寄存器/其他FU的旁路
fu2_src2_mux(
	.d0(ex_src2[2]) ,//from register
	.d1(wb_data[0]) ,//from FU0
	.d2(wb_data[1]) ,//from FU1
    .d3(wb_data[2]) ,//from FU2
    .d4(wb_data[3]) ,//from FU3
	.s(fu2_src2_sel),
	.y(fu2_src2)
);

mdu #(.DATA_WIDTH(DATA_WIDTH))
mdu_u0 
(
	.MDU_DA(fu2_src1), 
	.MDU_DB(fu2_src2), 
	.MDU_CTL(ex_mductl), 
	.MDU_DC(ex_mduout)
);
///////////
///////////BRU/////////////
mux5 #(.DATA_WIDTH(DATA_WIDTH))//选择BRU的操作数1，来源于寄存器/其他FU的旁路
fu3_src1_mux(
	.d0(ex_src1[3]) ,//from register
	.d1(wb_data[0]) ,//from FU0
	.d2(wb_data[1]) ,//from FU1
    .d3(wb_data[2]) ,//from FU2
    .d4(wb_data[3]) ,//from FU3
	.s(fu3_src1_sel),
	.y(fu3_src1)
);
mux5 #(.DATA_WIDTH(DATA_WIDTH))//选择BRU的操作数2，来源于寄存器/其他FU的旁路
fu3_src2_mux(
	.d0(ex_src2[3]) ,//from register
	.d1(wb_data[0]) ,//from FU0
	.d2(wb_data[1]) ,//from FU1
    .d3(wb_data[2]) ,//from FU2
    .d4(wb_data[3]) ,//from FU3
	.s(fu3_src2_sel),
	.y(fu3_src2)
);
bru #(.DATA_WIDTH(DATA_WIDTH))
bru_u0 
(
	.BRU_DA(fu2_src1), 
	.BRU_DB(fu2_src2), 
	.BRU_DC(ex_aguout)
);
module bru#(parameter DATA_WIDTH = 64)
(
	input beq,
	input bne, 
	input blt, 
	input bge, 
	input bltu, 
	input bgeu, 
	input jal,
	input jalr,
    input [DATA_WIDTH-1:0] BRU_DA,
    input [DATA_WIDTH-1:0] BRU_DB,
    input [DATA_WIDTH-1:0] pc,
    input [DATA_WIDTH-1:0] imme,
    output[DATA_WIDTH-1:0] pc_br,
	output [1:0] br_valid
);

*/
endmodule
