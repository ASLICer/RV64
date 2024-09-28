module main_control#(
    parameter ISSUE_NUM = 4
)(
	input	[6:0]	opcode [3:0],
	input	[2:0]	func3  [3:0],

    //to alu
	output	reg [1:0]	aluop [2:0],
    output              alusrc_pc[1:0],
    output			    alusrc[1:0],

    output			memread   [1:0],  
	output			memwrite  [1:0],
	output	[2:0]	RW_type   [1:0],

    //to bru
	output			jal,
	output			jalr,
	output			beq,
	output			bne,
	output			blt,
	output			bge,
	output			bltu,
	output			bgeu,

    output			regwrite  [3:0]//bru不会写目的寄存器
);

//alu
wire	R_type  [1:0];
wire	I_type  [1:0];//here don't include load and jalr
wire	load    [1:0];
wire	store   [1:0];
wire	Rw_type [1:0];
wire	Iw_type [1:0];
wire    lui     [1:0];
wire    auipc   [1:0];
//mdu

//bru
wire	B_type;

//to alu
generate
    genvar i;
    for(i=0;i<2;i=i+1)begin:alu_type
        assign 	R_type	[i] = (opcode[i] == `R_type) 	? 1'b1 : 1'b0;
        assign 	I_type	[i] = (opcode[i] == `I_type)	? 1'b1 : 1'b0;
        assign 	load	[i] = (opcode[i] == `load)  	? 1'b1 : 1'b0;
        assign 	store	[i] = (opcode[i] == `store) 	? 1'b1 : 1'b0;
        assign 	Rw_type	[i] = (opcode[i] == `Rw_type)   ? 1'b1 : 1'b0;
        assign 	Iw_type	[i] = (opcode[i] == `Iw_type)	? 1'b1 : 1'b0;
        assign	lui		[i] = (opcode[i] == `lui) 	    ? 1'b1 : 1'b0;
        assign	auipc	[i] = (opcode[i] == `auipc)	    ? 1'b1 : 1'b0;
        assign	RW_type	[i] = func3[i];

        //enable
        assign 	memread	[i] = load[i];
        assign 	memwrite[i] = store[i];

        //src control mux
        assign  alusrc_pc[i]=auipc[i];//pc + uimme 
        assign 	alusrc[i]	=load[i] | store[i] | I_type[i] | Iw_type[i] | auipc[i];//select imme as the second source data for alu

        //aluop(self define)
        //load/store use alu to calculate address of data_memory
        //lui use alu to directly {uimme,12'b0} ,auipc use alu to calculate pc + {uimme,12'b0}
        always@(*)begin
        	case({R_type[i],I_type[i],Rw_type[i],Iw_type[i],load[i] | store[i] | auipc[i],lui[i]})	
        		6'b100000:aluop[i] = 3'b000;
        		6'b010000:aluop[i] = 3'b001;
        		6'b001000:aluop[i] = 3'b010;
        		6'b000100:aluop[i] = 3'b011;
            	6'b000010:aluop[i] = 3'b100; 
                6'b000001:aluop[i] = 3'b101;   
        		default:aluop  [i] = 3'b000;
        	endcase
        end
    end
endgenerate


//to bru
assign 	B_type	=(opcode[3] ==`B_type)	? 1'b1 : 1'b0;
assign	jal		=(opcode[3] ==`jal)		? 1'b1 : 1'b0;
assign	jalr	=(opcode[3] ==`jalr)	? 1'b1 : 1'b0;
assign	beq		= B_type & (func3[3] == 3'b000);
assign	bne		= B_type & (func3[3] == 3'b001);
assign	blt		= B_type & (func3[3] == 3'b100);
assign	bge		= B_type & (func3[3] == 3'b101);
assign	bltu	= B_type & (func3[3] == 3'b110);
assign	bgeu	= B_type & (func3[3] == 3'b111);

//whether write registers
assign 	regwrite[0] = load[0] | I_type[0] | R_type[0] | lui[0] | auipc[0] | Rw_type[0] | Iw_type[0];//只有store 不写寄存器
assign 	regwrite[1] = load[1] | I_type[1] | R_type[1] | lui[1] | auipc[1] | Rw_type[1] | Iw_type[1];
assign 	regwrite[2] = 1;//乘除法指令一定写寄存器
assign 	regwrite[3] = jal | jalr;//B_type 不写寄存器

//assign 	memtoreg=load;//select data_memory data to write back



endmodule
