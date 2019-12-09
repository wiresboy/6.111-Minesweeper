`timescale 1ns / 1ps

module random_test;
	logic rst=1;
	logic clk=0;
	logic [15:0] random_number;
	always #0.001 clk<=!clk;

	random random(clk, rst, random_number);

	initial begin
		#0.01
		rst=0;
	end


endmodule
