module rename#(
	parameter ARF_WIDTH = 5,
    parameter PRF_WIDTH = 6,
	parameter DECODE_NUM = 4,
    parameter RETIRE_NUM = 4
)(  
    input clk,
	input rst,
    ///////////////////from instr_decode////////////////////
    //源寄存器的逻辑寄存器编号
    input [ARF_WIDTH-1:0] instr0_rs1,
    input [ARF_WIDTH-1:0] instr0_rs2,
    input [ARF_WIDTH-1:0] instr1_rs1,
    input [ARF_WIDTH-1:0] instr1_rs2,
    input [ARF_WIDTH-1:0] instr2_rs1,
    input [ARF_WIDTH-1:0] instr2_rs2,
    input [ARF_WIDTH-1:0] instr3_rs1,
    input [ARF_WIDTH-1:0] instr3_rs2,
    //目的寄存器的逻辑寄存器编号
    input [ARF_WIDTH-1:0] instr0_rd,
    input [ARF_WIDTH-1:0] instr1_rd,
    input [ARF_WIDTH-1:0] instr2_rd,
    input [ARF_WIDTH-1:0] instr3_rd,

	input  [DECODE_NUM-1:0]instr_prs1_v,//指令是否有来自源寄存器1操作数
    input  [DECODE_NUM-1:0]instr_prs2_v,//指令是否有来自源寄存器2操作数  
    input  [3:0]instr_prd_v,//指令是否有目的寄存器
        
    //from rob,指令退休 && 退休的指令存在目的寄存器>>释放指令的旧目的寄存器
    input [RETIRE_NUM-1:0] retire; //四条最旧指令是否可以退休
    input [2:0] retire_num,//本周期退休指令数量，退休几条则free list写地址加几
    input [RETIRE_NUM-1:0] rob_areg_v,//最旧四条指令是否存在目的寄存器
    input [PRF_WIDTH-1:0] rob_opreg [RETIRE_NUM-1:0],//最旧四条指令的opreg

    //////////////////to issue ///////////////////////////////
    //源寄存器的物理寄存器编号
    output [PRF_WIDTH-1:0] instr0_prs1,
    output [PRF_WIDTH-1:0] instr0_prs2,
    output [PRF_WIDTH-1:0] instr1_prs1,
    output [PRF_WIDTH-1:0] instr1_prs2,
    output [PRF_WIDTH-1:0] instr2_prs1,
    output [PRF_WIDTH-1:0] instr2_prs2,
    output [PRF_WIDTH-1:0] instr3_prs1,
    output [PRF_WIDTH-1:0] instr3_prs2,
    //////////////////to issue and rob///////////////////////////////
    //目的寄存器的物理寄存器编号
    output [PRF_WIDTH-1:0] instr0_prd,
    output [PRF_WIDTH-1:0] instr1_prd,
    output [PRF_WIDTH-1:0] instr2_prd,
    output [PRF_WIDTH-1:0] instr3_prd, 
    //目的寄存器的旧物理寄存器编号
    output [PRF_WIDTH-1:0] instr0_preprd,
    output [PRF_WIDTH-1:0] instr1_preprd,
    output [PRF_WIDTH-1:0] instr2_preprd,
    output [PRF_WIDTH-1:0] instr3_preprd   
);
reg [PRF_WIDTH-1:0] rat [31:0];//重命名映射表
reg [PRF_WIDTH-1:0] freelist [31:0];//空闲列表,FIFO实现(64个物理寄存器最多有32空闲，32个在RAT存在映射关系)
reg [2:0] free_num;//需要的空闲寄存器个数
reg [2:0] free_wnum;//写入的空闲寄存器个数
reg [4:0] fl_addr_before;//freelist未加上free_num的读地址（上周期freelist分配后的读地址）
wire [4:0] fl_addr_after;//freelist加上free_num的读地址（本周期freelist分配后的读地址）
reg [4:0] fl_waddr;//freelist的写地址
//从RAT中读取的源寄存器的物理寄存器编号(由于相关性，不一定是正确的)
reg [PRF_WIDTH-1:0] instr0_rat_prs1;
reg [PRF_WIDTH-1:0] instr0_rat_prs2;
reg [PRF_WIDTH-1:0] instr1_rat_prs1;
reg [PRF_WIDTH-1:0] instr1_rat_prs2;
reg [PRF_WIDTH-1:0] instr2_rat_prs1;
reg [PRF_WIDTH-1:0] instr2_rat_prs2;
reg [PRF_WIDTH-1:0] instr3_rat_prs1;
reg [PRF_WIDTH-1:0] instr3_rat_prs2;


