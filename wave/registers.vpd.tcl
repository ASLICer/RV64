# Begin_DVE_Session_Save_Info
# DVE view(Wave.1 ) session
# Saved on Wed Jul 31 15:56:53 2024
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Wave.1: 11 signals
# End_DVE_Session_Save_Info

# DVE version: O-2018.09-1_Full64
# DVE build date: Oct 12 2018 21:19:11


#<Session mode="View" path="/home/host/digital_ic/risc_v_5pipeline/wave/registers.vpd.tcl" type="Debug">

#<Database>

gui_set_time_units 1s
#</Database>

# DVE View/pane content session: 

# Begin_DVE_Session_Save_Info (Wave.1)
# DVE wave signals session
# Saved on Wed Jul 31 15:56:53 2024
# 11 signals
# End_DVE_Session_Save_Info

# DVE version: O-2018.09-1_Full64
# DVE build date: Oct 12 2018 21:19:11


#Add ncecessay scopes
gui_load_child_values {tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0}

gui_set_time_units 1s

set _wave_session_group_1 Group1
if {[gui_sg_is_group -name "$_wave_session_group_1"]} {
    set _wave_session_group_1 [gui_sg_generate_new_name]
}
set Group1 "$_wave_session_group_1"

gui_sg_addsignal -group "$_wave_session_group_1" { {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.clk} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.rst_n} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.W_en} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.Rs1} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.Rs2} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.Rd} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.Wr_data} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.Rd_data1} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.Rd_data2} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.i} {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.regs} }
gui_set_radix -radix {decimal} -signals {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.i}
gui_set_radix -radix {twosComplement} -signals {V1:tb.riscv_top_u1.riscv_inst.datapath_u0.registers_u0.i}
if {![info exists useOldWindow]} { 
	set useOldWindow true
}
if {$useOldWindow && [string first "Wave" [gui_get_current_window -view]]==0} { 
	set Wave.1 [gui_get_current_window -view] 
} else {
	set Wave.1 [lindex [gui_get_window_ids -type Wave] 0]
if {[string first "Wave" ${Wave.1}]!=0} {
gui_open_window Wave
set Wave.1 [ gui_get_current_window -view ]
}
}

set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 0 398
gui_list_add_group -id ${Wave.1} -after {New Group} [list ${Group1}]
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group ${Group1}  -position in

gui_marker_move -id ${Wave.1} {C1} 0
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
#</Session>

