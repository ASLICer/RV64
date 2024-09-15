`include "./rtl/define.v" 
module mdu_control(
	input	[6:0]	opcode,
	input 	[2:0]	func3,
	output 	[4:0]	mductl
);

reg [4:0]	MDop;
reg [4:0]	MDWop;

assign mdu_control = (opcode == `MD_type) ? MDop : MDWop; 

always@(*)begin
	case(func3)
		3'b000	: MDop = `MUL   ;      
		3'b001	: MDop = `MULH  ;
		3'b010	: MDop = `MULHSU;  
		3'b011	: MDop = `MUU   ;
		3'b100	: MDop = `DIV   ;
		3'b101	: MDop = `DIVU  ;
		3'b110	: MDop = `REM   ;
		3'b111	: MDop = `REMU  ;
		default	: MDop = `MUL   ;		
	endcase
end

always@(*)begin
	case(func3)
		3'b000	: MDWop = `MULW  ; 
		3'b100	: MDWop = `DIVW  ;
		3'b101	: MDWop = `DIVUW ;
		3'b110	: MDWop = `REMW  ;
		3'b111	: MDWop = `REMUW ;
		default	: MDWop = `MULW  ;			
	endcase
end

endmodule
