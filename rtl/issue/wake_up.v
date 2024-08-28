module wake_up#(
    parameter ISSUE_NUM = 4,
    parameter PRF_WIDTH = 6,
    parameter CIQ_DEPTH = 16
)(
    //from issue_queue
    input [PRF_WIDTH-1:0] arbit_prd[ISSUE_NUM-1:0],//被arbiter选中的指令的目的寄存器对应的物理寄存器编号
    input [ISSUE_NUM-1:0] arbit_prd_v,//被arbiter选中的指令是否有物理寄存器(避免误唤醒)
    input [PRF_WIDTH-1:0] ciq_prs1[CIQ_DEPTH-1:0],//发射队列中所有指令的源寄存器1对应的物理寄存器编号
    input [PRF_WIDTH-1:0] ciq_prs2[CIQ_DEPTH-1:0],//发射队列中所有指令的源寄存器2对应的物理寄存器编号
    //from arbiter
    input [ISSUE_NUM-1:0] arbit_grant,
    //to issue_queue
    output reg prs1_rdy [CIQ_DEPTH-1:0],
    output reg prs2_rdy [CIQ_DEPTH-1:0]    
);
wire [PRF_WIDTH-1:0] tag_bus [ISSUE_NUM-1:0];
integer i,j;
always@(*)begin
    for(i=0;i<ISSUE_NUM;i=i+1)begin
        if(i != 2)
            //tag_bus[i] = (arbit_grant[i] && arbit_prd_v[i]) ? arbit_prd[i] : tag_bus[i];//如果本周期bus对应的仲裁电路没有没有选出指令发射，bus置零
            tag_bus[i] = (arbit_grant[i] && arbit_prd_v[i]) ? arbit_prd[i] : 1'b0;//而不应该保持不变，保持不变可能会误唤醒，而0寄存器一直是准备好的
    end
end

//多周期指令专门用一条bus，bus在多周期指令倒数第三个执行周期更新，这时才可以用于唤醒其他指令
reg [4:0] cnt;//计数器，用于计数多周期指令已经执行的周期，假定mul/div需要32个周期
always@(posedge clk or posedge rst)begin
    if(rst)
        cnt <= 0;
    else if(cnt == 0)
        cnt <= arbit_grant[2] ? 1 : 0;//需要有效的仲裁来启动计数
    else
        cnt <= (cnt == 31) ? 0 : cnt + 1; //启动计数后，不再需要有效的仲裁来维持计数
    if(cnt == 31)
        tag_bus[2] <= arbit_prd[2];
    else
        tag_bus[2] <= 1'b0;
end 

//比较bus上的寄存器编号和发射队列的源寄存器编号，相等则唤醒，ready置1
always@(*)begin
    for(i=0;i<CIQ_DEPTH;i=i+1)begin
        for(j=0;j<ISSUE_NUM;j=i+1)begin
            prs1_rdy[i] = (tag_bus[j] == ciq_prs1[i]) ? 1'b1 : 1'b0;
            prs2_rdy[i] = (tag_bus[j] == ciq_prs2[i]) ? 1'b1 : 1'b0;
        end
    end         
end

endmodule