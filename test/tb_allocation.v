
module tb_allocation();
parameter DECODE_NUM = 4;
parameter CIQ_DEPTH = 16;
reg [CIQ_DEPTH-1:0] ciq_free;//16个空闲标志位   
wire [($clog2(CIQ_DEPTH)-1):0] free_addr [DECODE_NUM-1:0];//发射队列空闲表项的地址
wire [DECODE_NUM-1:0] free_valid;//所在地址确实是空闲的 

reg [($clog2(CIQ_DEPTH)-1):0] true_free_addr [DECODE_NUM-1:0];//正确的发射队列空闲表项的地址
reg [($clog2(CIQ_DEPTH)-1):0] random_bits [DECODE_NUM-1:0];//用于随机生成含有4个1所在位置
initial begin
    #`RUNTIME $finish;
end

integer i,j,k,l,m,n,x,y,bits_of1;
integer BIT1_NUM;
initial begin
    #170 BIT1_NUM = 4;
    #100 BIT1_NUM = 3;
    #100 BIT1_NUM = 2;
    #100 BIT1_NUM = 1;
    #100 BIT1_NUM = 4;    
end
initial begin
    ciq_free = 'b0000_0000_0000_0000;
    #10;
    //ciq_free[3:0]
    ciq_free = 'b0000_0000_0000_0001;
    #10;
    ciq_free = 'b0000_0000_0000_0011;
    #10;
    ciq_free = 'b0000_0000_0000_0111;
    #10;
    ciq_free = 'b0000_0000_0000_1111;
    #10;
    //ciq_free[7:4]
    ciq_free = 'b0000_0000_0001_0000;
    #10;
    ciq_free = 'b0000_0000_0011_0000;
    #10;
    ciq_free = 'b0000_0000_0111_0000;
    #10;
    ciq_free = 'b0000_0000_1111_0000;
    #10;
    //ciq_free[11:8]
    ciq_free = 'b0000_0001_0000_0000;
    #10;
    ciq_free = 'b0000_0011_0000_0000;
    #10;
    ciq_free = 'b0000_0111_0000_0000;
    #10;
    ciq_free = 'b0000_1111_0000_0000;
    #10;
    //ciq_free[15:12]
    ciq_free = 'b0001_0000_0000_0000;
    #10;
    ciq_free = 'b0011_0000_0000_0000;
    #10;
    ciq_free = 'b0111_0000_0000_0000;
    #10;
    ciq_free = 'b1111_0000_0000_0000;
    #10;
    
    for(integer i=0;i<40;i=i+1) begin   //4 bits of 1
        random_bits[0] = {$random}%16;
        for(m=1;m<BIT1_NUM;m=m+1)begin
            random_bits[m]={$random}%16;
            for(n=0;n<m;n=n+1)begin
                if(random_bits[m] == random_bits[n])
                    m = m-1 ;
            end
        end

        ciq_free = 'b0000_0000_0000_0000;
        for(m=0;m<BIT1_NUM;m=m+1)begin
            ciq_free[random_bits[m]] = 1;
        end
        #10;
    end
    forever begin //more or less than 4bits of 1
        ciq_free = {$random}%(2**16-1);
        #10;
    end    
end
initial begin
    #1;
    forever begin
        x = 0;
        for(y=0;y<DECODE_NUM;y=y+1)begin
            true_free_addr[y] = 'bx;
        end
        for(y=0;(y<CIQ_DEPTH && x < DECODE_NUM);y=y+1)begin
            if(ciq_free[y] == 1'b1)begin
                true_free_addr[x] = y;
                x = x+1;
            end
        end
        #10;
    end
end

allocation #(
   DECODE_NUM,
   CIQ_DEPTH
)
allocation_inst
(
    ciq_free,//16个空闲标志位   
    free_addr,//发射队列空闲表项的地址
    free_valid//所在地址确实是空闲的   
);

initial begin 
    #5;
    k = 0;
    forever begin
        
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~cycle%2d~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",k);
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~case%2d: %b_%b_%b_%b~~~~~~~~~~~~~~~~~~~~",k,ciq_free[15:12],ciq_free[11:8],ciq_free[7:4],ciq_free[3:0]);
        bits_of1 = 0;
        for(l=0;l<CIQ_DEPTH;l=l+1)begin
            bits_of1 = bits_of1 + ciq_free[l];
        end
        if(bits_of1 >= 4)
            bits_of1 = 4;
        else  
            bits_of1 = bits_of1;
	    for(i=0;i<DECODE_NUM;i=i+1)begin
            if(i<bits_of1)
	    	    $display("free_addr[%2d] = %d  true_free_addr[%2d] = %d",i,allocation_inst.free_addr[i],i,true_free_addr[i]);
            else
                $display("free_addr[%2d] = xx  true_free_addr[%2d] = xx",i,i);
	    end

        j = 0;
	    for(i=0;i<bits_of1;i=i+1)begin
	    	if(allocation_inst.free_addr[i] == true_free_addr[i])begin
	    		j++;
	    	end
	    	else begin
	    		$display("Fail!!! allocation_inst.free_addr[i]  !=  true_free_addr[i] ",i,i);
                $finish;
	    	end
	    end	
        if(j == bits_of1)begin
            $display("case%2d: Pass",k);
        end
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
    $fsdbDumpvars(0,tb_allocation,"+all");
end

endmodule
