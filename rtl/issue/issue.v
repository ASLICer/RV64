module issue#(
    parameter DECODE_NUM = 4,
    parameter ISSUE_NUM = 4,
    parameter CIQ_DEPTH = 16,
    parameter OPCODE = 7,
    parameter PRF_WIDTH = 6,
    parameter VALID = 1,
    parameter READY = 1,
    parameter ISSUED_WIDTH = 1,
    parameter FREE_WIDTH = 1,
    parameter AGE_WIDTH = 5,
    parameter IQ_WIDTH = OPCODE+3*PRF_WIDTH+3*VALID+2*READY+ISSUED_WIDTH+FREE_WIDTH+AGE,

    parameter FREE = 0,
    parameter ISSUED = FREE+1,
    parameter AGE_LSB = ISSUED+1,
    parameter AGE_MSB = AGE_LSB+AGE_WIDTH-1,
    parameter PRDV = AGE_MSB+1,
    parameter PRD_LSB = PRDV+1,
    parameter PRD_MSB = PRD_LSB+PRF_WIDTH-1,
    parameter PRS2_RDY = PRD_MSB+1,
    parameter PRS2_V = PRS2_RDY,
    parameter PRS2_LSB = PRS2_V+1,
    parameter PRS2_MSB = PRS2_LSB+PRF_WIDTH-1,
    parameter PRS1_RDY = PRS2_MSB+1,
    parameter PRS1_V = PRS1_RDY+1,
    parameter PRS1_LSB = PRS1_V+1,
    parameter PRS1_MSB = PRS1_LSB+PRF_WIDTH-1,  
    parameter OP_LSB = PRS1_MSB+1,
    parameter OP_MSB = OP_LSB+OPCODE_WIDTH-1

)(
    input clk,
    //from rename   
    input [OPCODE-1:0] instr_op [DECODE_NUM-1:0],//指令的opcode
    input instr_prs1_v [DECODE_NUM-1:0],//指令是否有来自源寄存器1操作数
    input instr_prs2_v [DECODE_NUM-1:0],//指令是否有来自源寄存器2操作数  
    input instr_prd_v [DECODE_NUM-1:0],//指令是否有目的寄存器     
    input [PRF_WIDTH-1:0] instr_prs1 [DECODE_NUM-1:0],//源寄存器1对应的物理寄存器编号
    input [PRF_WIDTH-1:0] instr_prs2 [DECODE_NUM-1:0],//源寄存器2对应的物理寄存器编号  
    input [PRF_WIDTH-1:0] instr_prd [DECODE_NUM-1:0],//目的寄存器对应的物理寄存器编号
    input [AGE-1:0] age [DECODE_NUM-1:0];//指令的年龄
    //to FU
    output [DATA_WIDTH-1:0] src0 [DECODE_NUM-1:0],//第一个操作数   
    output [DATA_WIDTH-1:0] src1 [DECODE_NUM-1:0]//第二个操作数   
);
reg [IQ_WIDTH-1:0] ciq [CIQ_DEPTH-1:0];//16个表项的集中式发射队列

//////////////////////分配电路(寻找发射队列空闲表项)//////////////////////////
reg [CIQ_DEPTH-1:0] ciq_free;//16个空闲标志位
wire [3:0] free_addr [DECODE_NUM-1:0];//发射队列空闲表项的地址
wire [DECODE_NUM-1:0] free_valid;//所在地址确实是空闲的 

integer i,j;
always@(*)begin
    for(i=0;i<CIQ_DEPTH;i=i+1)
        ciq_free[i] = ciq[i][0];
