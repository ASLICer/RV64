module rob#(
    parameter DATA_WIDTH = 64,
    
    parameter COMPLETE = 1,
    parameter AREG = 5,
    parameter PREG = 6,
    parameter OPREG = 6,
    parameter PC = DATA_WIDTH,
    parameter EXCEPTION = 1,
    parameter TYPE = 7

)
(
    input complete [DECODE_NUM-1:0]//
    input [AREG-1:0] areg [DECODE_NUM-1:0];//
    input [PREG-1:0] preg [DECODE_NUM-1:0];//
    input [OPREG-1:0]opreg[DECODE_NUM-1:0];//
    input [PC-1:0]   areg [DECODE_NUM-1:0];//
    input exception [DECODE_NUM-1:0];// 
    input [TYPE-1:0] type [DECODE_NUM-1:0];//   
);
reg [ROB_WIDTH-1:0] rob;//重排序缓存
endmodule