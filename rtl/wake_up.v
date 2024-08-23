module wake_up#(
    parameter ISSUE_NUM = 4,
    parameter PRF_WIDTH = 6,
    parameter CIQ_DEPTH = 16,
    parameter PRD_LSB,
    parameter PRD_MSB,
    parameter PRS1_LSB,
    parameter PRS1_MSB,
    parameter PRS2_LSB,
    parameter PRS2_MSB
)(
    //from issue_queue
    input [PRF_WIDTH-1:0] arbit_prd[ISSUE_NUM-1:0],
    input [PRF_WIDTH-1:0] ciq_prs1[CIQ_DEPTH-1:0],
    input [PRF_WIDTH-1:0] ciq_prs2[CIQ_DEPTH-1:0],
    //from arbiter
    input [3:0] arbit_addr [ISSUE_NUM-1:0],
    input [ISSUE_NUM-1:0] arbit_grant,
    //to issue_queue
    output reg prs1_rdy [CIQ_DEPTH-1:0],
    output reg prs2_rdy [CIQ_DEPTH-1:0]    
);
wire [PRF_WIDTH-1:0] tag_bus [ISSUE_NUM-1:0];
integer i;
always@(*)begin
    for(i=0;i<ISSUE_NUM;i=i+1)begin
        tag_bus[i] = arbit_grant[i] ? arbit_prd[i] : tag_bus[i];
    end
end

integer i,j;
//比较bus上的寄存器编号和发射队列的源寄存器编号，相等则唤醒，ready置1
always@(*)begin
    for(i=0;i<CIQ_DEPTH;i=i+1)begin
        for(j=0;j<ISSUE_NUM;j=i+1)begin
            if(tag_bus[j] == ciq_prs1[i])
                prs1_rdy[i] = 1'b1;
            if(tag_bus[j] == ciq_prs1[i])
                prs2_rdy[i] = 1'b1;
        end
    end         
end

endmodule