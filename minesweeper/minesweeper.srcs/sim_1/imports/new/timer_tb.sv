`timescale 1ns / 1ps
module timer_tb;
    logic clk; //~ 65 MHz clock
	logic[5:0] count_out;
	logic reset,start_timer;
    
	timer uut(.clock(clk),.start_timer(start_timer),.count_out(count_out));
    always begin
       #15; 
       clk = !clk;
   end
   initial begin
    clk = 0;
	reset = 0;
	#60;
	reset = 1;
	#30;
	reset=0;
	start_timer = 1;
	#30;
	start_timer = 0;
	#500;
    $finish;
   end
endmodule
