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
	logic [15:0] random;
    
	minesweeper uut(.clk_65mhz(clk),.mouse_x(mouse_x),.mouse_y(mouse_y),.mouse_left_click(mouse_left_click),.hcount_in(hcount_in),
		.vcount_in(vcount_in),.pixel_out(pixel_out),.reset(reset),.mouse_right_click(mouse_right_click),.random(random));
    always begin
       #15; 
       clk = !clk;
   end
   initial begin
    clk = 0;
	reset = 0;
	#45;
	reset = 1;
	mouse_left_click=1;
	mouse_right_click=1;
	mouse_x=8;
	mouse_y=200;
	hcount_in = 600;
	vcount_in = 200; 
	random = 0;
	#30;
	//mouse_left_click = 0;
	mouse_right_click = 0;
	reset = 0;
	random = 33333;
	#30;
	hcount_in = 10;
	vcount_in = 0;
	mouse_right_click = 1;
	mouse_left_click = 1;
	#30;
	mouse_right_click = 0;
	mouse_left_click = 0;
	#60;
	random = 0;
	#150;
    $finish;
   end
endmodule
