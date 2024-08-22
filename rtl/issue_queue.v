module issue_queue#(
    parameter OPCODE = 7,
    parameter PRF_WIDTH = 6,
    parameter VALID = 1,
    parameter READY = 1,
    parameter ISSUED = 1,
    parameter FREE = 1,
    parameter AGE = 5,
    parameter IQ_WIDTH = OPCODE+3*PRF_WIDTH+3*VALID+2*READY+ISSUED+FREE+AGE
)(
    input clk,
    //指令的opcode
    input [6:0] instr0_op,
    input [6:0] instr1_op,
    input [6:0] instr2_op,
    input [6:0] instr3_op,
    //指令是否有源操作数
    input instr0_prs1_v,
    input instr0_prs2_v,
    input instr1_prs1_v,
    input instr1_prs2_v,
    input instr2_prs1_v,
    input instr2_prs2_v,
    input instr3_prs1_v,
    input instr3_prs2_v,
    //指令是否有目的寄存器
    input instr0_prd_v,
    input instr1_prd_v,
    input instr2_prd_v,
    input instr3_prd_v，   
    //源寄存器的物理寄存器编号
    input [PRF_WIDTH-1:0] instr0_prs1,
    input [PRF_WIDTH-1:0] instr0_prs2,
    input [PRF_WIDTH-1:0] instr1_prs1,
    input [PRF_WIDTH-1:0] instr1_prs2,
    input [PRF_WIDTH-1:0] instr2_prs1,
    input [PRF_WIDTH-1:0] instr2_prs2,
    input [PRF_WIDTH-1:0] instr3_prs1,
    input [PRF_WIDTH-1:0] instr3_prs2,
    //目的寄存器的物理寄存器编号
    input [PRF_WIDTH-1:0] instr0_prd,
    input [PRF_WIDTH-1:0] instr1_prd,
    input [PRF_WIDTH-1:0] instr2_prd,
    input [PRF_WIDTH-1:0] instr3_prd,

    output reg [IQ_WIDTH-1:0] ciq [15:0]//16个表项的集中式发射队列
);

//发射队列空闲表项的地址
wire [3:0] free0_addr;
wire [3:0] free1_addr;
wire [3:0] free2_addr;
wire [3:0] free3_addr;
//所在地址确实是空闲的
wire free0_valid;
wire free1_valid;
wire free2_valid;
wire free3_valid; 
wire [15:0] ciq_free;//16个空闲标志位
integer i;
always@(*)begin
    for(i=0;i<16;i=i+1)
        ciq_free[i] = ciq[i][0];
end
allocation allocation_u0(
    ciq_free,
    //发射队列空闲表项的地址
    free0_addr,
    free1_addr,
    free2_addr,
    free3_addr,
    //所在地址确实是空闲的
    free0_valid,
    free1_valid,
    free2_valid,
    free3_valid  
);
//找到4个空闲表项写入指令
always@(posedge clk)begin
    if(free0_valid)
        ciq[free0_addr] <= {instr0_op,instr0_prs1,instr0_prs1_v,instr0_prs1_rdy,instr0_prs2,instr0_prs2_v,instr0_prs2_rdy,instr0_prd,instr0_prd_v,instr0_age,2'b00};  
    if(free1_valid)  
        ciq[free1_addr] <= {instr1_op,instr1_prs1,instr1_prs1_v,instr1_prs1_rdy,instr1_prs2,instr1_prs2_v,instr1_prs2_rdy,instr1_prd,instr1_prd_v,instr1_age,2'b00};
    if(free2_valid)
        ciq[free2_addr] <= {instr2_op,instr2_prs1,instr2_prs1_v,instr2_prs1_rdy,instr2_prs2,instr2_prs2_v,instr2_prs2_rdy,instr2_prd,instr2_prd_v,instr2_age,2'b00};
    if(free3_valid)
        ciq[free3_addr] <= {instr3_op,instr3_prs1,instr3_prs1_v,instr3_prs1_rdy,instr3_prs2,instr3_prs2_v,instr3_prs2_rdy,instr3_prd,instr3_prd_v,instr3_age,2'b00};    
end
always@(posedge clk)begin
    
end
endmoudle