end
allocation #(
    DECODE_NUM,
    DECODE_NUM
)allocation_u0(
    ciq_free,
    free_addr,
    free_valid  
);
////////////////////////////////////////////////
////////////////////发射队列////////////////////////
issue_queue #(
    DECODE_NUM,
    ISSUE_NUM,
    CIQ_DEPTH,
    OPCODE,
    PRF_WIDTH,
    VALID,
    READY,
    ISSUED,
    FREE,
    AGE,
    IQ_WIDTH,
    PRS1_RDY,
    PRS2_RDY
)issue_queue_u0(
    clk,   
    instr_op,//指令的opcode 
    instr_prs1_v,//指令是否有来自源寄存器1操作数
    instr_prs2_v,//指令是否有来自源寄存器2操作数   
    instr_prd_v, //指令是否有目的寄存器    
    instr_prs1,//源寄存器1对应的物理寄存器编号
    instr_prs2,//源寄存器2对应的物理寄存器编号  
    instr_prd,//目的寄存器对应的物理寄存器编号 
    free_addr,//发射队列空闲表项的地址 
    free_valid,//所在地址确实是空闲的  
    prs1_rdy,//唤醒电路得到的源寄存器1的ready信号
    prs1_rdy,//唤醒电路得到的源寄存器2的ready信号  
    ciq//16个表项的集中式发射队列
);
////////////////////////////////////////////////
//////////////////////仲裁电路//////////////////////////
wire [OPCODE_WIDTH-1:0] op [CIQ_DEPTH-1:0];//发射队列所有表项的opcode
reg  [CIQ_DEPTH-1:0] req;//发射队列所有表项的请求信号
wire [AGE-1:0] age [CIQ_DEPTH-1:0];//发射队列所有表项的年龄
wire [3:0] arbit_addr [ISSUE_NUM-1:0];//仲裁出的指令所在发射队列地址
wire [ISSUE_NUM-1:0] arbit_grant;//仲裁出的结果是有效的
wire [6:0] OP [ISSUE_NUM-1:0];
wire muti_finish;//多周期指令是否执行完毕
always@(*)begin
    OP[0] = `ALU;
    OP[1] = `ALU;
    OP[2] = `MUL;
    OP[3] = `LOAD;  
end

always@(*)begin//发射队列所有表项的请求信号
    for(i=0;i<CIQ_DEPTH;i=i+1)
        req[i] = (~ciq[PRS1_V] | ciq[PRS1_RDY]) & (~ciq[PRS2_V] | ciq[PRS2_RDY]) & ~ciq[ISSUED] & ~ciq[FREE];
end

generate
genvar i;
    for(i=0;i<ISSUE_NUM;i=i+1)begin:arbiter_group
        arbiter #(
            .OP(OP[i]),
            .OPCODE_WIDTH(7),
            .REQ(1),
            .AGE_WIDTH(5)
        )arbiter_block(
            .op(op),
            .req(req),
            .age(age),
            .grant(arbit_grant[i]),
            .addr(arbit_addr[i]),
            .muti_finish(muti_finish)
        );
    end
endgenerate
//////////////////////////////////////////////////////
///////////////////唤醒电路/////////////////////////
wire prs1_rdy [CIQ_DEPTH-1:0];//经过唤醒电路得到发射队列所有源寄存器1的ready信号
wire prs2_rdy [CIQ_DEPTH-1:0];//经过唤醒电路得到发射队列所有源寄存器2的ready信号
//from issue_queue
reg [PRF_WIDTH-1:0] arbit_prd[ISSUE_NUM-1:0];//被arbiter选中的指令的目的寄存器对应的物理寄存器编号
reg [ISSUE_NUM-1:0] arbit_prd_v;//被arbiter选中的指令是否有目的寄存器
reg [PRF_WIDTH-1:0] ciq_prs1[CIQ_DEPTH-1:0];//发射队列中所有指令的源寄存器1对应的物理寄存器编号
reg [PRF_WIDTH-1:0] ciq_prs2[CIQ_DEPTH-1:0];//发射队列中所有指令的源寄存器2对应的物理寄存器编号

always@(*)begin
    for(i=0;i<ISSUE_NUM;i=i+1)begin
        arbit_prd[i] = ciq[arbit_addr[i]][PRD_MSB:PRD_LSB];
        arbit_prd_v[i] = ciq[arbit_addr[i]][PRDV];
    end
    for(j=0;j<CIQ_DEPTH;j=i+1)begin
        ciq_prs1[j] = ciq[j][PRS1_MSB:PRS1_LSB];
        ciq_prs2[j] = ciq[j][PRS2_MSB:PRS2_LSB];
    end
end
wake_up #(
    ISSUE_NUM,
    PRF_WIDTH,
    CIQ_DEPTH
)wake_up_u0(
    .arbit_prd(arbit_prd),
    .arbit_prd_v(arbit_prd_v),
    .ciq_prs1(ciq_prs1),
    .ciq_prs2(ciq_prs2),
    .arbit_grant(arbit_grant),
    .prs1_rdy(prs1_rdy),
    .prs2_rdy(prs2_rdy),
    .muti_finish(muti_finish) 
);
//////////////////////////////////////////////////////
endmodule
