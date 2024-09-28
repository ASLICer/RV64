module tb_div#(
	parameter ARF_WIDTH = 5,
    parameter PRF_WIDTH = 6,
	parameter DECODE_NUM = 4
)();


	reg        clk         ;
	reg        rst         ;
	reg [63:0] divisor     ;
	reg [63:0] dividend    ;
	reg [9 :0] inst_op_f3  ;
	reg        div_ready   ;
	wire[63:0] div_rem_data;
	wire       div_finish  ;
	wire       busy_o      ; 

divider divider_uo
(
	clk         ,
	rst         ,
	divisor     ,
	dividend    ,
	inst_op_f3  ,
	div_ready   ,
	div_rem_data,
	div_finish  ,
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

	#15 rst = 1'b0;
	div_ready = 1'b1;
	inst_op_f3 = 10'b0110011_100;//div,shang:-1 yushu:0
	dividend = 5;
	divisor =-5;

	#1355 
	div_ready = 1'b1;
	inst_op_f3 = 10'b0110011_101;//divu,shang:0 yushu:7
	dividend = 7;
	divisor =-5;

	#1355
	div_ready = 1'b1;
	inst_op_f3 = 10'b0110011_110;//rem,shang:-1 yushu:2
	dividend = 7;
	divisor =-5;

	#1355
	div_ready = 1'b1;
	inst_op_f3 = 10'b0110011_111;//remu,shang:0 yushu:64'hffff_ffff_ffff_fff9
	dividend = -7;
	divisor =-5;//64'hffff_ffff_ffff_fffb

	#1355
	div_ready = 1'b1;
	inst_op_f3 = 10'b0111011_100;//divw,shang:1,yushu:-2
	dividend = 64'hffff_0000_ffff_fff9;//-7
	divisor =-5;
	#1355
	div_ready = 1'b1;
	inst_op_f3 = 10'b0111011_101;//divuw,shang:1,yushu:1
	dividend = 64'hffff_0000_1000_0001;//129
	divisor = 64'hffff_0000_1000_0000;//128
	#1355
	div_ready = 1'b1;
	inst_op_f3 = 10'b0111011_110;//remw,shang:-1,yushu:2
	dividend = 64'hffff_0000_0000_0007;//7
	divisor =-5;
	#1355
	div_ready = 1'b1;
	inst_op_f3 = 10'b0111011_111;//remuw,shang:1,yushu:3
	dividend = 64'hffff_0000_1000_0011;//131
	divisor = 64'hffff_0000_1000_0000;//128

	#1500 $finish;
end


initial begin
	$vcdpluson;
	$vcdplusmemon;
end

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0,tb_div,"+all");
end

endmodule
