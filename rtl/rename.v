module rename#(
    parameter DATAWIDTH = 32 
)(  
    input clk,
    //源寄存器的逻辑寄存器编号
    input [4:0] instr0_rs1,
    input [4:0] instr0_rs2,
    input [4:0] instr1_rs1,
    input [4:0] instr1_rs2,
    input [4:0] instr2_rs1,
    input [4:0] instr2_rs2,
    input [4:0] instr3_rs1,
    input [4:0] instr3_rs2,
    //目的寄存器的逻辑寄存器编号
    input [4:0] instr0_rd,
    input [4:0] instr1_rd,
    input [4:0] instr2_rd,
    input [4:0] instr3_rd,
    //源寄存器的物理寄存器编号
    output [4:0] instr0_prs1,
    output [4:0] instr0_prs2,
    output [4:0] instr1_prs1,
    output [4:0] instr1_prs2,
    output [4:0] instr2_prs1,
    output [4:0] instr2_prs2,
    output [4:0] instr3_prs1,
    output [4:0] instr3_prs2,
    //目的寄存器的物理寄存器编号
    output [4:0] instr0_prd,
    output [4:0] instr1_prd,
    output [4:0] instr2_prd,
    output [4:0] instr3_prd， 
    //目的寄存器的旧物理寄存器编号
    output reg [4:0] instr0_preprd,
    output reg [4:0] instr1_preprd,
    output reg [4:0] instr2_preprd,
    output reg [4:0] instr3_preprd   
);
reg [4:0] rat [31:0]；//重命名映射表
reg [4:0] freelist [63:0];//空闲列表,FIFO实现
reg [5:0]fl_raddr;//freelist的读地址
//从RAT中读取的源寄存器的物理寄存器编号(由于相关性，不一定是正确的)
reg [4:0] instr0_rat_prs1;
reg [4:0] instr0_rat_prs2;
reg [4:0] instr1_rat_prs1;
reg [4:0] instr1_rat_prs2;
reg [4:0] instr2_rat_prs1;
reg [4:0] instr2_rat_prs2;
reg [4:0] instr3_rat_prs1;
reg [4:0] instr3_rat_prs2;

always@(posedge clk)begin
    if(rst)
        fl_raddr <= 1'b0;
    else
        fl_raddr <= fl_raddr+4;
end
//从RAT中读取目的寄存器对应的的旧物理寄存器编号
always@(posedge clk)begin
    instr0_preprd <= rat[instr0_rd];
    instr1_preprd <= rat[instr1_rd];
    instr2_preprd <= rat[instr2_rd];
    instr3_preprd <= rat[instr3_rd];    
end

//从RAT中读取源寄存器对应的的物理寄存器编号
always@(posedge clk)begin
    instr0_rat_prs1 <= rat[instr0_rs1];
    instr0_rat_prs2 <= rat[instr0_rs2];
    instr1_rat_prs1 <= rat[instr1_rs1];
    instr1_rat_prs2 <= rat[instr1_rs2];
    instr2_rat_prs1 <= rat[instr2_rs1];
    instr2_rat_prs2 <= rat[instr2_rs2];
    instr3_rat_prs1 <= rat[instr3_rs1];
    instr3_rat_prs2 <= rat[instr3_rs2];
end
//从空闲列表中找到空闲的物理寄存器，作为指令的目的寄存器对应的物理寄存器(由于相关性，不一定是正确的)
//组合逻辑读freelist,因为读完后还要写新的映射关系进RAT(上升沿写入)
//整个过程在一个周期内完成
reg [4:0] instr0_fl_prd;
reg [4:0] instr1_fl_prd;
reg [4:0] instr2_fl_prd;
reg [4:0] instr3_fl_prd;
always@(*)begin
    instr0_fl_prd = freelist[fl_raddr];
    instr1_fl_prd = freelist[fl_raddr+1];
    instr2_fl_prd = freelist[fl_raddr+2];
    instr3_fl_prd = freelist[fl_raddr+3];
