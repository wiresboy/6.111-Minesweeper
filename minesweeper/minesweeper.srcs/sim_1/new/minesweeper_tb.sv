`timescale 1ns / 1ps
module minesweeper_tb;
    logic clk; //~ 65 MHz clock

	logic [10:0] mouse_x;
	logic [9:0] mouse_y;
	logic mouse_left_click,mouse_right_click;
	logic [10:0] hcount_in;
	logic [9:0] vcount_in;
	logic [11:0] pixel_out;
	logic reset;
    
	minesweeper uut(.clk_65mhz(clk),.mouse_x(mouse_x),.mouse_y(mouse_y),.mouse_left_click(mouse_left_click),.hcount_in(hcount_in),
		.vcount_in(vcount_in),.pixel_out(pixel_out),.reset(reset),.mouse_right_click(mouse_right_click));
    always begin
       #15; 
       clk = !clk;
   end
   initial begin
    clk = 0;
	reset = 0;
	#40;
	reset = 1;
	mouse_left_click=1;
	mouse_right_click=1;
	mouse_x=8;
	mouse_y=200;
	hcount_in = 600;
	vcount_in = 200; //
	#30;
	reset = 0;
	#30;
	hcount_in = 0;
	vcount_in = 0; //expect tile_number of 2, should draw 0's bits
    #150;
    $finish;
   end
endmodule
