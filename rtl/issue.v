module issue#(
    parameter INSTR_NUM = 4,
    parameter ISSUE_NUM = 4,
    parameter CIQ_DEPTH = 16,
    parameter OPCODE = 7,
    parameter PRF_WIDTH = 6,
    parameter VALID = 1,
    parameter READY = 1,
    parameter ISSUED = 1,
    parameter FREE = 1,
    parameter AGE_WIDTH = 5,
    parameter IQ_WIDTH = OPCODE+3*PRF_WIDTH+3*VALID+2*READY+ISSUED+FREE+AGE

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
    parameter OP_MSB = OP_LSB+OPCODE_WIDTH-1,

)(
    input clk,
    //指令的opcode
    input [OPCODE-1:0] instr_op [INSTR_NUM-1:0],
    //指令是否有源寄存器操作数
    input instr_prs1_v [INSTR_NUM-1:0],
    input instr_prs2_v [INSTR_NUM-1:0],
    //指令是否有目的寄存器
    input instr_prd_v [INSTR_NUM-1:0],   
    //源寄存器的物理寄存器编号
    input [PRF_WIDTH-1:0] instr_prs1 [INSTR_NUM-1:0],
    input [PRF_WIDTH-1:0] instr_prs2 [INSTR_NUM-1:0],
    //目的寄存器的物理寄存器编号
    input [PRF_WIDTH-1:0] instr_prd [INSTR_NUM-1:0],
    //第一个操作数
    output [DATA_WIDTH-1:0] src0 [INSTR_NUM-1:0],
    //第二个操作数 
    output [DATA_WIDTH-1:0] src1 [INSTR_NUM-1:0]   
);
reg [IQ_WIDTH-1:0] ciq [CIQ_DEPTH-1:0];//16个表项的集中式发射队列

//////////////////////分配电路(寻找发射队列空闲表项)//////////////////////////
//发射队列空闲表项的地址
wire [3:0] free_addr [INSTR_NUM-1:0];
//所在地址确实是空闲的
wire [INSTR_NUM-1:0] free_valid; 
reg [CIQ_DEPTH-1:0] ciq_free;//16个空闲标志位
integer i;
always@(*)begin
    for(i=0;i<CIQ_DEPTH;i=i+1)
        ciq_free[i] = ciq[i][0];
end
allocation allocation_u0(
    ciq_free,
    //发射队列空闲表项的地址
    free_addr,
    //所在地址确实是空闲的
    free_valid  
);
////////////////////////////////////////////////
////////////////////发射队列////////////////////////
issue_queue issue_queue_u0#(
    INSTR_NUM，
    ISSUE_NUM,
    CIQ_DEPTH,
    OPCODE,
    PRF_WIDTH,
    VALID,
    READY,
    ISSUED,
    FREE,
    AGE,
    IQ_WIDTH
)(
    clk,
    //指令的opcode
    instr_op,
    //指令是否有源操作数
    instr_prs1_v,
    instr_prs2_v,
    //指令是否有目的寄存器
    instr_prd_v,   
    //源寄存器的物理寄存器编号
    instr_prs1,
    instr_prs2,
    //目的寄存器的物理寄存器编号
    instr_prd,
    //发射队列空闲表项的地址
    free_addr,
    //所在地址确实是空闲的
    free_valid
    //唤醒电路得到的源寄存器ready信号
    prs1_rdy,
    prs1_rdy,
    //16个表项的集中式发射队列
    ciq
);
////////////////////////////////////////////////
//////////////////////仲裁电路//////////////////////////
wire [OPCODE_WIDTH-1:0] op [CIQ_DEPTH-1:0];//发射队列所有表项的opcode
reg  [CIQ_DEPTH-1:0] req;//发射队列所有表项的请求信号
wire [AGE-1:0] age [CIQ_DEPTH-1:0];//发射队列所有表项的年龄
wire [3:0] arbit_addr [ISSUE_NUM-1:0];//仲裁出的指令所在发射队列地址
wire [ISSUE_NUM-1:0] arbit_grant;//仲裁出的结果是有效的
wire [6:0] OP [ISSUE_NUM-1:0];
always@(*)begin
    OP[0] = `ALU;
    OP[1] = `ALU;
    OP[2] = `MUL;
    OP[3] = `LOAD;  
end
always@(*)begin
    for(i=0;i<CIQ_DEPTH;i=i+1)
        req[i] = (~ciq[PRS1_V] | ciq[PRS1_RDY]) & (~ciq[PRS2_V] | ciq[PRS2_RDY]) & ~ciq[ISSUED] & ~ciq[FREE];
end
genvar i;
generate
    for(i=0;i<ISSUE_NUM;i=i+1)begin:arbiter_group
        arbiter arbiter_block#(
            .OP(OP[i]),
            .OPCODE_WIDTH(7),
            .REQ(1),
            .AGE_WIDTH(5)
        )(
            .op(op),
            .req(req),
            .age(age),
            .grant(arbit_grant[i]),
            .addr(arbit_addr[i])
        );
    end
endgenerate
//////////////////////////////////////////////////////
///////////////////唤醒电路/////////////////////////
wire prs1_rdy [15:0];
wire prs2_rdy [15:0];
wake_up wake_up_u0#(
    PRF_WIDTH,
    PRD_LSB,
    PRD_MSB,
    PRS1_LSB,
    PRS1_MSB,
    PRS2_LSB,
    PRS2_MSB
)(
    .ciq_prd(ciq[PRD_MSB:PRD_LSB]),
    .ciq_prs1(ciq[PRS1_MSB:PRS1_LSB]),
    .ciq_prs2(ciq[PRS2_MSB:PRS2_LSB]),
    .addr_alu0(addr_alu0),
    .addr_alu1(addr_alu1),
    .addr_mul(addr_mul),
    .addr_ls(addr_ls),
    .grant_alu0(grant_alu0),
    .grant_alu1(grant_alu1),
    .grant_mul(grant_mul),
    .grant_ls(grant_ls),

    .prs1_rdy(prs1_rdy),
    .prs2_rdy(prs2_rdy)   
);
//////////////////////////////////////////////////////
endmodule