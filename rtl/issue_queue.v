module issue_queue#(
    parameter INSTR_NUM = 4,
    parameter ISSUE_NUM = 4,
    parameter CIQ_DEPTH = 16,
    parameter OPCODE = 7,
    parameter PRF_WIDTH = 6,
    parameter VALID = 1,
    parameter READY = 1,
    parameter ISSUED = 1,
    parameter FREE = 1,
    parameter AGE = 5,
    parameter IQ_WIDTH = OPCODE+3*PRF_WIDTH+3*VALID+2*READY+ISSUED+FREE+AGE,

    parameter PRS1_RDY,
    parameter PRS2_RDY
)(
    input clk,
    //from rename   
    input [OPCODE-1:0] instr_op[INSTR_NUM-1:0],//指令的opcode
    input instr_prs1_v[INSTR_NUM-1:0],//指令是否有来自源寄存器1操作数
    input instr_prs2_v[INSTR_NUM-1:0],//指令是否有来自源寄存器2操作数  
    input instr_prd_v[INSTR_NUM-1:0],//指令是否有目的寄存器     
    input [PRF_WIDTH-1:0] instr_prs1[INSTR_NUM-1:0],//源寄存器1对应的物理寄存器编号
    input [PRF_WIDTH-1:0] instr_prs2[INSTR_NUM-1:0],//源寄存器2对应的物理寄存器编号  
    input [PRF_WIDTH-1:0] instr_prd[INSTR_NUM-1:0],//目的寄存器对应的物理寄存器编号
    input [AGE-1:0] age [INSTR_NUM-1:0];//指令的年龄
    //from allocation  
    input [3:0] free_addr [INSTR_NUM-1:0],//发射队列空闲表项的地址  
    input [INSTR_NUM-1:0] free_valid,//所在地址确实是空闲的
    //from aribiter
    input [3:0] arbit_addr [ISSUE_NUM-1:0],//仲裁出的指令所在发射队列地址
    input [ISSUE_NUM-1:0] arbit_grant;//仲裁出的结果是有效的
    //from wake up
    input prs1_rdy [CIQ_DEPTH-1:0],//唤醒电路得到的源寄存器1的ready信号
    input prs2_rdy [CIQ_DEPTH-1:0],//唤醒电路得到的源寄存器2的ready信号
    output reg [IQ_WIDTH-1:0] ciq [CIQ_DEPTH-1:0]//16个表项的集中式发射队列
);


//找到空闲表项将重命名后的指令写入发射队列
always@(posedge clk)begin
    for(i=0;i<INSTR_NUM;i=i+1)
        if(free_valid[i])
            ciq[free_addr[i]] <= {instr_op[i],instr_prs1[i],instr_prs1_v[i],instr_prs1_rdy[i],instr_prs2[i],instr_prs2_v[i],instr_prs2_rdy[i],instr_prd[i],instr_prd_v[i],instr_age[i],2'b00};  
end

integer i,j;
//根据仲裁电路结果更新issued信号
always@(posedge clk)begin
    for(i=0;i<CIQ_DEPTH;i=i+1)begin
        for(j=0;j<ISSUE_NUM;j=j+1)begin
            if(i == arbit_addr[j] && arbit_grant[j])
                ciq[i][ISSUED] == 1'b1;//表明该指令已经被选择发射
        end 
    end
end
//根据唤醒电路结果更新ready信号
always@(posedge clk)begin
    for(i=0;i<CIQ_DEPTH;i=i+1)
        if(ciq[i][0] = 1'b0)begin//该表项不是空闲的
            ciq[i][PRS1_RDY] = instr_prs1_rdy[i];
            ciq[i][PRS2_RDY] = instr_prs2_rdy[i];
        end
end
endmoudle