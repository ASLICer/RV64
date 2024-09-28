
`include "./rtl/define.v"
module tb_arbiter();
parameter OP = `R_type;
parameter OPCODE_WIDTH = 7;
parameter REQ = 1;
parameter AGE_WIDTH = 5;
parameter ISSUE_DEPTH = 16;

reg [OPCODE_WIDTH-1:0] op_correct;//随机选择一种指令类型进行仲裁
reg [OPCODE_WIDTH-1:0] op [ISSUE_DEPTH-1:0];
reg [ISSUE_DEPTH-1:0] req ;
reg [AGE_WIDTH-1:0] age [ISSUE_DEPTH-1:0];
wire grant;//请求发射成功
wire [3:0] addr;
reg muti_finish;

integer op_correct_num;
initial begin
    #`RUNTIME $finish;
end
integer m,n;
integer op_num;
initial begin
    muti_finish = 1;
    forever begin  
		op_correct_num = {$random}%13;
		case(op_correct_num)
		    0: op_correct = 7'b0110111;//lui 55
		    1: op_correct = 7'b0010111;//auipc 23	
		    2: op_correct = 7'b1101111;//jal	111	
		    3: op_correct = 7'b1100111;//jalr 103	
		    4: op_correct = 7'b1100011;//B_type 99
		    5: op_correct = 7'b0000011;//load 3	
		    6: op_correct = 7'b0100011;//store 35	
		    7: op_correct = 7'b0010011;//I_type 19
		    8: op_correct = 7'b0110011;//R_type 51
		    9: op_correct = 7'b0011011;//Iw_type	27
		    10:op_correct = 7'b0111011;//Rw_type	59
		    11:op_correct = 7'b0110011;//MD_type 51
		    12:op_correct = 7'b0111011;//MDW_type 59
		    default:op_correct = 7'b0110011;
		endcase

        for(m=0;m<ISSUE_DEPTH;m=m+1)begin//随机生成指令opcode(rv64I有13种)
            op_num = {$random}%13;
            case(op_num)
                0: op[m] = 7'b0110111;//lui 55
                1: op[m] = 7'b0010111;//auipc 23	
                2: op[m] = 7'b1101111;//jal	111	
                3: op[m] = 7'b1100111;//jalr 103	
                4: op[m] = 7'b1100011;//B_type 99
                5: op[m] = 7'b0000011;//load 3	
                6: op[m] = 7'b0100011;//store 35	
                7: op[m] = 7'b0010011;//I_type 19
                8: op[m] = 7'b0110011;//R_type 51
                9: op[m] = 7'b0011011;//Iw_type	27
                10:op[m] = 7'b0111011;//Rw_type	59
                11:op[m] = 7'b0110011;//MD_type 51
                12:op[m] = 7'b0111011;//MDW_type 59
                default:op[m] = 7'b0110011;
            endcase
        end

        age[0] = {$random}%(ISSUE_DEPTH);//随机生成指令的年龄,不重复
        for(m=1;m<ISSUE_DEPTH;m=m+1)begin
            age[m]={$random}%16;
            for(n=0;n<m;n=n+1)begin
                if(age[m] == age[n])
                    m = m-1 ;
            end
        end
        for(m=0;m<ISSUE_DEPTH;m=m+1)begin//随机生成指令是否发出请求
            req[m] = {$random}%2;
        end
        #10;
    end
end

arbiter #(
    OPCODE_WIDTH,
    REQ,
    AGE_WIDTH
)
arbiter_inst
(
	op_correct,
    op,
    req,
    age,

    grant,//请求发射成功
    addr,
    muti_finish
);//最小的年龄值对应最旧的指令

integer addr_correct,age_correct,k;
initial begin 
    #1;
    k = 0;
    forever begin  
        addr_correct = 16;
		age_correct = 16;
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~cycle%2d~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",k);
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ISSUE QUEUE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
		$display("~~~~~~~~~~~~~~~~~~~~~~~~~~correct op: %3d~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",op_correct);
		$display("| addr |  op | age | req | ");
        for(integer i=0;i<ISSUE_DEPTH;i=i+1) begin//find correct addr
            if(op[i] == op_correct && req[i] == 1)begin//指令类型正确 && 请求有效
				if(age_correct > age[i])begin
                	addr_correct = i;
					age_correct = age[i];
				end
			end
        end

		for(integer i=0;i<ISSUE_DEPTH;i=i+1) begin//display issue queue

			if(op[i] == op_correct && req[i] == 1 && age[i] == age_correct)
            	$display("| %4d | %3d | %3d | %3d | ◎  √ ",i,op[i],age[i],req[i]);
			else if(op[i] == op_correct && req[i] == 1)
            	$display("| %4d | %3d | %3d | %3d | ◎ ",i,op[i],age[i],req[i]);
			else
				$display("| %4d | %3d | %3d | %3d |",i,op[i],age[i],req[i]);
        end

        if(addr_correct == arbiter_inst.addr && grant)//队列请求有效 && 理论地址 = 电路计算出的地址
            $display("ISSUE QUEUE %2d: Pass ! The instruction in addr = %2d will be issued !",k,addr_correct);
        else if(addr_correct != arbiter_inst.addr && grant)begin//队列请求有效&&理论地址 = 电路计算出的地址
			$display("ISSUE QUEUE %2d: Fail ! The arbiter circuit has errors !",k);
			$finish;
		end
		else//队列请求有效(所有指令的指令类型和请求有效没有同时满足)
			$display("ISSUE QUEUE %2d: Invalid ! No instruction can be issued !",k);
        k = k + 1;
        #10;
     end
end   

initial begin
	$vcdpluson;
	$vcdplusmemon;
end

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0,tb_arbiter,"+all");
end

endmodule