end
//目的寄存器的物理寄存器编号就是从空闲列表找到空闲的物理寄存器编号
asign instr0_prd = instr0_fl_prd;
asign instr1_prd = instr1_fl_prd;
asign instr2_prd = instr2_fl_prd;
asign instr3_prd = instr3_fl_prd;
//向RAT中写入新的映射关系(目的寄存器对应的新的物理寄存器,解决WAW相关性)
always@(posedge clk)begin
    if((instr0_rd != instr1_rd) && (instr0_rd != instr2_rd) && (instr0_rd != instr3_rd))
        rat[instr0_rd] <= instr0_fl_prd;
    if((instr1_rd != instr2_rd) && (instr1_rd != instr3_rd))
        rat[instr1_rd] <= instr1_fl_prd;
    if((instr2_rd != instr3_rd))
        rat[instr2_rd] <= instr2_fl_prd;
    //指令3的新映射关系一定会被写入
    rat[instr3_rd] <= instr3_fl_prd;
end
//RAW相关性检查(后面指令的源寄存器是否等于前面指令的目的寄存器)
//第一条指令的源寄存器对应的物理寄存器只能来自RAT
//最后一条指令的目的寄存器来自于空闲列表，不可能作为其他指令的源寄存器
wire raw1_rs1,raw1_rs2;
wire [1:0] raw2_rs1,raw2_rs2;
wire [2:0] raw3_rs1,raw3_rs2;
//指令1与指令0相关性
//指令1的源寄存器=指令0的目的寄存器，1
assign raw1_rs1 = (instr1_rat_prs1 == instr0_fl_prd);
assign raw1_rs2 = (instr1_rat_prs2 == instr0_fl_prd);
//指令2与指令0/指令1相关性
//指令2的源寄存器=指令0的目的寄存器，01
//指令2的源寄存器=指令1的目的寄存器，10
//指令2的源寄存器=指令0和指令1的目的寄存器，11
assign raw2_rs1 = {(instr2_rat_prs1 == instr1_fl_prd),(instr2_rat_prs1 == instr0_fl_prd)};
assign raw2_rs2 = {(instr2_rat_prs2 == instr1_fl_prd),(instr2_rat_prs2 == instr0_fl_prd)};
//指令3与指令0/指令1/指令2相关性
//指令3的源寄存器=指令0的目的寄存器，001
//指令3的源寄存器=指令1的目的寄存器，010
//指令3的源寄存器=指令2的目的寄存器，100
//其他情况~~~
assign raw3_rs1 = {(instr3_rat_prs1 == instr2_fl_prd),(instr3_rat_prs1 == instr1_fl_prd),(instr3_rat_prs1 == instr0_fl_prd)};
assign raw3_rs2 = {(instr3_rat_prs2 == instr2_fl_prd),(instr3_rat_prs2 == instr1_fl_prd),(instr3_rat_prs2 == instr0_fl_prd)};

//选择源寄存器对应的物理寄存器输出
//指令0
assign instr0_prs1 = instr0_rat_prs1;
assign instr0_prs2 = instr0_rat_prs2;
//指令1
assign instr1_prs1 = raw1_rs1 ? instr0_fl_prd : instr1_rat_prs1;
assign instr1_prs2 = raw1_rs2 ? instr0_fl_prd : instr1_rat_prs2;
//指令2
assign instr2_prs1 = raw2_rs1[1] ? instr1_fl_prd : 
                     raw2_rs1[0] ? instr0_fl_prd : instr2_rat_prs1;
assign instr2_prs2 = raw2_rs2[1] ? instr1_fl_prd : 
                     raw2_rs2[0] ? instr0_fl_prd : instr2_rat_prs2; 
//指令3 
assign instr3_prs1 = raw3_rs1[2] ? instr2_fl_prd :
                     raw3_rs1[1] ? instr1_fl_prd : 
                     raw3_rs1[0] ? instr0_fl_prd : instr3_rat_prs1; 
assign instr3_prs2 = raw3_rs2[2] ? instr2_fl_prd :
                     raw3_rs2[1] ? instr1_fl_prd : 
                     raw3_rs2[0] ? instr0_fl_prd : instr3_rat_prs2;   
                                                                             
endmodule
