debImport "-sv" "-f" "filelist"
debLoadSimResult /home/host/digital_ic/RV64-order/test.fsdb
wvCreateWindow
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalClose -win $_nWave2
srcHBSelect "tb.riscv_top_u1" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.riscv_top_u1" -delim "."
srcHBSelect "tb.riscv_top_u1" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.instr_memory_inst" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.riscv_inst" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.riscv_top_u1.riscv_inst" -delim "."
srcHBSelect "tb.riscv_top_u1.riscv_inst" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.riscv_inst.datapath_u0" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.riscv_inst" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.riscv_inst.control_u0" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.riscv_top_u1.riscv_inst.control_u0" -delim "."
srcHBSelect "tb.riscv_top_u1.riscv_inst.control_u0" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.riscv_inst.control_u0" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.riscv_top_u1.riscv_inst.control_u0" -delim "."
srcHBSelect "tb.riscv_top_u1.riscv_inst.control_u0" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.riscv_inst.datapath_u0" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.instr_memory_inst" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.riscv_top_u1.instr_memory_inst" -delim "."
srcHBSelect "tb.riscv_top_u1.instr_memory_inst" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.riscv_inst.datapath_u0" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.riscv_top_u1.riscv_inst.datapath_u0" -delim "."
srcHBSelect "tb.riscv_top_u1.riscv_inst.datapath_u0" -win $_nTrace1
srcHBSelect "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0" -delim "."
srcHBSelect "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0" -win \
           $_nTrace1
srcSignalView -on
srcSignalViewSelect \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.instr\[31:0\]"
srcSignalViewSelect \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.instr\[31:0\]" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.opcode\[6:0\]" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.func3\[2:0\]" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.func7" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.Rs1\[4:0\]" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.Rs2\[4:0\]" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.Rd\[4:0\]" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.imme" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.DATA_WIDTH" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.I_type" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.U_type" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.J_type" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.B_type" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.S_type" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.I_imme" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.U_imme" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.J_imme" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.B_imme" \
           "tb.riscv_top_u1.riscv_inst.datapath_u0.instr_decode_u0.S_imme"
wvCreateWindow
wvSetPosition -win $_nWave3 {("G1" 0)}
wvOpenFile -win $_nWave3 {/home/host/digital_ic/RV64-order/test.fsdb}
srcSignalViewAddSelectedToWave -win $_nTrace1 -clipboard
wvDrop -win $_nWave3
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
srcSignalView -off
verdiDockWidgetMaximize -dock windowDock_nWave_3
wvZoomAll -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomIn -win $_nWave3
wvZoomIn -win $_nWave3
