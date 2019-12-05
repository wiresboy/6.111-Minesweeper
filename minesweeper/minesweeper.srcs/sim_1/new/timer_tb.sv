`timescale 1ns / 1ps
module timer_tb;
    logic clk; //~ 65 MHz clock

	logic[5:0] count_out;
	logic [11:0] pixel_out;
	logic reset,start_timer;
    
	timer uut(.clock(clk),.start_timer(start_timer),.count_out(count_out));
    always begin
       #15; 
       clk = !clk;
   end
   initial begin
    clk = 0;
	reset = 0;
	#45;
	reset = 1;
	#15;
	reset=0;
	start_timer = 1;
	#100;
    $finish;
   end
endmodule
