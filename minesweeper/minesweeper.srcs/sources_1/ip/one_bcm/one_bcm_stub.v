// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue Nov 19 10:42:29 2019
// Host        : DESKTOP-RQQ2FB3 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top one_bcm -prefix
//               one_bcm_ one_bcm_stub.v
// Design      : one_bcm
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module one_bcm(clka, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,addra[4:0],douta[7:0]" */;
  input clka;
  input [4:0]addra;
  output [7:0]douta;
endmodule
