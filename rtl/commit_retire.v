module commit_retire#(
    parameter DATA_WIDTH = 64,
    parameter DECODE_NUM = 4,
    parameter ISSUE_NUM =4,
    parameter RETIRE_NUM =4,
    
    parameter COMPLETE = 1,
    parameter AREG_V = 1,
    parameter AREG = 5,
    parameter PREG = 6,
    parameter OPREG = 6,
    parameter PC = DATA_WIDTH,
    parameter EXCEPTION = 1,
    parameter TYPE = 7,
    parameter ROB_WIDTH = COMPLETE + AREG_V + AREG + PREG + OPREG + PC + EXCEPTION + TYPE,

    parameter COMPLETE_B = 0,
    parameter AREG_V_B = COMPLETE_B + 1,
    parameter AREG_LSB = AREG_V_B + 1,
    parameter AREG_MSB = AREG_LSB + AREG - 1,
    parameter PREG_LSB = AREG_MSB + 1,
    parameter PREG_MSB = PREG_LSB + PREG - 1,
    parameter OPREG_LSB= PREG_MSB + 1,
    parameter OPREG_MSB= OPREG_LSB + OPREG - 1,
    parameter PC_LSB   = OPREG_MSB + 1,
    parameter PC_MSB   = PC_LSB + 1,
    parameter EXCEPTION_B = PC_MSB + 1,
    parameter TYPE_LSB = EXCEPTION_B + 1,
    parameter TYPE_MSB = TYPE_LSB + TYPE - 1 
)
(
    input clk,
    input rst,
    /from execute
    input [4:0] instr_iaddr [ISSUE_NUM-1:0],//指令在rename阶段开始就跟着指令流动的ROB编号，传到write back阶段，说明指令执行完毕

    //from rename and decode
    input [DECODE_NUM-1:0]] areg_v ,//指令存在目的寄存器
    input [AREG-1:0] areg [DECODE_NUM-1:0],//逻辑目的寄存器
    input [PREG-1:0] preg [DECODE_NUM-1:0],//物理目的寄存器
    input [OPREG-1:0]opreg[DECODE_NUM-1:0],//旧物理目的寄存器
    input [PC-1:0]   pc   [DECODE_NUM-1:0],//指令pc值，用于中断或者异常，重新执行程序
    input exception [DECODE_NUM-1:0];// 异常类型
    input [TYPE-1:0] type [DECODE_NUM-1:0],// 指令类型，退休时，不同类型指令有不同动作

    //rob >> issue >> execute >> write back >> rob
    output [4:0] instr_oaddr [DECODE_NUM-1:0],//指令在rob的地址跟随指令流动

    //to freelist,指令退休 && 指令存在目的寄存器>>释放指令的旧目的寄存器（后面的指令不会再使用这个物理寄存器）
    output [RETIRE_NUM-1:0] retire; //四条最旧指令是否可以退休
    output [2:0] retire_num;//本周期退休指令数量，退休几条则free list写地址加几
    output reg [RETIRE_NUM-1:0] rob_areg_v;//最旧四条指令是否存在目的寄存器
    output reg [OPREG-1:0] rob_opreg [RETIRE_NUM-1:0];//最旧四条指令的opreg
);
reg [ROB_WIDTH-1:0] rob [31:0];//重排序缓存
reg [PREG-1:0] rat [31:0];//保存正确映射关系的rat,外部可见

reg [31:0] complete;//推算出的完成指令完成状态
reg [4:0] head_pointer;//最旧的指令对应的地址，相当于fifo的读指针,每周期最多退休4条指令
reg [4:0] tail_pointer;//最新的指令对应的地址，相当于fifo的写指针,每周期写入4条指令

//通过比较跟随指令流动的地址和在rob中还未退休指令的地址,判断它们是否完成
integer i,j;
always@(*)begin
    for(i=head_pointer;i<=tail_pointer;i=i+1)begin//rob中指令地址 
        complete[i] = 0; 
        for(j=0;j<ISSUE_NUM;j=j+1)begin//流动过来的指令地址
            if(i == instr_iaddr[j])
                complete[i] == 1;
        end
    end
