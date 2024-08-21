module issue_queue#(
    parameter OPCODE = 7,
    parameter PRF_WIDTH = 6,
    parameter VALID = 1,
    parameter READY = 1,
    parameter ISSUED = 1,
    parameter FREE = 1,
    parameter AGE = 5
    parameter IQ_WIDTH =OPCODE+3*PRF_WIDTH+3*VALID+2*READY+ISSUED+FREE+AGE
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
    input [PRF_WIDTH-1:0] instr3_prd，

);
reg [IQ_WIDTH-1:0] ciq [15:0];//16个表项的集中式发射队列
wire [3:0] free0_addr;
wire [3:0] free1_addr;
wire [3:0] free2_addr;
wire [3:0] free3_addr;
//找到4个空闲表项写入指令
always@(posedge clk)begin
    ciq[free0_addr] <= {instr0_op,instr0_prs1,instr0_prs1_v,instr0_prs1_rdy,instr0_prs2,instr0_prs2_v,instr0_prs2_rdy,instr0_prd,instr0_prd_v，2'b00,instr0_age};    
    ciq[free1_addr] <= {instr1_op,instr1_prs1,instr1_prs1_v,instr1_prs1_rdy,instr1_prs2,instr1_prs2_v,instr1_prs2_rdy,instr1_prd,instr1_prd_v，2'b00,instr1_age};
    ciq[free2_addr] <= {instr2_op,instr2_prs1,instr2_prs1_v,instr2_prs1_rdy,instr2_prs2,instr2_prs2_v,instr2_prs2_rdy,instr2_prd,instr2_prd_v，2'b00,instr2_age};
    ciq[free3_addr] <= {instr3_op,instr3_prs1,instr3_prs1_v,instr3_prs1_rdy,instr3_prs2,instr3_prs2_v,instr3_prs2_rdy,instr3_prd,instr3_prd_v，2'b00,instr3_age};    
end
//找到4个空闲表项，将16个free信号分解，逐级进行解决
//第一级处理电路
wire [1:0] first_a3     ,first_a2   ,first_a1   ,first_a0   ;
wire [1:0] second_a3    ,second_a2  ,second_a1  ,second_a0  ;
wire [1:0] third_a3     ,third_a2   ,third_a1   ,third_a0   ;
wire [1:0] fourth_a3    ,fourth_a2  ,fourth_a1  ,fourth_a0  ;
wire v_first_a3     ,v_first_a2   ,v_first_a1   ,v_first_a0   ;
wire v_second_a3    ,v_second_a2  ,v_second_a1  ,v_second_a0  ;
wire v_third_a3     ,v_third_a2   ,v_third_a1   ,v_third_a0   ;
wire v_fourth_a3    ,v_fourth_a2  ,v_fourth_a1  ,v_fourth_a0  ;
//第一级处理电路
wire [2:0] first_b1     ,first_b0   ;
wire [2:0] second_b1    ,second_b0  ;
wire [2:0] third_b1     ,third_b0   ;
wire [2:0] fourth_b1    ,fourth_b0  ;
wire v_first_b1     ,v_first_b0   ;
wire v_second_b1    ,v_second_b0  ;
wire v_third_b1     ,v_third_b0   ;
wire v_fourth_b1    ,v_fourth_b0  ;
//第三级电路
wire [3:0] first_c0 ;
wire [3:0] second_c0;
wire [3:0] third_c0 ;
wire [3:0] fourth_c0;
wire v_first_c0 ;
wire v_second_c0;
wire v_third_c0 ;
wire v_fourth_c0;
////////////////////////////////找第一个空闲表项////////////////////
//ciq_free[3:0]/ciq_free[7:4]/ciq_free[11:8]/ciq_free[15:12]中第一个1的位置,也可能没有第一个1
//第一个1位于ciq[0],a0[1:0] = 00;
//第一个1位于ciq[1],a0[1:0] = 01;
//第一个1位于ciq[2],a0[1:0] = 10;
//第一个1位于ciq[3],a0[1:0] = 11;
/////////第一级电路//////////
assign first_a0[0] = (ciq_free[1:0]     == 2'b10) | (ciq_free[3:2]  == 2'b10 & ~ciq_free[0]);
assign first_a1[0] = (ciq_free[5:4]     == 2'b10) | (ciq_free[7:6]  == 2'b10 & ~ciq_free[4]);
assign first_a2[0] = (ciq_free[9:8]     == 2'b10) | (ciq_free[11:8] == 2'b10 & ~ciq_free[8]);
assign first_a3[0] = (ciq_free[13:12]   == 2'b10) | (ciq_free[15:12]== 2'b10 & ~ciq_free[12]);
assign first_a0[1] = (ciq_free[1:0] == 2'b00);
assign first_a1[1] = (ciq_free[5:4] == 2'b00);
assign first_a2[1] = (ciq_free[9:8] == 2'b00);
assign first_a3[1] = (ciq_free[13:12] == 2'b00);
assign v_first_a0 = |ciq_free[1:0];
assign v_first_a1 = |ciq_free[5:4];
assign v_first_a2 = |ciq_free[9:8];
assign v_first_a3 = |ciq_free[13:12];
/////////第二级电路//////////
assign first_b0 = v_first_a0 ? {1'b0,first_a0} : {1'b1,first_a1};
assign first_b1 = v_first_a2 ? {1'b0,first_a2} : {1'b1,first_a3};
assign v_first_b0 = v_first_a0 | v_first_a1;
assign v_first_b1 = v_first_a2 | v_first_a3;
/////////第三级电路//////////
assign first_c0 = v_first_b0 ? {1'b0,first_b0} : {1'b1,first_b1} ;
assign v_first_c0 = v_first_b0 | v_first_b1;
////////////////////////////////////////////////////////////////////
////////////////////////////////找第二个空闲表项////////////////////
//ciq_free[3:0]/ciq_free[7:4]/ciq_free[11:8]/ciq_free[15:12]中第二个1的位置,也可能没有第二个1
//第二个1不会位于ciq[0],a0[1:0] = ××;
//第二个1位于ciq[1],a0[1:0] = 01;
//第二个1位于ciq[2],a0[1:0] = 10;
//第二个1位于ciq[3],a0[1:0] = 11;
/////////第一级电路//////////
assign second_a0[0] = (ciq_free[1:0]    == 2'b00) | (ciq_free[1:0]      == 2'b11） ~ciq_free[2]);
assign second_a1[0] = (ciq_free[5:4]    == 2'b00) | (ciq_free[5:4]      == 2'b11） ~ciq_free[6]);
assign second_a2[0] = (ciq_free[9:8]    == 2'b00) | (ciq_free[9:8]      == 2'b11） ~ciq_free[10]);
assign second_a3[0] = (ciq_free[13:12]  == 2'b00) | (ciq_free[13:12]    == 2'b11） ~ciq_free[14]);
assign second_a0[1] = ~(ciq_free[1:0]    == 2'b11);
assign second_a1[1] = ~(ciq_free[5:4]    == 2'b11);
assign second_a2[1] = ~(ciq_free[9:8]    == 2'b11);
assign second_a3[1] = ~(ciq_free[13:12]  == 2'b11);
assign v_second_a0 = (ciq_free[1:0]     == 2'b11) | (ciq_free[3:2]    == 2'b11) | ~(ciq_free[1:0]  == 2'b00 | ciq_free[3:2]    == 2'b00);
assign v_second_a1 = (ciq_free[5:4]     == 2'b11) | (ciq_free[7:6]    == 2'b11) | ~(ciq_free[5:4]  == 2'b00 | ciq_free[7:6]    == 2'b00);
assign v_second_a2 = (ciq_free[9:8]     == 2'b11) | (ciq_free[11:8]   == 2'b11) | ~(ciq_free[9:8]  == 2'b00 | ciq_free[11:8]   == 2'b00);
assign v_second_a3 = (ciq_free[13:12]   == 2'b11) | (ciq_free[15:12]  == 2'b11) | ~(ciq_free[13:12]== 2'b00 | ciq_free[15:12]  == 2'b00);
/////////第二级电路//////////
assign second_b0 = v_second_a0 ? {1'b0,second_a0} : (v_first_a0 ? {1'b1,first_a1} : {1'b1,second_a1});
assign second_b1 = v_second_a2 ? {1'b0,second_a1} : (v_first_a0 ? {1'b1,first_a1} : {1'b1,second_a1});
assign v_second_b0 = v_first_a0 | v_first_a1;
assign v_second_b1 = v_first_a2 | v_first_a3;
/////////第三级电路//////////
assign second_c0 = v_first_b0 ? {1'b0,first_b0} : {1'b1,first_b1} ;
assign v_second_c0 = v_first_b0 | v_first_b1;
////////////////////////////////////////////////////////////////////
endmoudle