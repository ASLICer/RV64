`include "./rtl/define.v" 
module alu_control(
	input	[1:0]	aluop,
	input 	[2:0]	func3,
	input 			func7,
	output	[3:0]	aluctl
);

wire	[3:0]	branchop;
reg 	[3:0]	RIop;

assign	branchop	=	(func3[2] & func3[1]) ? `SLTU	:	//bltu bgeu
						(func3[2] & ~func3[1]) ? `SLT 	:	//blt  bge
						`SUB;								//beq  bne

always@(*)begin
	case(func3)
		3'b000	:	RIop=(aluop[1]&func7) ? `SUB :`ADD;
		3'b001	:	RIop=`SLL;
		3'b010	:	RIop=`SLT;
		3'b011	:	RIop=`SLTU;
		3'b100	:	RIop=`XOR;
		3'b101	:	RIop=(func7) ? `SRA : `SRL;
		3'b110	:	RIop=`OR;
		3'b111	:	RIop=`AND;
		default	:	RIop=`ADD;			
	endcase
end

assign	aluctl	=	(aluop[1]^aluop[0]) ? RIop 		:	//R,I type	 
			  		(aluop[1]&aluop[0]) ? branchop	:	//B type
					`ADD;								//load,store

endmodule
