module wake_up#(
    parameter PRF_WIDTH = 6,
    parameter PRD_LSB,
    parameter PRD_MSB,
    parameter PRS1_LSB,
    parameter PRS1_MSB,
    parameter PRS2_LSB,
    parameter PRS2_MSB
)(
    input [PRF_WIDTH-1:0] ciq_prd[15:0],
    input [PRF_WIDTH-1:0] ciq_prs1[15:0],
    input [PRF_WIDTH-1:0] ciq_prs2[15:0],
    input [4:0] addr_alu0,
    input [4:0] addr_alu1,
    input [4:0] addr_mul,
    input [4:0] addr_ls,
    input grant_alu0;
    input grant_alu1;
    input grant_mul;
    input grant_ls;

    output prs1_rdy [15:0],
    output prs2_rdy [15:0]    
);
wire [PRF_WIDTH-1:0] tag_bus0;
wire [PRF_WIDTH-1:0] tag_bus1;
wire [PRF_WIDTH-1:0] tag_bus2;
wire [PRF_WIDTH-1:0] tag_bus3;
assign tag_bus0 = grant_alu0 ? ciq_prd[addr_alu0] : tag_bus0;
assign tag_bus1 = grant_alu1 ? ciq_prd[addr_alu1] : tag_bus1;
assign tag_bus2 = grant_mul  ? ciq_prd[addr_mul]  : tag_bus2;
assign tag_bus3 = grant_ls   ? ciq_prd[addr_ls]   : tag_bus3;
integer i;
always@(*)begin
    for(i=0;i<16;i=i+1)begin
        prs1_rdy[i] = (tag_bus0 == ciq_prs1[i]) | (tag_bus1 == ciq_prs1[i]) | (tag_bus2 == ciq_prs1[i]) | (tag_bus3 == ciq_prs1[i]);
        prs2_rdy[i] = (tag_bus0 == ciq_prs2[i]) | (tag_bus1 == ciq_prs2[i]) | (tag_bus2 == ciq_prs2[i]) | (tag_bus3 == ciq_prs2[i]);
    end
end

endmodule