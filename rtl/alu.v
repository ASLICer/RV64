`include "./rtl/define.v"
module alu#(parameter DATA_WIDTH=64)
(
	input [DATA_WIDTH-1:0] ALU_DA,
	input [DATA_WIDTH-1:0]  ALU_DB,
	input [4:0]  ALU_CTL,
	output ALU_ZERO,
	output ALU_OverFlow,
	output reg [DATA_WIDTH-1:0] ALU_DC
);		   
//********************generate ctr***********************
wire SUBctr;		//only sub/slt/sltu use substraction
wire SLTctr;		//distinguish slt and sltu
wire Ovctr;			//overflow only happen in add/sub
wire [1:0] Opctr;	//4 types of operations(arithmetic/logic/slt/shift)

assign Opctr 	= ALU_CTL[3:2];
assign SUBctr 	= (ALU_CTL == `SUB) | (ALU_CTL == `SLT) | (ALU_CTL == `SLTU) | (ALU_CTL == `SUBW);
assign Ovctr 	= (ALU_CTL == `SUB) | (ALU_CTL == `ADD) | (ALU_CTL == `SUBW) | (ALU_CTL == `ADDW);
assign SLTctr 	= (ALU_CTL == `SLT);

//********************************************************
//*********************logic op***************************
reg [DATA_WIDTH-1:0] logic_result;
always@(*) begin
    case(ALU_CTL)
		`AND:	logic_result = ALU_DA & ALU_DB;
		`OR:	logic_result = ALU_DA | ALU_DB;
		`XOR:	logic_result = ALU_DA ^ ALU_DB;
		default:logic_result = {(DATA_WIDTH){1'b0}};
	endcase
end 
//********************************************************
//************************shift op************************
wire [5:0] ALU_SHIFT;
reg [DATA_WIDTH-1:0] shift_result;
reg [DATA_WIDTH-1:0] shiftw_result;

assign ALU_SHIFT = (ALU_CTL[4] | DATA_WIDTH==32) ? {1'b0,ALU_DB[4:0]} : ALU_DB[5:0];

always@(*) begin
  case(ALU_CTL)
	`SLL:	shift_result = ALU_DA << ALU_SHIFT;
 	`SRL:	shift_result = ALU_DA >> ALU_SHIFT;
 	`SRA:	shift_result = ($signed(ALU_DA)) >>> ALU_SHIFT;
	default:shift_result = {(DATA_WIDTH){1'b0}};
  endcase
end
always@(*) begin
  case(ALU_CTL)
	`SLLW:	shiftw_result = ALU_DA[31:0] << ALU_SHIFT;
 	`SRLW:	shiftw_result = ALU_DA[31:0] >> ALU_SHIFT;
 	`SRAW:	shiftw_result = ($signed(ALU_DA[31:0])) >>> ALU_SHIFT;	
	default:shiftw_result = {(DATA_WIDTH){1'b0}};
  endcase
end

//********************************************************
//************************add sub op**********************
wire ADD_carry;
wire ADD_OverFlow;
wire [DATA_WIDTH-1:0] ALU_DB_ones_compl;
wire [DATA_WIDTH-1:0] ADD_result;

assign ALU_DB_ones_compl = SUBctr ? ~ALU_DB : ALU_DB;

Adder #(.DATA_WIDTH(DATA_WIDTH))
Adder_u0
(
 .A(ALU_DA),
 .B(ALU_DB_ones_compl),
 .Cin(SUBctr),//if execute add,Cin=0;if execute sub Cin=1.
 .ALU_CTL(ALU_CTL),
 .ADD_carry(ADD_carry),
 .ADD_OverFlow(ADD_OverFlow),
 .ADD_zero(ALU_ZERO),
 .ADD_result(ADD_result)
);

assign ALU_OverFlow = ADD_OverFlow & Ovctr;

//********************************************************
//**************************slt op************************
wire [DATA_WIDTH-1:0] SLT_result;
wire less_sltu;
wire less_slt;
wire less;

assign less_sltu = ~ADD_carry;//sltu
assign less_slt = ADD_OverFlow ^ ADD_result[DATA_WIDTH-1];//slt
assign less = (SLTctr == 1'b0) ? less_sltu : less_slt;
assign SLT_result = less ? {{(DATA_WIDTH-1){1'b0}},1'b1} : {(DATA_WIDTH){1'b0}};

//*******************************************************
//**************************ALU result********************
always @(*) begin
  case(Opctr)
     2'b00:ALU_DC = ALU_CTL[4] ? {{32{ADD_result[31]}},ADD_result[31:0]} : ADD_result[DATA_WIDTH-1:0];
     2'b01:ALU_DC = logic_result;
     2'b10:ALU_DC = SLT_result;
     2'b11:ALU_DC = ALU_CTL[4] ? {{32{shiftw_result[31]}},shiftw_result[31:0]} : shift_result;
	 default:ALU_DC = {(DATA_WIDTH){1'b0}};
  endcase
end

endmodule



