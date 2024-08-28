cs_all:
	make cs_arithmetic
	make cs_hazard
	make cs_jump
	make cs_logic
	make cs_mem
	make cs_shift
	make cs_slt
	make cs_u_type

ver_%:
	make change_tb_$* 
	make ver
dve_%:
	make change_tb_$* 
	make dve

cs_%:
	make change_tb_$*
	make cs

DATA_WIDTH=32
TB_NAME=tb
change_tb_%:
	sed -i  '10s/.*/	\$$readmemh\(\".\/test\/registers\/RV$(DATA_WIDTH)\/reg_$*.c\", registers\)\;/' ./test/$(TB_NAME).v 
	sed -i  '11s/.*/	\$$readmemb\(\".\/test\/instructions\/RV$(DATA_WIDTH)\/$*.c\", riscv_top_u1.instr_memory_inst.rom\)\;/' ./test/$(TB_NAME).v 
	sed -i  '47s/.*/            \$$display\(\"~~~~~~~~$*  INSTRUCTIONS TEST PASS ~~~~~~~~~~~"\)\;/' ./test/$(TB_NAME).v 
	sed -i  '58s/.*/            \$$display\(\"~~~~~~~~$*  INSTRUCTIONS TEST FAIL ~~~~~~~~~~~"\)\;/' ./test/$(TB_NAME).v 


ver : com sim run_verdi 
dve : com sim run_dve
cs: com sim

vca: cache 
	verdi -sv  I_cache.v tb_cache.v ./rtl/instr_memory.v \
	-ssf test.fsdb &
cache:
	vcs -sverilog -full64 -debug_acc+all -debug_access+dmptf -timescale=1ns/1ns \
	I_cache.v tb_cache.v ./rtl/instr_memory.v \
	-l com.log
	make sim
vrename: rename
	verdi -sv  ./rtl/rename.v ./test/tb_rename.v  \
	-ssf test.fsdb &
rename:
	vcs -sverilog -full64 -debug_acc+all -debug_access+dmptf -timescale=1ns/1ns \
	 ./rtl/rename.v ./test/tb_rename.v \
	-l com.log
	make sim
vmul: mul
	verdi -sv  ./rtl/multiplier.v ./test/tb_mul.v  \
	-ssf test.fsdb &
mul:
	vcs -sverilog -full64 -debug_acc+all -debug_access+dmptf -timescale=1ns/1ns \
	 ./rtl/multiplier.v ./test/tb_mul.v \
	-l com.log
	make sim



com:
	vcs -sverilog \
	-full64 \
	-debug_acc+all \
	-debug_access+dmptf \
	-timescale=1ns/1ns \
	-f filelist \
	-l com.log \
	+define+DATA_WIDTH=$(DATA_WIDTH)
	 
	
sim:
	./simv -l sim.log +fsdb+functions

run_dve:
	dve -vpd vcdplus.vpd &

run_verdi:
	verdi -sv -f filelist -ssf test.fsdb &

clean:
	rm -rf *.vpd csrc *.log *.key *.vdb simv* DVE* nova* *fsdb verdiLog test.fsdb*

mv:
	-mkdir rtl
	mv ./*.v rtl

find:
	find  -name "*.v">filelist
