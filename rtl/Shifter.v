module Shifter(input [31:0] ALU_DA,
               input [4:0] ALU_SHIFT,
			   input [1:0] Shiftctr,
			   output reg [31:0] shift_result
			   );
			   
     always@(*) begin
	   case(Shiftctr)
	   2'b00:	shift_result = ALU_DA << ALU_SHIFT;
	   2'b01:	shift_result = ALU_DA >> ALU_SHIFT;
	   2'b10:	shift_result = ($signed(ALU_DA)) >>> ALU_SHIFT;
	   default:	shift_result = ALU_DA;
	   endcase
	 end


endmodule

