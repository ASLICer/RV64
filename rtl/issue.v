module issue(
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

wire [OPCODE_WIDTH-1:0] op [15:0];
wire req [15:0];
wire [AGE-1:0] age [15:0];
wire [4:0] addr_alu0;
wire [4:0] addr_alu1;
wire [4:0] addr_mul;
wire [4:0] addr_ls;
arbiter arbiter_u0#(
    .OP(`ALU),
    .OPCODE_WIDTH(7),
    .REQ(1),
    .AGE_WIDTH(5)
)(
    op(op),
    req(req),
    age(age),
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
    addr(addr_ls)
);//LOAD_STORE仲裁器


endmodule