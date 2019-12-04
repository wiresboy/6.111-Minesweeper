# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir {C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.cache/wt} [current_project]
set_property parent.project_path {C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.xpr} [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
set_property ip_output_repo {c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.cache/ip} [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/1.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/facing_down.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/1_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/1_bcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/1_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/facing_down_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/0.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/0_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/0_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/0_bcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/facing_down_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/facing_down_bcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/2.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/2_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/2_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/2_bcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/3.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/3_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/3_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/3_bcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/4.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/4_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/4_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/4_bcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/5.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/5_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/5_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/5_bcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/6.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/6_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/6_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/6_bcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/flag.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/flag_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/flag_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/flag_bcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/bomb.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/bomb_rcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/bomb_gcm.coe}}
add_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/Images/bomb_bcm.coe}}
read_verilog -library xil_defaultlib -sv {
  {C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/new/minesweeper.sv}
  {C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/new/mouse.sv}
  {C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/new/utils.sv}
  {C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/new/top_level.sv}
}
read_verilog -library xil_defaultlib {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/imports/6.111/clk_wiz_lab3.v}}
read_vhdl -library xil_defaultlib {
  {C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/new/Ps2Interface.vhd}
  {C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/new/mouse_ctl.vhd}
}
read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/one_bcm/one_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/one_bcm/one_bcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/one_rcm/one_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/one_rcm/one_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/facing_down_image_rom/facing_down_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/facing_down_image_rom/facing_down_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/zero_bcm/zero_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/zero_bcm/zero_bcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/facing_down_rcm/facing_down_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/facing_down_rcm/facing_down_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/zero_gcm/zero_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/zero_gcm/zero_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/zero_rcm/zero_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/zero_rcm/zero_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/zero_image_rom/zero_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/zero_image_rom/zero_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/one_gcm/one_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/one_gcm/one_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/one_image_rom_2/one_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/one_image_rom_2/one_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/facing_down_gcm/facing_down_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/facing_down_gcm/facing_down_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/facing_down_bcm/facing_down_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/facing_down_bcm/facing_down_bcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/two_image_rom/two_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/two_image_rom/two_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/two_rcm/two_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/two_rcm/two_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/two_gcm/two_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/two_gcm/two_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/two_bcm/two_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/two_bcm/two_bcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/three_image_rom/three_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/three_image_rom/three_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/three_rcm/three_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/three_rcm/three_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/three_gcm/three_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/three_gcm/three_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/three_bcm/three_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/three_bcm/three_bcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/four_image_rom/four_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/four_image_rom/four_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/four_rcm/four_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/four_rcm/four_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/four_gcm/four_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/four_gcm/four_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/four_bcm/four_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/four_bcm/four_bcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/five_image_rom/five_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/five_image_rom/five_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/five_rcm/five_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/five_rcm/five_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/five_gcm/five_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/five_gcm/five_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/five_bcm/five_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/five_bcm/five_bcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/six_image_rom/six_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/six_image_rom/six_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/six_rcm/six_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/six_rcm/six_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/six_gcm/six_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/six_gcm/six_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/six_bcm/six_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/six_bcm/six_bcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/flag_image_rom/flag_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/flag_image_rom/flag_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/flag_rcm/flag_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/flag_rcm/flag_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/flag_gcm/flag_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/flag_gcm/flag_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/flag_bcm/flag_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/flag_bcm/flag_bcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/bomb_image_rom/bomb_image_rom.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/bomb_image_rom/bomb_image_rom_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/bomb_rcm/bomb_rcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/bomb_rcm/bomb_rcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/bomb_gcm/bomb_gcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/bomb_gcm/bomb_gcm_ooc.xdc}}]

read_ip -quiet {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/bomb_bcm/bomb_bcm.xci}}
set_property used_in_implementation false [get_files -all {{c:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/sources_1/ip/bomb_bcm/bomb_bcm_ooc.xdc}}]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/constrs_1/imports/6.111/nexys4_ddr_lab3.xdc}}
set_property used_in_implementation false [get_files {{C:/Users/Rod Bayliss III/6.111-Minesweeper/minesweeper/minesweeper.srcs/constrs_1/imports/6.111/nexys4_ddr_lab3.xdc}}]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top top_level -part xc7a100tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top_level.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_level_utilization_synth.rpt -pb top_level_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
