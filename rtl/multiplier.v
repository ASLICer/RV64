module multiplier
(
	input  wire        clk        ,
	input  wire        rst        ,
	input  wire        mult_ready ,//准备执行乘法
	input  wire [9 :0] inst_op_f3 ,//opcode 和 func3
	input  wire [63:0] mult_op1   ,//被乘数
	input  wire [63:0] mult_op2   ,//乘数
	output wire [63:0] product_val,//乘积结果
	output wire        mult_finish,//乘法执行完毕
	output reg         busy_o//乘法正在执行
);
	
	parameter MUL    = 10'b0110011_000;
	parameter MULH   = 10'b0110011_001;
	parameter MULHSU = 10'b0110011_010;
	parameter MULHU  = 10'b0110011_011;
	parameter MULW   = 10'b0111011_000;
	reg [9 :0] current_instr_type;//用于仿真时看指令类型
	reg [9 :0] next_instr_type;
	always@(*)begin
		case(current_instr_type)
			MUL:next_instr_type = (inst_op_f3 == MUL)   ? MUL 	: 
							 	  (inst_op_f3 == MULH)  ? MULH 	:
							 	  (inst_op_f3 == MULHSU)? MULHSU:
							 	  (inst_op_f3 == MULHU) ? MULHU :
							 	  (inst_op_f3 == MULW)  ? MULW 	: 1'b0;
		   MULH:next_instr_type = (inst_op_f3 == MUL)   ? MUL 	: 
							 	  (inst_op_f3 == MULH)  ? MULH 	:
							 	  (inst_op_f3 == MULHSU)? MULHSU:
							 	  (inst_op_f3 == MULHU) ? MULHU :
							 	  (inst_op_f3 == MULW)  ? MULW 	: 1'b0;
		 MULHSU:next_instr_type = (inst_op_f3 == MUL)   ? MUL 	: 
							 	  (inst_op_f3 == MULH)  ? MULH 	:
							 	  (inst_op_f3 == MULHSU)? MULHSU:
							 	  (inst_op_f3 == MULHU) ? MULHU :
							 	  (inst_op_f3 == MULW)  ? MULW 	: 1'b0;
		  MULHU:next_instr_type = (inst_op_f3 == MUL)   ? MUL 	: 
							 	  (inst_op_f3 == MULH)  ? MULH 	:
							 	  (inst_op_f3 == MULHSU)? MULHSU:
							      (inst_op_f3 == MULHU) ? MULHU :
							 	  (inst_op_f3 == MULW)  ? MULW 	: 1'b0;
		   MULW:next_instr_type = (inst_op_f3 == MUL)   ? MUL 	: 
							 	  (inst_op_f3 == MULH)  ? MULH 	:
							 	  (inst_op_f3 == MULHSU)? MULHSU:
							 	  (inst_op_f3 == MULHU) ? MULHU :
							 	  (inst_op_f3 == MULW)  ? MULW 	: 1'b0;
		        1'b0:next_instr_type = (inst_op_f3 == MUL)   ? MUL 		: 
							 		   (inst_op_f3 == MULH)  ? MULH 	:
							 		   (inst_op_f3 == MULHSU)? MULHSU 	:
							 		   (inst_op_f3 == MULHU) ? MULHU 	:
							 		   (inst_op_f3 == MULW)  ? MULW 	: 1'b0;
									   
			default:next_instr_type = 1'b0;
		endcase
	end

	always@(posedge clk)begin
		current_instr_type <= next_instr_type;
	end

	reg        mult_valid;//表示可以开始执行乘法
	reg [127:0] multiplicand;//被乘数
	reg [63:0] multiplier;//乘数
	
	assign mult_finish = mult_valid & ~(|multiplier);//乘法有效 && 除数为0，则执行完毕
	//finish = 1 >> valid = 0 ,finish = 0 >> valid = 1，valid失效一个周期
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				mult_valid <= 1'b1;
			end
			else if(~mult_ready | mult_finish) begin
				mult_valid <= 1'b0;
			end
			else begin
				mult_valid <= 1'b1;
			end
		end
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				busy_o <= 1'b0;
			end
			else if(mult_finish) begin
				busy_o <= 1'b0;
			end
			else if(mult_ready) begin
				busy_o <= 1'b1;
			end
			else begin
				busy_o <= 1'b0;
			end
		end
	
	wire        op1_signbit ;//被乘数的符号
	wire        op2_signbit ;//乘数的符号
	wire [63:0] op1_absolute;//被乘数的绝对值
	wire [63:0] op2_absolute;//乘数的绝对值
	
	assign op1_signbit  = mult_op1[63];
	assign op2_signbit  = mult_op2[63];
	assign op1_signbit_w= mult_op1[31];
	assign op2_signbit_w= mult_op2[31];
	//assign op1_absolute = ((op1_signbit&&inst_op_f3==MUL) || (op1_signbit&&inst_op_f3==MULHSU) || (op1_signbit&&inst_op_f3==MULH) || (op1_signbit&&inst_op_f3==MULW)) ? (~mult_op1+1) : mult_op1;
	//assign op2_absolute = ((op2_signbit&&inst_op_f3==MUL) || (op2_signbit&&inst_op_f3==MULH) || (op2_signbit&&inst_op_f3==MULW)) ? (~mult_op2+1) : mult_op2;
	assign op1_absolute = ((op1_signbit&&inst_op_f3==MUL) || (op1_signbit&&inst_op_f3==MULHSU) || (op1_signbit&&inst_op_f3==MULH)) ? (~mult_op1+1) : 
													  											 (op1_signbit_w&&inst_op_f3==MULW) ? {{64{1'b0}},{~mult_op1[31:0]+1}} : 
																								(~op1_signbit_w&&inst_op_f3==MULW) ? {{64{1'b0}},mult_op1[31:0]} : mult_op1;
	assign op2_absolute = ((op2_signbit&&inst_op_f3==MUL) || (op2_signbit&&inst_op_f3==MULH)) ? (~mult_op2+1) : 
													  		(op2_signbit_w&&inst_op_f3==MULW) ? {{64{1'b0}},{~mult_op2[31:0]+1}} : 
														   (~op2_signbit_w&&inst_op_f3==MULW) ? {{64{1'b0}},mult_op2[31:0]} : mult_op2;
	
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				multiplicand <= 128'b0;
			end
			else if(mult_valid) begin
				multiplicand <= {multiplicand[126:0], 1'b0}; //被乘数左移
			end
			else if(mult_ready) begin
				multiplicand <= {64'b0, op1_absolute};
			end
		end
		
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				multiplier <= 64'b0;
			end
			else if(mult_valid) begin
				multiplier <= {1'b0, multiplier[63:1]}; //乘数右移，直到为0
			end
			else if(mult_ready) begin
				multiplier <= op2_absolute;
			end
		end
		
	wire [127:0] product_lins;//部分积
	
	assign product_lins = multiplier[0] ? multiplicand : 128'b0;
	
	reg [127:0] product_temp;//部分积的和
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				product_temp <= 128'b0;
			end
			else if(mult_valid) begin
				product_temp <= product_temp + product_lins;
			end
			else if(mult_ready) begin
				product_temp <= 128'b0;
			end
		end
	
	reg product_signbit;//乘积的符号
	
	always @(posedge clk)
		begin
			if(rst == 1'b1) begin
				product_signbit <= 1'b0;
			end
			else if(mult_valid) begin
				
				product_signbit <= (inst_op_f3 == MULW) ? op1_signbit_w ^ op2_signbit_w :op1_signbit ^ op2_signbit;
			end
			else begin
				product_signbit <= (inst_op_f3 == MULW) ? op1_signbit_w ^ op2_signbit_w :op1_signbit ^ op2_signbit;
			end
		end
	
	assign product_val = (inst_op_f3 == MUL   ) ? ((product_signbit&&mult_op1!=64'd0&&mult_op2!=64'd0) ? ~product_temp[63 :0 ]+64'd1 : product_temp[63 :0 ]) :
						 (inst_op_f3 == MULH  ) ? ((product_signbit&&mult_op1!=64'd0&&mult_op2!=64'd0) ? ~product_temp[127:64]+64'd1 : product_temp[127:64]) :
						 (inst_op_f3 == MULHU ) ? product_temp[127:64]                                               :
						 (inst_op_f3 == MULHSU) ? ((op1_signbit&&mult_op1!=64'd0&&mult_op2!=64'd0) ? ~product_temp[127:64] : product_temp[127:64])     :
						 (inst_op_f3 == MULW  ) ? ((product_signbit&&mult_op1!=64'd0&&mult_op2!=64'd0) ? (~product_temp[31] ? {32'hffffffff,(~product_temp[31:0]+32'd1)} : {32'b0,(~product_temp[31:0]+32'd1)}) : (product_temp[31] ? {32'hffffffff,product_temp[31:0]} : {32'b0,product_temp[31:0]})) : 64'b0;
endmodule
