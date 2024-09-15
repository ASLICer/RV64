module alu(
	   ALU_DA,
       ALU_DB,
       ALU_CTL,
       ALU_ZERO,
       ALU_OverFlow,
       ALU_DC   
);
input 		[31:0]    	ALU_DA;
input 		[31:0]    	ALU_DB;
input 		[3:0]     	ALU_CTL;
output					ALU_ZERO;
output					ALU_OverFlow;
output reg 	[31:0]   	ALU_DC;
		   
//********************generate ctr***********************
wire 					SUBctr;		//only sub and slt use substraction
wire 					SIGctr;		//distinguish slt and sltu
wire 					Ovctr;		//overflow only happen in add and sub
wire 		[1:0] 		Opctr;		//4 types of operations
wire 		[1:0] 		Logicctr;	//3 types of logical operations 
wire 		[1:0] 		Shiftctr;	//3 types of shifting operations

assign SUBctr 	= (~ ALU_CTL[3]  & ~ALU_CTL[2]  & ALU_CTL[1]) | ( ALU_CTL[3]  & ~ALU_CTL[2]);
assign Opctr 	= ALU_CTL[3:2];
assign Ovctr 	= ALU_CTL[0] & ~ ALU_CTL[3]  & ~ALU_CTL[2] ;
assign SIGctr 	= ALU_CTL[0];
assign Logicctr = ALU_CTL[1:0]; 
assign Shiftctr = ALU_CTL[1:0]; 

//********************************************************

//*********************logic op***************************
reg [31:0] logic_result;

always@(*) begin
    case(Logicctr)
	2'b00:logic_result = ALU_DA 	& 	ALU_DB;
	2'b01:logic_result = ALU_DA 	| 	ALU_DB;
	2'b10:logic_result = ALU_DA 	^ 	ALU_DB;
	default:logic_result = logic_result;
	endcase
end 

//********************************************************
//************************shift op************************
wire [4:0]	ALU_SHIFT;
wire [31:0] shift_result;
assign ALU_SHIFT=ALU_DB[4:0];

Shifter Shifter(.ALU_DA(ALU_DA),
                .ALU_SHIFT(ALU_SHIFT),
				.Shiftctr(Shiftctr),
				.shift_result(shift_result));

//********************************************************
//************************add sub op**********************
wire [31:0] BIT_M;
wire [31:0]	XOR_M;
wire 		ADD_carry;
wire 		ADD_OverFlow;
wire [31:0] ADD_result;

assign BIT_M={32{SUBctr}};//if SUBctr=0,XOR_M=ALU_DB;else XOR_M= -ALU_DB.
assign XOR_M=BIT_M^ALU_DB;

Adder Adder(.A(ALU_DA),
            .B(XOR_M),
			.Cin(SUBctr),//if execute add,Cin=0;else Cin=1.
			.ALU_CTL(ALU_CTL),
			.ADD_carry(ADD_carry),
			.ADD_OverFlow(ADD_OverFlow),
			.ADD_zero(ALU_ZERO),
			.ADD_result(ADD_result));

assign ALU_OverFlow = ADD_OverFlow & Ovctr;

//********************************************************
//**************************slt op************************
wire [31:0] SLT_result;
wire 		LESS_M1;
wire 		LESS_M2;
wire		LESS_S;

assign LESS_M1 		= ~ADD_carry;//sltu
assign LESS_M2 		= ADD_OverFlow ^ ADD_result[31];//slt
assign LESS_S 		= (SIGctr==1'b0)?LESS_M1:LESS_M2;
assign SLT_result	= (LESS_S)?32'h00000001:32'h00000000;

//*******************************************************
//**************************ALU result********************
always @(*) 
begin
  case(Opctr)
     2'b00:ALU_DC<=ADD_result;
     2'b01:ALU_DC<=logic_result;
     2'b10:ALU_DC<=SLT_result;
     2'b11:ALU_DC<=shift_result; 
  endcase
end

endmodule



