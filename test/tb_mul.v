module tb_mul#(
	parameter ARF_WIDTH = 5,
    parameter PRF_WIDTH = 6,
	parameter DECODE_NUM = 4
)();
	reg clk;
	reg rst;
	reg        mult_ready ;
	reg [9 :0] inst_op_f3 ;
	reg [63:0] mult_op1   ;
	reg [63:0] mult_op2   ;
	wire[63:0] product_val;
	wire       mult_finish;
    wire       busy_o;

multiplier multiplier_u0
(
	clk        ,
	rst        ,
	mult_ready ,
	inst_op_f3 ,
	mult_op1   ,
	mult_op2   ,
	product_val,
	mult_finish,
	busy_o
);

integer i,j;
initial  begin
	forever #10 clk = ~clk;
end
/*
initial  begin
	#10
	for(i=0;i<3;i=i+1)begin
		#1
		$display("================================== Cycle %2d ==================================",i);	
		$display("instruction0 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",instr0_rd,instr0_rs1,instr0_rs2,instr0_prd,instr0_prs1,instr0_prs2,instr0_preprd);	
		$display("instruction1 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",instr1_rd,instr1_rs1,instr1_rs2,instr1_prd,instr1_prs1,instr1_prs2,instr1_preprd);	
		$display("instruction2 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",instr2_rd,instr2_rs1,instr2_rs2,instr2_prd,instr2_prs1,instr2_prs2,instr2_preprd);	
		$display("instruction3 R%2d = R%2d op R%2d   =====>>>>   P%2d = P%2d op P%2d   previous_prd:P",instr3_rd,instr3_rs1,instr3_rs2,instr3_prd,instr3_prs1,instr3_prs2,instr3_preprd);
		reg_rat = rename_u0.rat;
		#15
				$display("+-----------+  =====>>>>  +-----------+");
				$display("| ARF | PRF |  =====>>>>  | ARF | PRF |");
				$display("+-----------+  =====>>>>  +-----------+");
		for(j=0;j<32;j=j+1)
				$display("| R%2d | P%2d |  =====>>>>  | R%2d | P%2d | ",j,reg_rat[j],j,rename_u0.rat[j]);
		#4 ;
	end
end
*/
/*always@(posedge clk)begin
	instr0_rd = {$random}%32;instr0_rs1 = {$random}%32;instr0_rs2 = {$random}%32;//第一条指令
	instr1_rd = {$random}%32;instr1_rs1 = {$random}%32;instr1_rs2 = {$random}%32;//第二条指令
	instr2_rd = {$random}%32;instr2_rs1 = {$random}%32;instr2_rs2 = {$random}%32;//第三条指令
	instr3_rd = {$random}%32;instr3_rs1 = {$random}%32;instr3_rs2 = {$random}%32;//第四条指令	
end
*/
initial begin
	clk = 1'b0;
	rst = 1'b1;

	#5 rst = 1'b0;
	mult_ready = 1'b1;
	inst_op_f3 = 10'b0110011000;//mul
	mult_op1 = 5;
	mult_op2 =-5;

	#85 
	mult_ready = 1'b1;
	inst_op_f3 = 10'b0110011001;//mulh
	mult_op1 = 5;
	mult_op2 =-5;

	#100
	mult_ready = 1'b1;
	inst_op_f3 = 10'b0110011010;//mulhsu
	mult_op1 = 5;
	mult_op2 =-5;

	#1320
	mult_ready = 1'b1;
	inst_op_f3 = 10'b0110011011;//mulhu
	mult_op1 = -5;
	mult_op2 =-5;

	#1320
	mult_ready = 1'b1;
	inst_op_f3 = 10'b0111011000;//mulw
	mult_op1 = -5;
	mult_op2 =-5;

	#100 $finish;
end


initial begin
	$vcdpluson;
	$vcdplusmemon;
end

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0,tb_mul,"+all");
end

endmodule
