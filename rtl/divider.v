module divider
(
	input  wire        clk         ,
	input  wire        rst         ,
	input  wire [63:0] divisor     ,//除数
	input  wire [63:0] dividend    ,//被除数
	input  wire [9 :0] inst_op_f3  ,//指令的opcode 和 func3
	input  wire        div_ready   ,//准备执行除法
	output wire [63:0] div_rem_data,//除法结果
	output wire        div_finish  ,//除法执行完毕
	output reg         busy_o      //除法还在执行
);
	
	parameter DIV   = 10'b0110011_100;
	parameter DIVU  = 10'b0110011_101;
	parameter REM   = 10'b0110011_110;
	parameter REMU  = 10'b0110011_111;
	parameter DIVW  = 10'b0111011_100;
	parameter DIVUW = 10'b0111011_101;
	parameter REMW  = 10'b0111011_110;
	parameter REMUW = 10'b0111011_111;
	
	reg [6 :0] counter   ;
	reg        sign      ;//商的符号
	reg        sign_y    ;//余数的符号
	reg [63:0] dividend_t;//被除数的绝对值
	reg [63:0] divider_t ;//除数的绝对值
	
	reg  [127:0] temp_a   ;//中间过程的余数
	reg  [127:0] temp_b   ;//{divider_t, 64'b0 }
	reg          finish   ;//除法执行完毕
	wire         sign_inst;//除法结果是否有符号
	
	assign sign_inst = (inst_op_f3 == DIV) || (inst_op_f3 == DIVW) || (inst_op_f3 == REM) || (inst_op_f3 == REMW);
	
	reg [63:0] yushu;
	reg [63:0] shang;

	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				counter    = 7'b0  ;
				dividend_t = 64'b0 ;
				divider_t  = 64'b0 ;
				temp_a     = 128'b0;
				temp_b     = 128'b0;
				finish     = 1'b0  ;
				sign       = 1'b0  ;
				sign_y     = 1'b0  ;
				busy_o     = 1'b0  ;
			end
			else begin
				case(counter)
					0:begin
						if(div_ready) begin//对于有符号和无符号除法，原则都是被除数=除数×商+余数，并且余数的符号与被除数的符号相同
							counter = counter + 1;
							finish  = 1'b0       ;
							busy_o  = 1'b1       ;
                            if((inst_op_f3 == DIV) | (inst_op_f3 == DIVU) | (inst_op_f3 == REM) |(inst_op_f3 == REMU)) begin
    							if(sign_inst && dividend[63] && divisor[63]) begin//有符号除法 && 被除数是负数 && 除数是负数
    								dividend_t = ~dividend + 1;//被除数的绝对值
    								divider_t  = ~divisor + 1 ;//除数的绝对值
    								sign       = 1'b0         ;//商是正数
    								sign_y     = 1'b1         ;//余数是负数
    							end
    							else if(sign_inst && dividend[63]) begin//有符号除法 && 被除数是负数 && 除数是正数
    								dividend_t = ~dividend + 1;//被除数的绝对值
    								divider_t  = divisor      ;//除数的绝对值，即本身
    								sign       = 1'b1         ;//商是负数
    								sign_y     = 1'b1         ;//余数是负数
    							end
    							else if(sign_inst && divisor[63]) begin//有符号除法 && 被除数是正数 && 除数是负数
    								divider_t  = ~divisor + 1;//除数的绝对值
    								dividend_t = dividend    ;//被除数的绝对值，即本身
    								sign       = 1'b1        ;//商是负数
    								sign_y     = 1'b0        ;//余数是正数
    							end
							    else begin//无符号除法 | (被除数是正数 && 除数是正数)
							    	divider_t  = divisor ;//除数的绝对值，即本身
							    	dividend_t = dividend;//被除数的绝对值，即本身
							    	sign       = 1'b0    ;//商是正数
							    	sign_y     = 1'b0    ;//余数是正数
							    end
                            end
                            else begin//DIVW/DIVUW/REMW/REMUW,将rs1的低32位除以rs2的低32位
    							if(sign_inst && dividend[31] && divisor[31]) begin//有符号除法 && 被除数是负数 && 除数是负数
    								dividend_t = {{32{1'b0}},~dividend[31:0] + 1};//被除数的绝对值
    								divider_t  = {{32{1'b0}},~divisor[31:0] + 1};//除数的绝对值
    								sign       = 1'b0         ;//商是正数
    								sign_y     = 1'b1         ;//余数是负数
    							end
    							else if(sign_inst && dividend[31]) begin//有符号除法 && 被除数是负数 && 除数是正数
    								dividend_t = {{32{1'b0}},~dividend[31:0] + 1};//被除数的绝对值
    								divider_t  = {{32{1'b0}},divisor[31:0]};//除数的绝对值，即低32位
    								sign       = 1'b1         ;//商是负数
    								sign_y     = 1'b1         ;//余数是负数
    							end
    							else if(sign_inst && divisor[31]) begin//有符号除法 && 被除数是正数 && 除数是负数
    								divider_t  = {{32{1'b0}},~divisor[31:0] + 1};;//除数的绝对值
    								dividend_t = {{32{1'b0}},dividend[31:0]};//被除数的绝对值，即低32位
    								sign       = 1'b1        ;//商是负数
    								sign_y     = 1'b0        ;//余数是正数
    							end
							    else begin//无符号除法 | (被除数是正数 && 除数是正数)
							    	divider_t  = {{32{1'b0}},divisor[31:0]} ;//除数的绝对值，即本身
							    	dividend_t = {{32{1'b0}},dividend[31:0]};//被除数的绝对值，即本身
							    	sign       = 1'b0    ;//商是正数
							    	sign_y     = 1'b0    ;//余数是正数
							    end
                            end
						end
					end
					1:begin
						temp_a  = {64'b0, dividend_t};
						temp_b  = {divider_t, 64'b0 };
						counter = counter + 1        ;
						busy_o  = 1'b1               ;
					end
					66:begin
						finish  = 1'b1       ;
						counter = counter + 1;
						busy_o  = 1'b0       ;
					end
					67:begin
						counter = 7'b0;
						finish  = 1'b0;
						busy_o  = 1'b0;
					end
					default:begin
						counter = counter + 1;
						temp_a  = {temp_a[126:0], 1'b0};
						if(temp_a >= temp_b) begin
							temp_a = temp_a - temp_b + 1'b1;//商直接加到末尾
						end
						else begin
							temp_a = temp_a;
						end
					end
				endcase
			end
		end
	
	always @(*)
		begin
			if(rst == 1'b1) begin
				yushu = 64'b0;
				shang = 64'b0;
			end
			else if(divisor == 64'd0) begin//除以零：商所有位均为1，余数等于被除数。
				shang = 64'hffff_ffff_ffff_ffff;
				yushu = dividend               ;
			end
			else if(finish) begin
				if(sign && (!sign_y)) begin//前64位是余数，后64位是商
					yushu = temp_a[127:64]     ;
					shang = ~temp_a[63 : 0] + 1;
				end
				else if(sign && sign_y) begin
					yushu = ~temp_a[127:64] + 1;
					shang = ~temp_a[63 : 0] + 1;
				end
				else if((!sign) && (sign_y)) begin
					yushu = ~temp_a[127:64] + 1;
					shang = temp_a[63 : 0]     ;
				end
				else begin
					yushu = temp_a[127:64];
					shang = temp_a[63 : 0];
				end
			end
			else begin
				yushu = temp_a[127:64];
				shang = temp_a[63 : 0];
			end
		end
	
	assign div_finish = finish;
	assign div_rem_data = ((inst_op_f3 == DIV) || (inst_op_f3 == DIVU)) ? shang :
						  ((inst_op_f3 == DIVUW) || (inst_op_f3 == DIVW)) ? {{32{shang[31]}}, shang[31:0]} :
	                      ((inst_op_f3 == REM) || (inst_op_f3 == REMU)) ? yushu : 
						  ((inst_op_f3 == REMUW) || (inst_op_f3 == REMW)) ? {{32{yushu[31]}}, yushu[31:0]} : 64'b0;
	reg [9 :0] current_instr_type;//用于仿真时看指令类型
	reg [9 :0] next_instr_type;
	always@(*)begin
		case(current_instr_type)
			DIV:next_instr_type = (inst_op_f3 == DIV)   ? DIV 	: 
							 	  (inst_op_f3 == DIVU)  ? DIVU 	:
							 	  (inst_op_f3 == REM)	? REM	:
							 	  (inst_op_f3 == REMU) 	? REMU  :
							 	  (inst_op_f3 == DIVW)  ? DIVW 	: 
								  (inst_op_f3 == DIVUW) ? DIVUW	:
								  (inst_op_f3 == REMW)	? REMW	:
							 	  (inst_op_f3 == REMUW) ? REMUW :1'b0;
		   DIVU:next_instr_type = (inst_op_f3 == DIV)   ? DIV 	: 
							 	  (inst_op_f3 == DIVU)  ? DIVU 	:
							 	  (inst_op_f3 == REM)	? REM	:
							 	  (inst_op_f3 == REMU) 	? REMU  :
							 	  (inst_op_f3 == DIVW)  ? DIVW 	: 
								  (inst_op_f3 == DIVUW) ? DIVUW	:
								  (inst_op_f3 == REMW)	? REMW	:
							 	  (inst_op_f3 == REMUW) ? REMUW :1'b0;
		    REM:next_instr_type = (inst_op_f3 == DIV)   ? DIV 	: 
							 	  (inst_op_f3 == DIVU)  ? DIVU 	:
							 	  (inst_op_f3 == REM)	? REM	:
							 	  (inst_op_f3 == REMU) 	? REMU  :
							 	  (inst_op_f3 == DIVW)  ? DIVW 	: 
								  (inst_op_f3 == DIVUW) ? DIVUW	:
								  (inst_op_f3 == REMW)	? REMW	:
							 	  (inst_op_f3 == REMUW) ? REMUW :1'b0;
		   REMU:next_instr_type = (inst_op_f3 == DIV)   ? DIV 	: 
							 	  (inst_op_f3 == DIVU)  ? DIVU 	:
							 	  (inst_op_f3 == REM)	? REM	:
							 	  (inst_op_f3 == REMU) 	? REMU  :
							 	  (inst_op_f3 == DIVW)  ? DIVW 	: 
								  (inst_op_f3 == DIVUW) ? DIVUW	:
								  (inst_op_f3 == REMW)	? REMW	:
							 	  (inst_op_f3 == REMUW) ? REMUW :1'b0;
		   DIVW:next_instr_type = (inst_op_f3 == DIV)   ? DIV 	: 
							 	  (inst_op_f3 == DIVU)  ? DIVU 	:
							 	  (inst_op_f3 == REM)	? REM	:
							 	  (inst_op_f3 == REMU) 	? REMU  :
							 	  (inst_op_f3 == DIVW)  ? DIVW 	: 
								  (inst_op_f3 == DIVUW) ? DIVUW	:
								  (inst_op_f3 == REMW)	? REMW	:
							 	  (inst_op_f3 == REMUW) ? REMUW :1'b0;
		  DIVUW:next_instr_type = (inst_op_f3 == DIV)   ? DIV 	: 
							 	  (inst_op_f3 == DIVU)  ? DIVU 	:
							 	  (inst_op_f3 == REM)	? REM	:
							 	  (inst_op_f3 == REMU) 	? REMU  :
							 	  (inst_op_f3 == DIVW)  ? DIVW 	: 
								  (inst_op_f3 == DIVUW) ? DIVUW	:
								  (inst_op_f3 == REMW)	? REMW	:
							 	  (inst_op_f3 == REMUW) ? REMUW :1'b0;
		   REMW:next_instr_type = (inst_op_f3 == DIV)   ? DIV 	: 
							 	  (inst_op_f3 == DIVU)  ? DIVU 	:
							 	  (inst_op_f3 == REM)	? REM	:
							 	  (inst_op_f3 == REMU) 	? REMU  :
							 	  (inst_op_f3 == DIVW)  ? DIVW 	: 
								  (inst_op_f3 == DIVUW) ? DIVUW	:
								  (inst_op_f3 == REMW)	? REMW	:
							 	  (inst_op_f3 == REMUW) ? REMUW :1'b0;
		   REMUW:next_instr_type = (inst_op_f3 == DIV)   ? DIV 	: 
							 	  (inst_op_f3 == DIVU)  ? DIVU 	:
							 	  (inst_op_f3 == REM)	? REM	:
							 	  (inst_op_f3 == REMU) 	? REMU  :
							 	  (inst_op_f3 == DIVW)  ? DIVW 	: 
								  (inst_op_f3 == DIVUW) ? DIVUW	:
								  (inst_op_f3 == REMW)	? REMW	:
							 	  (inst_op_f3 == REMUW) ? REMUW :1'b0;								  
		   1'b0:next_instr_type = (inst_op_f3 == DIV)   ? DIV 	: 
							 	  (inst_op_f3 == DIVU)  ? DIVU 	:
							 	  (inst_op_f3 == REM)	? REM	:
							 	  (inst_op_f3 == REMU) 	? REMU  :
							 	  (inst_op_f3 == DIVW)  ? DIVW 	: 
								  (inst_op_f3 == DIVUW) ? DIVUW	:
								  (inst_op_f3 == REMW)	? REMW	:
							 	  (inst_op_f3 == REMUW) ? REMUW :1'b0;
									   
			default:next_instr_type = 1'b0;
		endcase
	end
	always@(posedge clk)begin
		current_instr_type <= next_instr_type;
	end
	
endmodule