assign fl_addr_after = fl_addr_before + free_num;
integer i;
//计算需要的空闲寄存器个数
always@(instr_prd_v or rst) begin
	if(rst)
		free_num = 1'b0;
    else begin 
		free_num = 1'b0;
    	for(i=0;i<4;i=i+1)
			free_num = free_num + instr_prd_v[i];
	end
end

wire [RETIRE_NUM-1:0] retire_rdv;//指令退休且存在目的寄存器
always@(*) begin
    for(i=0;i<RETIRE_NUM;i=i+1)
		retire_rdv[i] = rob_areg_v[i] & retire[i];
	end
end
//计算写入的空闲寄存器个数
always@(instr_prd_v or rst) begin
	if(rst)
		free_wnum = 1'b0;
    else begin 
		free_wnum = 1'b0;
    	for(i=0;i<RETIRE_NUM;i=i+1)
			free_wnum = free_wnum + retire_rdv[i];
	end
end
//更新freelist读地址
always@(posedge clk or posedge rst)begin
	if(rst)
		fl_addr_before = 0;
	else
		fl_addr_before = fl_addr_after;	
end
//更新freelist写地址

always@(posedge clk or posedge rst)begin
	if(rst)
		fl_waddr = 0;
	else
		fl_waddr = fl_waddr + free_wnum;	
end

