module hazard(
	//fetch stage
	output 	wire 			stallF,
	//decode stage
	input 	wire 	[4:0]	Rs1D,
	input 	wire 	[4:0]	Rs2D,
	input 	wire 			branchD,
	input	wire			jalD,
	input	wire			jalrD,
	input	wire			luiD,
	input	wire			auipcD,
	input	wire			memwriteD,
	output 	reg		[1:0]	forwardaD,
	output 	reg	 	[1:0]	forwardbD,
	output 	wire 			stallD,
	//execute stage
	input 	wire 	[4:0]	Rs1E,
	input 	wire 	[4:0]	Rs2E,
	input 	wire 	[4:0]	RdE,
	input 	wire 			regwriteE,
	input 	wire 			memtoregE,
	output 	reg 	[1:0]	forwardaE,
	output 	reg 	[1:0]	forwardbE,
	output 	wire 			flushE,
	//mem stage
	input 	wire 	[4:0]	Rs2M,
	input 	wire 	[4:0]	RdM,
	input 	wire 			regwriteM,
	input 	wire 			memtoregM,
	input 	wire 			memwriteM,
	input 	wire 			memreadM,
	output	wire			forwardM,
	//write back stage
	input 	wire 	[4:0]	RdW,
	input 	wire 			regwriteW
);

wire lwstall;
wire branchstallD;
wire jalrstallD;
//forwarding sources to D stage(used for B/jalr)
always@(*)begin
	if(Rs1D != 0)begin
		if(Rs1D == RdM & regwriteM & ~memreadM)//M前推到D(2 cylces)，B follow load can't forward
			forwardaD=2'b10;
		else if(Rs1D == RdW & regwriteW)//W前推到D(3 cylces)
			forwardaD=2'b01;
		else	
			forwardaD=2'b00;
	end
	else
		forwardaD=2'b00;
end
always@(*)begin
	if(Rs2D != 0)begin
		if(Rs2D == RdM & regwriteM & ~memreadM)//M前推到D(2 cylces)，B follow load can't forward
			forwardbD=2'b10;
		else if(Rs2D == RdW & regwriteW)//W前推到D(3 cylces)
			forwardbD=2'b01;
		else	
			forwardbD=2'b00;
	end
	else
		forwardbD=2'b00;
end

//forwarding sources to E stage(ALU)
always@(*)begin
	if(Rs1E != 0)begin
		if(Rs1E == RdM & regwriteM)
			forwardaE=2'b10;
		else if(Rs1E == RdW & regwriteW)
			forwardaE=2'b01;
		else	
			forwardaE=2'b00;
	end
	else
		forwardaE=2'b00;
end

always@(*)begin
	if(Rs2E != 0)begin
		if((Rs2E == RdM & regwriteM) & ~memreadM)//store(rs1) follow load can't forward to ex_stage
			forwardbE=2'b10;					 //store(rs2) follow load can forward to mem_stage
		else if(Rs2E == RdW & regwriteW)
			forwardbE=2'b01;
		else
			forwardbE=2'b00;
	end
	else
		forwardbE=2'b00;
end

//forwarding sources to M stage(store(rs2) follow load)
assign forwardM=memwriteM & ((Rs2M != 0) & (Rs2M == RdW));
//if Rs2M==0,then don't need to forward,because the value in x0 is always 0
//not necessary to stall D stage on store
//if source comes from load;
//instead,another bypass network should be 
//added from W to M



//stalls
assign lwstall	=~luiD & ~auipcD & ~jalD & memtoregE	& 	(RdE == Rs1D | (~memwriteD & RdE == Rs2D));
//R/I/B/jalr_type follow load_type 1 cycles,stall D stage
//lui/auipc/jal指令没有rs1和rs2一说，需要避免误暂停
//store(rs1) follow load need to stall
//store(rs2) follow load should avoid to stall

assign branchstallD	=branchD	& 	((regwriteE & (RdE == Rs1D | RdE == Rs2D)) |	//B_type follow R/I/jalr/jal/U/load_type
									(memtoregM & (RdM == Rs1D | RdM == Rs2D)));	//B_type follow load_type 2 cycles
assign jalrstallD	=jalrD  	&	((regwriteE & RdE == Rs1D) |					//jalr follow R/I/jalr/jal/U/load_type
								  	(memtoregM & RdM == Rs1D));					//jalr follow load_type 2 cycles
assign stallD=lwstall | branchstallD | jalrstallD;
assign stallF=stallD;
//stalling D stalls all previous stages
assign flushE=stallD;
//stalling D flushes next stage,otherwise will always RdE=RsD
endmodule
