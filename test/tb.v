module tb();
parameter DATA_WIDTH = `DATA_WIDTH;
reg	clk;
reg rst_n;
wire[7:0]rom_addr;
reg	[DATA_WIDTH-1:0]registers [31:0];


initial begin
	$readmemh("./test/registers/RV32/reg_logic.c", registers);
	$readmemb("./test/instructions/RV32/logic.c", riscv_top_u1.instr_memory_inst.rom);
end

riscv_top riscv_top_u1(
	.clk(clk),
	.rst_n(rst_n),
	.rom_addr(rom_addr)
    );




integer i;
integer j=0;
initial begin 
	rst_n = 0;
	#5;
	rst_n = 1;
	#1000 
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	for(i=0;i<32;i=i+1)begin
		$display("regs[%2d] = 0x%h  correct_registers[%2d] = 0x%h",i,riscv_top_u1.riscv_inst.datapath_inst.registers_inst.regs[i],i,registers[i]);
	end
	for(i=0;i<32;i=i+1)begin
		if(riscv_top_u1.riscv_inst.datapath_inst.registers_inst.regs[i]==registers[i])begin
			j++;
		end
		else begin
			$display("regs[%2d]  !=  correct_registers[%2d] ",i,i);
		end
	end	
	
		$display("~~~~~~~~How many regs are correct?   %2d ~~~~~~~~", j);
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	if(j==32)begin
            $display("~~~~~~~~logic  INSTRUCTIONS TEST PASS ~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
            $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end 
	else begin
            $display("~~~~~~~~logic  INSTRUCTIONS TEST FAIL ~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	end
	$finish;
end

always begin
	clk = 1;
	#10;
	clk = 0;
	#10;
	
end

initial begin
	$vcdpluson;
	$vcdplusmemon;
end

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0,tb,"+all");
end

endmodule
