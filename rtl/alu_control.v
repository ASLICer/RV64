`include "./rtl/define.v" 
module alu_control(
	input	[2:0]	aluop,
	input 	[2:0]	func3,
	input 			func7,
	output reg	[4:0]	aluctl
);

wire	[4:0]	branchop;
reg 	[4:0]	RIop;
reg 	[4:0]	RIWop;
assign	branchop	=	(func3[2] & func3[1]) ? `SLTU	:	//bltu bgeu
						(func3[2] & ~func3[1]) ? `SLT 	:	//blt  bge
						`SUB;								//beq  bne

always@(*)begin
	case(func3)
		3'b000	:	RIop=((aluop == 3'b000 | aluop == 3'b011) & func7) ? `SUB :`ADD;//only R_type/Rw_type has sub
		3'b001	:	RIop=`SLL;
		3'b010	:	RIop=`SLT;
		3'b011	:	RIop=`SLTU;
		3'b100	:	RIop=`XOR;
		3'b101	:	RIop=((aluop == 3'b000 | aluop == 3'b001 | aluop == 3'b011) & func7) ? `SRA : `SRL;//only R_type/I_type/RIw_type  has SRA/SRL
		3'b110	:	RIop=`OR;
		3'b111	:	RIop=`AND;
		default	:	RIop=`ADD;			
	endcase
end

always@(*)begin
	case(func3)
		3'b000	:	RIWop=((aluop == 3'b000 | aluop == 3'b011)& func7) ? `SUBW :`ADDW;
		3'b001	:	RIWop=`SLLW;
		3'b101	:	RIWop=((aluop == 3'b000 | aluop == 3'b001 | aluop == 3'b011) & func7) ? `SRAW : `SRLW;
		default	:	RIWop=`ADD;			
	endcase
end

always@(*)begin
	case(aluop)
		3'b000	:	aluctl= RIop;
		3'b001	:	aluctl= RIop;
		3'b010	:	aluctl= branchop;
		3'b011	:	aluctl= RIWop;
		3'b100	:	aluctl= `ADD;
		default	:	aluctl= `ADD;			
	endcase
end

endmodule
