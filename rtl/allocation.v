module allocation#(
    parameter INSTR_NUM = 4,
    parameter CIQ_DEPTH = 16
)(
    input [CIQ_DEPTH-1:0] ciq_free,//16个空闲标志位   
    output [3:0] free_addr [INSTR_NUM-1:0],//发射队列空闲表项的地址
    output [INSTR_NUM-1:0] free_valid//所在地址确实是空闲的   
);
assign free_addr[0] = first_c0 ;
assign free_addr[1] = second_c0;
assign free_addr[2] = third_c0 ;
assign free_addr[3] = fourth_c0;
assign free_valid[0] = v_first_c0 ;
assign free_valid[1] = v_second_c0;
assign free_valid[2] = v_third_c0 ;
assign free_valid[3] = v_fourth_c0;
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
//第二级处理电路
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
assign second_b1 = v_second_a2 ? {1'b0,second_a2} : (v_first_a2 ? {1'b1,first_a3} : {1'b1,second_a3});
assign v_second_b0 = v_second_a0 | v_second_a1 | (v_first_a0 & v_first_a1);
assign v_second_b1 = v_second_a2 | v_second_a3 | (v_first_a2 & v_first_a3);
/////////第三级电路//////////
assign second_c0 = v_second_b0 ? {1'b0,second_b0} : (v_first_b0 ? {1'b1,first_b1} : {1'b1,second_b1}) ;
assign v_second_c0 = v_second_b0 | v_second_b1 |(v_first_b0 & v_first_b1);
////////////////////////////////////////////////////////////////////
////////////////////////////////找第三个空闲表项////////////////////
//ciq_free[3:0]/ciq_free[7:4]/ciq_free[11:8]/ciq_free[15:12]中第三个1的位置,也可能没有第三个1
//第三个1不会位于ciq[0],a0[1:0] = ××;
//第三个1不会位于ciq[1],a0[1:0] = ××;
//第三个1位于ciq[2],a0[1:0] = 10;
//第三个1位于ciq[3],a0[1:0] = 11;
/////////第一级电路//////////
assign third_a0[0] = ~(ciq_free[2:0]    == 3'b111) ;
assign third_a1[0] = ~(ciq_free[6:4]    == 3'b111) ;
assign third_a2[0] = ~(ciq_free[10:8]   == 3'b111) ;
assign third_a3[0] = ~(ciq_free[14:12]  == 3'b111) ;
assign third_a0[1] = 1'b1;
assign third_a1[1] = 1'b1;
assign third_a2[1] = 1'b1;
assign third_a3[1] = 1'b1;
assign v_third_a0 = ((ciq_free[1:0]     == 2'b11) && (ciq_free[3:2] != 2'b00)) | ((ciq_free[3:2]    == 2'b11) && (ciq_free[1:0]  != 2'b00 ));
assign v_third_a1 = ((ciq_free[5:4]     == 2'b11) && (ciq_free[3:2] != 2'b00)) | ((ciq_free[7:6]    == 2'b11) && (ciq_free[5:4]  != 2'b00 ));
assign v_third_a2 = ((ciq_free[9:8]     == 2'b11) && (ciq_free[3:2] != 2'b00)) | ((ciq_free[11:8]   == 2'b11) && (ciq_free[9:8]  != 2'b00 ));
assign v_third_a3 = ((ciq_free[13:12]   == 2'b11) && (ciq_free[3:2] != 2'b00)) | ((ciq_free[15:12]  == 2'b11) && (ciq_free[13:12]!= 2'b00 ));
/////////第二级电路//////////
assign third_b0 = v_third_a0 ? {1'b0,third_a0} : (v_first_a0 ? {1'b1,second_a1} : (v_second_a0 ? {1'b1,first_a1} : {1'b1,third_a1}));
assign third_b1 = v_third_a2 ? {1'b0,third_a2} : (v_first_a2 ? {1'b1,second_a3} : (v_second_a2 ? {1'b1,first_a3} : {1'b1,third_a3}));
assign v_third_b0 = v_third_a0 | v_third_a1 | (v_first_a0 & v_second_a1) | (v_second_a0 & v_first_a1);
assign v_third_b1 = v_third_a2 | v_third_a3 | (v_first_a2 & v_second_a3) | (v_second_a2 & v_first_a3);
/////////第三级电路//////////
assign third_c0 = v_third_b0 ? {1'b0,third_b0} : (v_first_b0 ? {1'b1,second_b1} : (v_second_b0 ? {1'b1,first_b1} : {1'b1,third_b1})) ;
assign v_third_c0 = v_third_b0 | v_third_b1 |(v_first_b0 & v_second_b1) |(v_second_b0 & v_first_b1);
////////////////////////////////////////////////////////////////////
////////////////////////////////找第四个空闲表项////////////////////
//ciq_free[3:0]/ciq_free[7:4]/ciq_free[11:8]/ciq_free[15:12]中第三个1的位置,也可能没有第三个1
//第四个1不会位于ciq[0],a0[1:0] = ××;
//第四个1不会位于ciq[1],a0[1:0] = ××;
//第四个1不会位于ciq[2],a0[1:0] = ××;
//第四个1位于ciq[3],a0[1:0] = 11;
/////////第一级电路//////////
assign fourth_a0 = 2'b11;
assign fourth_a1 = 2'b11;
assign fourth_a2 = 2'b11;
assign fourth_a3 = 2'b11;
assign v_fourth_a0 = ((ciq_free[3:0]     == 4'b1111);
assign v_fourth_a1 = ((ciq_free[7:4]     == 4'b1111);
assign v_fourth_a2 = ((ciq_free[11:8]    == 4'b1111);
assign v_fourth_a3 = ((ciq_free[15:12]   == 4'b1111);
/////////第二级电路//////////
always@(*)begin
    if(v_fourth_a0)
        fourth_b0 = {1'b0,fourth_a0};
    else if(v_first_a0)
        fourth_b0 = {1'b1,third_a1};
    else if(v_second_a0)
        fourth_b0 = {1'b1,second_a1};
    else if(v_third_a0)
        fourth_b0 = {1'b1,first_a1};
    else    
        fourth_b0 = {1'b1,fourth_a1};
end
always@(*)begin
    if(v_fourth_a2)
        fourth_b1 = {1'b0,fourth_a2};
    else if(v_first_a2)
        fourth_b1 = {1'b1,third_a3};
    else if(v_second_a2)
        fourth_b1 = {1'b1,second_a3};
    else if(v_third_a2)
        fourth_b1 = {1'b1,first_a3};
    else    
        fourth_b1 = {1'b1,fourth_a3};
end

assign v_fourth_b0 = v_fourth_a0 | v_fourth_a1 | (v_first_a0 & v_third_a1) | (v_second_a0 & v_second_a1) | (v_third_a0 & v_first_a1);
assign v_fourth_b1 = v_fourth_a2 | v_fourth_a3 | (v_first_a2 & v_third_a3) | (v_second_a2 & v_second_a3) | (v_third_a2 & v_first_a3);
/////////第三级电路//////////
always@(*)begin
    if(v_fourth_b0)
        fourth_c0 = {1'b0,fourth_b0};
    else if(v_first_b0)
        fourth_c0 = {1'b1,third_b1};
    else if(v_second_b0)
        fourth_c0 = {1'b1,second_b1};
    else if(v_third_b0)
        fourth_c0 = {1'b1,first_b1};
    else
        fourth_c0 = {1'b1,fourth_b1};
end

assign v_ fourth_c0 = v_ fourth_b0 | v_ fourth_b1 |(v_first_b0 & v_third_b1) |(v_second_b0 & v_second_b1) |(v_third_b0 & v_first_b1);
////////////////////////////////////////////////////////////////////

endmodule