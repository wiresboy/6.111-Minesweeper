vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm -64 -incr -sv \
"C:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_addr_decode.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_read.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg_bank.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_top.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_write.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_ar_channel.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_aw_channel.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_b_channel.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_arbiter.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_fsm.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_translator.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_fifo.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_incr_cmd.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_r_channel.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_simple_fifo.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wrap_cmd.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wr_cmd_fsm.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_axi_mc_w_channel.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_axic_register_slice.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_register_slice.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_upsizer.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_a_upsizer.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_and.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_and.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_or.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_or.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_command_fifo.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel_static.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_r_upsizer.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/axi/mig_7series_v4_2_ddr_w_upsizer.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/clocking/mig_7series_v4_2_clk_ibuf.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/clocking/mig_7series_v4_2_infrastructure.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/clocking/mig_7series_v4_2_iodelay_ctrl.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/clocking/mig_7series_v4_2_tempmon.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_arb_mux.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_arb_row_col.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_arb_select.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_cntrl.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_common.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_compare.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_mach.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_queue.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_state.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_col_mach.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_mc.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_rank_cntrl.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_rank_common.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_rank_mach.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/controller/mig_7series_v4_2_round_robin_arb.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ecc/mig_7series_v4_2_ecc_buf.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ecc/mig_7series_v4_2_ecc_dec_fix.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ecc/mig_7series_v4_2_ecc_gen.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ecc/mig_7series_v4_2_ecc_merge_enc.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ecc/mig_7series_v4_2_fi_xor.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_axi.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ip_top/mig_7series_v4_2_mem_intfc.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_group_io.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_lane.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_calib_top.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_if_post_fifo.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy_wrapper.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_of_pre_fifo.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_4lanes.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal_hr.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_init.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_cntlr.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_data.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_edge.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_lim.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_mux.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_po_cntlr.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_samp.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_oclkdelay_cal.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_prbs_rdlvl.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_rdlvl.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_tempmon.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_top.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrcal.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl_off_delay.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_prbs_gen.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_cc.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_edge_store.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_meta.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_pd.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_tap_base.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_top.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ui/mig_7series_v4_2_ui_cmd.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ui/mig_7series_v4_2_ui_rd_data.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ui/mig_7series_v4_2_ui_top.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ui/mig_7series_v4_2_ui_wr_data.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ram_to_ddr_mig_sim.v" \
"../../../../minesweeper.srcs/sources_1/ip/ram_to_ddr/ram_to_ddr/user_design/rtl/ram_to_ddr.v" \

vlog -work xil_defaultlib \
"glbl.v"

