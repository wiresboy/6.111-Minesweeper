`timescale 1ns / 1ps
module minesweeper_tb;
    logic clk; //~ 65 MHz clock

	logic [10:0] mouse_x;
	logic [9:0] mouse_y;
	logic mouse_left_click;
    
	minesweeper uut(.clk_65mhz(clk),.mouse_x(mouse_x),.mouse_y(mouse_y),.mouse_left_click(mouse_left_click));
    always begin
       #15; 
       clk = !clk;
   end
   initial begin
    clk = 0;
	mouse_left_click=1;
	mouse_x=480;
	mouse_y=400;
	#30;
	//mouse_left_click = 0;
    #150;
    $finish;
   end
endmodule
