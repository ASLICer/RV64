module arbiter#(
    parameter OPCODE_WIDTH = 7,
    parameter REQ = 1,
    parameter AGE_WIDTH = 5
)(
	input [OPCODE_WIDTH-1:0] op_correct,
    input [OPCODE_WIDTH-1:0] op [15:0],
    input [15:0] req ,
    input [AGE_WIDTH-1:0] age [15:0],

    output grant,//请求发射成功
    output [3:0] addr,
    input muti_finish
);//最小的年龄值对应最旧的指令
//各级的有效请求
reg [15:0]req16;
reg [7:0] req8 ;
reg [3:0] req4 ;
reg [1:0] req2 ;
//各级的最小的年龄值
reg [AGE_WIDTH-1:0] age8 [7:0];
reg [AGE_WIDTH-1:0] age4 [3:0];
reg [AGE_WIDTH-1:0] age2 [1:0];
reg [AGE_WIDTH-1:0] age1;
//各级的最小年龄值对应的指令所在发射队列地址
reg [3:0] addr8 [7:0];
reg [3:0] addr4 [3:0];
reg [3:0] addr2 [1:0];
reg [3:0] addr1;
assign addr = addr1;
assign grant = (| req16) && (((op_correct != `MD_type) | (op_correct != `MDW_type)) | muti_finish);//16个请求中至少有一个有效,如果是多周期指令arbiter，需要等上一条指令多周期指令执行完毕
integer i;
always@(*)begin
    for(i=0;i<16;i=i+1)
        req16[i] = (op[i] == op_correct) & req[i]; 
    for(i=0;i<8;i=i+1)
        req8[i] = req16[i*2] | req16[i*2+1]; 
    for(i=0;i<4;i=i+1)
        req4[i] = req8[i*2] | req8[i*2+1]; 
    for(i=0;i<2;i=i+1)
        req2[i] = req4[i*2] | req4[i*2+1]; 
end

always@(*)begin
    for(i=0;i<8;i=i+1)begin
        case({req16[i*2+1],req16[i*2]})
            2'b00:age8[i] = age[i*2];
            2'b01:age8[i] = age[i*2];
            2'b10:age8[i] = age[i*2+1];
            2'b11:age8[i] = (age[i*2] < age[i*2+1]) ? age[i*2] : age[i*2+1];
        endcase
    end 
    for(i=0;i<4;i=i+1)begin
        case({req8[i*2+1],req8[i*2]})
            2'b00:age4[i] = age8[i*2];
            2'b01:age4[i] = age8[i*2];
            2'b10:age4[i] = age8[i*2+1];
            2'b11:age4[i] = (age8[i*2] < age8[i*2+1]) ? age8[i*2] : age8[i*2+1];
        endcase
    end 
    for(i=0;i<2;i=i+1)begin
        case({req4[i*2+1],req4[i*2]})
            2'b00:age2[i] = age4[i*2];
            2'b01:age2[i] = age4[i*2];
            2'b10:age2[i] = age4[i*2+1];
            2'b11:age2[i] = (age4[i*2] < age4[i*2+1]) ? age4[i*2] : age4[i*2+1];
        endcase
    end 
    case({req2[1],req2[0]})
        2'b00:age1 = age2[0];
        2'b01:age1 = age2[0];
        2'b10:age1 = age2[1];
        2'b11:age1 = (age2[0] < age2[1]) ? age2[0] : age2[1];
    endcase
end
always@(*)begin
    for(i=0;i<8;i=i+1)begin
        case({req16[i*2+1],req16[i*2]})
            2'b00:addr8[i] = i*2;
            2'b01:addr8[i] = i*2;
            2'b10:addr8[i] = i*2+1;
            2'b11:addr8[i] = (age[i*2] < age[i*2+1]) ? i*2 : i*2+1;
        endcase
    end 
    for(i=0;i<4;i=i+1)begin
        case({req8[i*2+1],req8[i*2]})
            2'b00:addr4[i] = addr8[i*2];
            2'b01:addr4[i] = addr8[i*2];
            2'b10:addr4[i] = addr8[i*2+1];
            2'b11:addr4[i] = (age8[i*2] < age8[i*2+1]) ? addr8[i*2] : addr8[i*2+1];
        endcase
    end 
    for(i=0;i<2;i=i+1)begin
        case({req4[i*2+1],req4[i*2]})
            2'b00:addr2[i] = addr4[i*2];
            2'b01:addr2[i] = addr4[i*2];
            2'b10:addr2[i] = addr4[i*2+1];
            2'b11:addr2[i] = (age4[i*2] < age4[i*2+1]) ? addr4[i*2] : addr4[i*2+1];
        endcase
    end 
    case({req2[1],req2[0]})
        2'b00:addr1 = addr2[0];
        2'b01:addr1 = addr2[0];
        2'b10:addr1 = addr2[1];
        2'b11:addr1 = (age2[0] < age2[1]) ? addr2[0] : addr2[1];
    endcase
end
endmodule