end
//更新rob中指令的完成状态
always@(posedge clk)begin
    for(i=head_pointer;i<=tail_pointer;i=i+1)begin
        rob[i][0] <= complete[i];
    end
end
//前面的指令退休，后面的才有可能退休（否则即使完成了也不能退休）
assign retire[0] = rob[head_pointer][0]; 
assign retire[1] = rob[head_pointer+1][0] && retire0; 
assign retire[2] = rob[head_pointer+2][0] && retire0 && retire1;
assign retire[3] = rob[head_pointer+3][0] && retire0 && retire1 && retire2;
assign retire_num = retire0 + retire1 + retire2 + retire3;

reg [AREG-1:0] rob_areg [RETIRE_NUM-1:0];//最旧四条指令的areg
reg [PREG-1:0] rob_preg [RETIRE_NUM-1:0];//最旧四条指令的preg



//读取最旧四条指令的areg/preg/opreg/areg_v,时钟上升沿向real rat/free list写入
//四条指令中未退休的不用写rat/free list，retire信号即可作为rat/free list的写使能
always@(*)begin
    for(i=0;i<RETIRE_NUM;i=i+1)begin
        rob_areg[i]   = rob[head_pointer+i][AREG_MSB:AREG_LSB];
        rob_preg[i]   = rob[head_pointer+i][PREG_MSB:PREG_LSB];
        rob_opreg[i]  = rob[head_pointer+i][OPREG_MSB:OPREG_LSB];
        rob_areg_v[i] = rob[head_pointer+i][AREG_V_B];
    end
end

//向RAT中写入新的映射关系(目的寄存器对应的新的物理寄存器)
//存在目的寄存器才需要写入新的映射关系
//若出现WAW相关性,只需写入最新的映射关系
always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i=0;i<32;i=i+1)
			rat[i] <= i;
	end
	else begin
		if(retire[0] && rob_areg_v[i])begin//指令准备退休 && 存在目的寄存器，才需要写映射关系进rat
			if(~(((rob_areg[0] == rob_areg[1]) && rob_areg_v[1] && retire[1]) | ((rob_areg[0] == rob_areg[2]) && rob_areg_v[2] && retire[2]) | ((rob_areg[0] == rob_areg[3]) && rob_areg_v[3] && retire[3])))//指令1/指令2/指令3(准备退休) && 目的寄存器和指令0的目的寄存器相同，则指令0不写RAT
    	    	rat[rob_areg[0]] <= rob_preg[0]; 
		end
		if(retire[1] && rob_areg_v[1])begin
			if(~(((rob_areg[1] == rob_areg[2]) && rob_areg_v[2] && retire[2) | ((rob_areg[1] == rob_areg[3]) && rob_areg_v[3] && retire[3])))//指令2/指令3(准备退休) && 目的寄存器和指令1的目的寄存器相同，则指令1不写RAT
    	    	rat[rob_areg[1]] <= rob_preg[1] ;
		end
		if(retire[2] && rob_areg_v[2])begin
			if(~((rob_areg[2] == rob_areg[3]) && rob_areg_v[3] && retire[3))//指令3(准备退休) && 目的寄存器和指令2的目的寄存器相同，则指令2不写RAT
    	    	rat[rob_areg[2]] <= rob_preg[2] ;
		end
    	if(retire[3] && rob_areg_v[3])
    		rat[rob_areg[3]] <= rob_preg[3];//指令3只要存在目的寄存器，指令3的新映射关系一定会被写入
	end
end
//根据本周期退休指令数，更新读指针
always@(posedge clk or posedge rst)begin
    if(rst)
        head_pointer <= 1'b0;
    else 
        head_pointer <= head_pointer + retire_num;
end

//更新写指针,每周期译码四条指令
always@(posedge clk or posedge rst)begin
    if(rst)
        tail_pointer <= 1'b0;
    else 
        tail_pointer <= tail_pointer + 4;
end
//重命名后，将指令写入rob
always@(posedge clk)begin
    for(i=0;i<DECODE_NUM;i=i+1)begin
        rob[tail_pointer-i] = {type[i],exception[i],pc[i],opreg[i],preg[i],areg[i],areg_v[i],1'b0};
    end
end

endmodule