//根据退休指令数目以及需要写入free list的物理寄存器数目，向free list 写入释放的物理寄存器号
always@(posedge clk or posedge rst)begin
    if(rst)
        for(i=0;i<32;i=i+1)//复位后0-31已经在RAT中有映射关系，32-63物理寄存器都是空闲的
			freelist[i] <= i+32;
    else begin
    	case(free_wnum)
        	1:	begin//0,1,2,3
                    freelist[fl_waddr] <= (retire_rdv == 4'b0001) ? rob_opreg[0] ://向free list写入最旧退休指令的物理寄存器
                                          (retire_rdv == 4'b0010) ? rob_opreg[1] ://向free list写入第二旧退休指令的物理寄存器
                                          (retire_rdv == 4'b0100) ? rob_opreg[2] ://向free list写入第三旧退休指令的物理寄存器
                                          (retire_rdv == 4'b1000) ? rob_opreg[3] ://向free list写入第四旧退休指令的物理寄存器
                                          freelist[fl_waddr];
                end
        	2:	begin//01,02,03,12,13,23
    				freelist[fl_waddr-1] <= (retire_rdv == 4'b0011) ? rob_opreg[1] :
                                            ((retire_rdv == 4'b0101) | (retire_rdv == 4'b0011)) ? rob_opreg[2] :
                                            ((retire_rdv == 4'b1001) | (retire_rdv == 4'b1010) | (retire_rdv == 4'b1100)) ? rob_opreg[3] :
                                            freelist[fl_waddr-1];
    				freelist[fl_waddr] <= ((retire_rdv == 4'b0011) | (retire_rdv == 4'b0101) | (retire_rdv == 4'b1001)) ? rob_opreg[0] :
                                          ((retire_rdv == 4'b0110) | (retire_rdv == 4'b1010)) ? rob_opreg[1] :
                                          ((retire_rdv == 4'b1100)) ? rob_opreg[2] :
                                          freelist[fl_waddr];
    			end
        	3:	begin//012,013,123,123
    				freelist[fl_waddr-2] <= (retire_rdv == 4'b0111) ? rob_opreg[2] : rob_opreg[3];
    				freelist[fl_waddr-1] <= ((retire_rdv == 4'b0111) | (retire_rdv == 4'b1011)) ? rob_opreg[1] : rob_opreg[2]];
                    freelist[fl_waddr]   <= ((retire_rdv == 4'b0111) | (retire_rdv == 4'b1011)) ? rob_opreg[0] : rob_opreg[1]];
    			end
        	4:	begin//0123
    				freelist[fl_waddr-3] <= rob_opreg[0];
    				freelist[fl_waddr-2] <= rob_opreg[1];
                    freelist[fl_waddr-1] <= rob_opreg[2];
                    freelist[fl_waddr]   <= rob_opreg[3];
    			end	
    	endcase
    end
end
//从空闲列表中找到空闲的物理寄存器，作为指令的目的寄存器对应的物理寄存器(由于WAW相关性，不一定是正确的)
//组合逻辑读freelist,因为读完后还要写新的映射关系进RAT(上升沿写入)
//整个过程在一个周期内完成
reg [PRF_WIDTH-1:0] instr0_fl_prd;
reg [PRF_WIDTH-1:0] instr1_fl_prd;
reg [PRF_WIDTH-1:0] instr2_fl_prd;
reg [PRF_WIDTH-1:0] instr3_fl_prd;
//上升沿读，因为要与从RAT读取的源寄存器对应的物理寄存器编号同步
//由于可能出现RAW，需要从两者中选取一个作为真正的源寄存器对应的物理寄存器编号
always@(posedge clk)begin
	case(free_num)
    	1:	instr0_fl_prd <= freelist[fl_addr_after];
    	2:	begin
				instr0_fl_prd <= freelist[fl_addr_after-1];
				instr1_fl_prd <= freelist[fl_addr_after];
			end
    	3:	begin
				instr0_fl_prd <= freelist[fl_addr_after-2];
				instr1_fl_prd <= freelist[fl_addr_after-1];
				instr2_fl_prd <= freelist[fl_addr_after];
			end
    	4:	begin
				instr0_fl_prd <= freelist[fl_addr_after-3];
				instr1_fl_prd <= freelist[fl_addr_after-2];
				instr2_fl_prd <= freelist[fl_addr_after-1];
				instr3_fl_prd <= freelist[fl_addr_after];
			end	
	endcase
end
//从RAT中读取目的寄存器对应的的旧物理寄存器编号
//由于WAW相关性，不一定是正确的,可能来源于上一条指令的目的寄存器的物理寄存器
//也可能不存在目的寄存器，不读取RAT或者忽略掉读取的结果
reg [PRF_WIDTH-1:0] instr0_rat_preprd;
reg [PRF_WIDTH-1:0] instr1_rat_preprd;
reg [PRF_WIDTH-1:0] instr2_rat_preprd;
reg [PRF_WIDTH-1:0] instr3_rat_preprd;

always@(posedge clk)begin//存在目的寄存器才读，否则保持不变节省功耗
    instr0_rat_preprd <= instr_prd_v[0] ? rat[instr0_rd] : instr0_rat_preprd;
    instr1_rat_preprd <= instr_prd_v[1] ? rat[instr1_rd] : instr1_rat_preprd;
    instr2_rat_preprd <= instr_prd_v[2] ? rat[instr2_rd] : instr2_rat_preprd;
    instr3_rat_preprd <= instr_prd_v[3] ? rat[instr3_rd] : instr3_rat_preprd;    
end
//输出真正的旧映射关系（若不存在目的寄存器，忽略掉该结果，保持不变节省功耗）
//assign instr0_preprd = instr_prd_v[0] ? instr0_rat_preprd : instr0_preprd;//指令0的旧映射关系只能来源于RAT
//assign instr1_preprd = ((instr1_rd == instr0_rd) & ( instr_prd_v[0] & instr_prd_v[1])) ? instr0_fl_prd : 
//												   (~instr_prd_v[0] & instr_prd_v[1])  ? instr1_rat_preprd : instr1_preprd;
//assign instr2_preprd = ((instr2_rd == instr1_rd) & ( instr_prd_v[1] & instr_prd_v[2])) ? instr1_fl_prd : 
//                       ((instr2_rd == instr0_rd) & ( instr_prd_v[0] & instr_prd_v[2])) ? instr0_fl_prd : 
//					   			  (~instr_prd_v[0] & ~instr_prd_v[1] & instr_prd_v[2]) ? instr2_rat_preprd : instr2_preprd;
//assign instr3_preprd = ((instr3_rd == instr2_rd) & ( instr_prd_v[2] & instr_prd_v[3])) ? instr2_fl_prd :
//                       ((instr3_rd == instr1_rd) & ( instr_prd_v[1] & instr_prd_v[3])) ? instr1_fl_prd : 
//                       ((instr3_rd == instr0_rd) & ( instr_prd_v[0] & instr_prd_v[3])) ? instr0_fl_prd : 
//					   (~instr_prd_v[0] & ~instr_prd_v[1] & ~instr_prd_v[2] & instr_prd_v[3]) ? instr3_rat_preprd : instr3_preprd;

assign instr0_preprd = instr_prd_v[0] ? instr0_rat_preprd : instr0_preprd;//指令0的旧映射关系只能来源于RAT
assign instr1_preprd = ((instr1_rd == instr0_rd) & ( instr_prd_v[0] & instr_prd_v[1])) ? instr0_fl_prd : //指令1的目的寄存器和指令0相同(且两者存在目的寄存器)
												   					  instr_prd_v[1]   ? instr1_rat_preprd : instr1_preprd;
assign instr2_preprd = ((instr2_rd == instr1_rd) & ( instr_prd_v[1] & instr_prd_v[2])) ? instr1_fl_prd : //指令2的目的寄存器和指令1相同(且两者存在目的寄存器)
                       ((instr2_rd == instr0_rd) & ( instr_prd_v[0] & instr_prd_v[2])) ? instr0_fl_prd : //指令2的目的寄存器和指令0相同(且两者存在目的寄存器)
					   			  										instr_prd_v[2] ? instr2_rat_preprd : instr2_preprd;
assign instr3_preprd = ((instr3_rd == instr2_rd) & ( instr_prd_v[2] & instr_prd_v[3])) ? instr2_fl_prd : //指令3的目的寄存器和指令2相同(且两者存在目的寄存器)
                       ((instr3_rd == instr1_rd) & ( instr_prd_v[1] & instr_prd_v[3])) ? instr1_fl_prd : //指令3的目的寄存器和指令1相同(且两者存在目的寄存器)
                       ((instr3_rd == instr0_rd) & ( instr_prd_v[0] & instr_prd_v[3])) ? instr0_fl_prd : //指令3的目的寄存器和指令0相同(且两者存在目的寄存器)
					   													instr_prd_v[3] ? instr3_rat_preprd : instr3_preprd;
//从RAT中读取源寄存器对应的物理寄存器编号
//由于RAW相关性，不一定是正确的,可能来源于上一条指令的目的寄存器的物理寄存器
//也可能不存在源寄存器，不读取RAT或者忽略掉读取的结果
always@(posedge clk)begin
    instr0_rat_prs1 <= instr_prs1_v[0] ? rat[instr0_rs1] : instr0_rat_prs1;
    instr0_rat_prs2 <= instr_prs2_v[0] ? rat[instr0_rs2] : instr0_rat_prs2;
    instr1_rat_prs1 <= instr_prs1_v[1] ? rat[instr1_rs1] : instr1_rat_prs1;
    instr1_rat_prs2 <= instr_prs2_v[1] ? rat[instr1_rs2] : instr1_rat_prs2;
    instr2_rat_prs1 <= instr_prs1_v[2] ? rat[instr2_rs1] : instr2_rat_prs1;
    instr2_rat_prs2 <= instr_prs2_v[2] ? rat[instr2_rs2] : instr2_rat_prs2;
    instr3_rat_prs1 <= instr_prs1_v[3] ? rat[instr3_rs1] : instr3_rat_prs1;
    instr3_rat_prs2 <= instr_prs2_v[3] ? rat[instr3_rs2] : instr3_rat_prs2;
end
//目的寄存器的物理寄存器编号就是从空闲列表找到空闲的物理寄存器编号(某些指令没有目的寄存器)
assign instr0_prd = instr_prd_v[0] ? instr0_fl_prd : instr0_prd;
assign instr1_prd = ( instr_prd_v[0] & instr_prd_v[1]) ? instr1_fl_prd :
					(~instr_prd_v[0] & instr_prd_v[1]) ? instr0_fl_prd : instr1_prd;
assign instr2_prd = ((instr_prd_v[1:0] == 2'b11) & instr_prd_v[2]) ? instr2_fl_prd :
					((^instr_prd_v[1:0])  		 & instr_prd_v[2]) ? instr1_fl_prd : 
					((|instr_prd_v[1:0])  		 & instr_prd_v[2]) ? instr0_fl_prd : instr2_prd;
assign instr3_prd = ((instr_prd_v[2:0] == 3'b111) & instr_prd_v[3]) ? instr3_fl_prd :
					((instr_prd_v[2:0] == 3'b110 | instr_prd_v[2:0] == 3'b101 | instr_prd_v[2:0] == 3'b011) & instr_prd_v[3]) ? instr2_fl_prd :
					((instr_prd_v[2:0] == 3'b100 | instr_prd_v[2:0] == 3'b010 | instr_prd_v[2:0] == 3'b001) & instr_prd_v[3]) ? instr1_fl_prd : 
					((instr_prd_v[2:0] == 3'b000) & instr_prd_v[3]) ? instr0_fl_prd : instr3_prd;


//向RAT中写入新的映射关系(目的寄存器对应的新的物理寄存器)
//存在目的寄存器才需要写入新的映射关系
//若出现WAW相关性,只需写入最新的映射关系
always@(negedge clk or posedge rst)begin//上升沿读，下降沿写，保证下周期上升沿能够读到本cycle的写入的映射关系
	if(rst)begin
		for(i=0;i<32;i=i+1)
			rat[i] <= i;
	end
	else begin
		if(instr_prd_v[0])begin//指令1/指令2/指令3的目的寄存器和指令0的目的寄存器相同，则指令0不写RAT
			if(~(((instr0_rd == instr1_rd) && instr_prd_v[1]) | ((instr0_rd == instr2_rd) && instr_prd_v[2]) | ((instr0_rd == instr3_rd) && instr_prd_v[3])))
    	    	rat[instr0_rd] <= instr0_prd ;
		end
		if(instr_prd_v[1])begin//指令2/指令3的目的寄存器和指令1的目的寄存器相同，则指令1不写RAT
			if(~(((instr1_rd == instr2_rd) && instr_prd_v[2]) | ((instr1_rd == instr3_rd) && instr_prd_v[3])))
    	    	rat[instr1_rd] <= instr1_prd ;
		end
		if(instr_prd_v[2])begin//指令3的目的寄存器和指令2的目的寄存器相同，则指令2不写RAT
			if(~((instr2_rd == instr3_rd) && instr_prd_v[3]))
    	    	rat[instr2_rd] <= instr2_prd ;
		end
    	if(instr_prd_v[3])//指令3只要存在目的寄存器，指令3的新映射关系一定会被写入
    		rat[instr3_rd] <= instr3_prd;
	end
end

//RAW相关性检查(后面指令的源寄存器是否等于前面指令的目的寄存器)比较的是逻辑寄存器
//第一条指令的源寄存器对应的物理寄存器只能来自RAT
//最后一条指令的目的寄存器来自于空闲列表，不可能作为其他指令的源寄存器
wire raw1_rs1,raw1_rs2;
wire [1:0] raw2_rs1,raw2_rs2;
wire [2:0] raw3_rs1,raw3_rs2;
//指令1与指令0相关性
//指令1的源寄存器=指令0的目的寄存器，1
assign raw1_rs1 = ((instr1_rs1 == instr0_rd) & (instr_prs1_v[1] & instr_prd_v[0]));//指令1存在源寄存器1 & 指令0存在目的寄存器
assign raw1_rs2 = ((instr1_rs2 == instr0_rd) & (instr_prs2_v[1] & instr_prd_v[0]));//指令1存在源寄存器2 & 指令0存在目的寄存器
//指令2与指令0/指令1相关性
//指令2的源寄存器=指令0的目的寄存器，01
//指令2的源寄存器=指令1的目的寄存器，10
//指令2的源寄存器=指令0和指令1的目的寄存器，11
assign raw2_rs1 = {((instr2_rs1 == instr1_rd) & (instr_prs1_v[2] & instr_prd_v[1])),((instr2_rs1 == instr0_rd) & (instr_prs1_v[2] & instr_prd_v[0]))};
assign raw2_rs2 = {((instr2_rs2 == instr1_rd) & (instr_prs2_v[2] & instr_prd_v[1])),((instr2_rs2 == instr0_rd) & (instr_prs2_v[2] & instr_prd_v[0]))};
//指令3与指令0/指令1/指令2相关性
//指令3的源寄存器=指令0的目的寄存器，001
//指令3的源寄存器=指令1的目的寄存器，01x
//指令3的源寄存器=指令2的目的寄存器，1xx
//其他情况~~~
assign raw3_rs1 = {((instr3_rs1 == instr2_rd) & (instr_prs1_v[3] & instr_prd_v[2])),((instr3_rs1 == instr1_rd) & (instr_prs1_v[3] & instr_prd_v[1])),((instr3_rs1 == instr0_rd) & (instr_prs1_v[3] & instr_prd_v[0]))};
assign raw3_rs2 = {((instr3_rs2 == instr2_rd) & (instr_prs2_v[3] & instr_prd_v[2])),((instr3_rs2 == instr1_rd) & (instr_prs2_v[3] & instr_prd_v[1])),((instr3_rs2 == instr0_rd) & (instr_prs2_v[3] & instr_prd_v[0]))};

//选择源寄存器对应的物理寄存器输出
//指令0因为是第一条指令，源寄存器对应的物理寄存器编号只能是RAT中读取的值
assign instr0_prs1 = instr0_rat_prs1;
assign instr0_prs2 = instr0_rat_prs2;
//指令1与指令0存在RAW，说明指令0存在目的寄存器，即指令0必用了一个空闲寄存器
assign instr1_prs1 = raw1_rs1 ? instr0_fl_prd : instr1_rat_prs1;
assign instr1_prs2 = raw1_rs2 ? instr0_fl_prd : instr1_rat_prs2;
//指令2(需要判断前面用了多少空闲寄存器)
assign instr2_prs1 = (raw2_rs1[1] &  instr_prd_v[0]) ? instr1_fl_prd : //指令2和指令1存在RAW & 指令0由于存在目的寄存器，用了一个空闲寄存器
                     (raw2_rs1[1] & ~instr_prd_v[0]) ? instr0_fl_prd : //指令2和指令1存在RAW & 指令0不存在目的寄存器
										 raw2_rs1[0] ? instr0_fl_prd : //指令2只和指令0存在RAW
													   instr2_rat_prs1;//指令2和指令0、指令0都不存在RAW
assign instr2_prs2 = (raw2_rs2[1] &  instr_prd_v[0]) ? instr1_fl_prd : //指令2和指令1存在RAW & 指令0由于存在目的寄存器，用了一个空闲寄存器
                     (raw2_rs2[1] & ~instr_prd_v[0]) ? instr0_fl_prd : //指令2和指令1存在RAW & 指令0不存在目的寄存器
										 raw2_rs2[0] ? instr0_fl_prd : //指令2只和指令0存在RAW
													   instr2_rat_prs2;//指令2和指令0、指令1都不存在RAW
//指令3 
assign instr3_prs1 = (raw3_rs1[2] & (instr_prd_v[1:0] == 2'b11)) ? instr2_fl_prd ://指令3和指令2存在RAW & 指令1和指令0由于存在目的寄存器，用了两个空闲寄存器
                     (raw3_rs1[2] & (instr_prd_v[1:0] != 2'b00)) ? instr1_fl_prd ://指令3和指令2存在RAW & 指令1或指令0由于存在目的寄存器，用了一个空闲寄存器 
                     (raw3_rs1[2] & (instr_prd_v[1:0] == 2'b00)) ? instr0_fl_prd ://指令3和指令2存在RAW & 指令1和指令0不存在目的寄存器
					 (raw3_rs1[1] &  instr_prd_v[0]) ? instr1_fl_prd : //指令3和指令1存在RAW & 指令0由于存在目的寄存器，用了一个空闲寄存器
                     (raw3_rs1[1] & ~instr_prd_v[0]) ? instr0_fl_prd : //指令3和指令1存在RAW & 指令0不存在目的寄存器
										 raw3_rs1[0] ? instr0_fl_prd : //指令3只和指令0存在RAW
										 			   instr3_rat_prs1;//指令3和指令0、指令1、指令2都不存在RAW

assign instr3_prs2 = (raw3_rs2[2] & (instr_prd_v[1:0] == 2'b11)) ? instr2_fl_prd ://指令3和指令2存在RAW & 指令1和指令0由于存在目的寄存器，用了两个空闲寄存器
                     (raw3_rs2[2] & (instr_prd_v[1:0] != 2'b00)) ? instr1_fl_prd ://指令3和指令2存在RAW & 指令1或指令0由于存在目的寄存器，用了一个空闲寄存器 
                     (raw3_rs2[2] & (instr_prd_v[1:0] == 2'b00)) ? instr0_fl_prd ://指令3和指令2存在RAW & 指令1和指令0不存在目的寄存器
					 (raw3_rs2[1] &  instr_prd_v[0]) ? instr1_fl_prd : //指令3和指令1存在RAW & 指令0由于存在目的寄存器，用了一个空闲寄存器
                     (raw3_rs2[1] & ~instr_prd_v[0]) ? instr0_fl_prd : //指令3和指令1存在RAW & 指令0不存在目的寄存器
										 raw3_rs2[0] ? instr0_fl_prd : //指令3只和指令0存在RAW
										 			   instr3_rat_prs2;//指令3和指令0、指令1、指令2都不存在RAW    
                                                                             
endmodule
