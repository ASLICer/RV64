module issue#(
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
    input reg [IQ_WIDTH-1:0] ciq [15:0]//16个表项的集中式发射队列
    //第一个操作数
    output [DATA_WIDTH-1:0] src0_alu0;
    output [DATA_WIDTH-1:0] src0_alu1;
    output [DATA_WIDTH-1:0] src0_mul;
    output [DATA_WIDTH-1:0] src0_ls;
    //第二个操作数 
    output [DATA_WIDTH-1:0] src1_alu0;
    output [DATA_WIDTH-1:0] src1_alu1;
    output [DATA_WIDTH-1:0] src1_mul;
    output [DATA_WIDTH-1:0] src1_ls;    
);
reg [IQ_WIDTH-1:0] ciq [15:0]//16个表项的集中式发射队列
wire [OPCODE_WIDTH-1:0] op [15:0];
reg req [15:0];
wire [AGE-1:0] age [15:0];
wire [4:0] addr_alu0;
wire [4:0] addr_alu1;
wire [4:0] addr_mul;
wire [4:0] addr_ls;
wire grant_alu0;
wire grant_alu1;
wire grant_mul;
wire grant_ls;

always@(*)begin
    for(i=0;i<16;i=i+1)
        req[i] = (~ciq[PRS1_V] | ciq[PRS1_RDY]) & (~ciq[PRS2_V] | ciq[PRS2_RDY]) & ~ciq[ISSUED];
end
//////////////////////仲裁电路//////////////////////////
arbiter arbiter_u0#(
    .OP(`ALU),
    .OPCODE_WIDTH(7),
    .REQ(1),
    .AGE_WIDTH(5)
)(
    op(op),
    req(req),
    age(age),
    grant(grant_alu0),
    addr(addr_alu0)
);//ALU0仲裁器
arbiter arbiter_u0#(
    .OP(`ALU),
    .OPCODE_WIDTH(7),
    .REQ(1),
    .AGE_WIDTH(5)
)(
    op,
    req,
    op(op),
    req(req),
    age(age),
    grant(grant_alu1),
    addr(addr_alu1)
);//ALU1仲裁器
arbiter arbiter_u0#(
    .OP(`MUL),
    .OPCODE_WIDTH(7),
    .REQ(1),
    .AGE_WIDTH(5)
)(
    op(op),
    req(req),
    age(age),
    grant(grant_mul),
    addr(addr_mul)
);//MUL仲裁器
arbiter arbiter_u0#(
    .OP(`LOAD_STORE),
    .OPCODE_WIDTH(7),
    .REQ(1),
    .AGE_WIDTH(5)
)(
    op(op),
    req(req),
    age(age),
    grant(grant_ls),
    addr(addr_ls)
);//LOAD_STORE仲裁器
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
    .ciq_prs1(ciq[PRS2_MSB:PRS2_LSB]),
    .addr_alu0(addr_alu0),
    .addr_alu1(addr_alu1),
    .addr_mul(addr_mul),
    .addr_ls(addr_ls),
    .grant_alu0(grant_alu0),
    .grant_alu1(grant_alu1),
    .grant_mul(grant_mul),
    .grant_ls(grant_ls),

    .prs1_rdy(),
    .prs2_rdy()   
);
//////////////////////////////////////////////////////
endmodule