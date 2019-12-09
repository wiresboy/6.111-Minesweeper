`timescale 1ns / 1ps

module mouse_renderer
	#(	parameter SCREEN_WIDTH=1024, 
		parameter SCREEN_HEIGHT=768,
		parameter MOUSE_INNER_COLOR = 'hFFF,
		parameter MOUSE_OUTER_COLOR = 'h000)
	(	
	input clk_65mhz,
	input reset,
	
	input [10:0] mouse_x,	// Mouse X coord.
	input [9:0] mouse_y,	// Mouse Y coord.

	input [10:0] hcount_in,	// horizontal index of current pixel (0..1023)
	input [9:0] vcount_in,	// vertical index of current pixel (0..767)
	input hsync_in,			// XVGA horizontal sync signal (active low)
	input vsync_in,			// XVGA vertical sync signal (active low)
	input blank_in,			// XVGA blanking (1 means output black pixel)
	input [11:0] pixel_in,	// input pixel to pass through if not under cursor.

	output [10:0] hcount_out,// horizontal index of current pixel (buffered)
	output [9:0] vcount_out,	// vertical index of current pixel (buffered)
	output hsync_out,		// horizontal sync (output with buffering)
	output vsync_out,		// vertical sync (output with buffering)
	output blank_out,		// blanking (output with buffering)
	output logic [11:0] pixel_out	// pixel r=11:8, g=7:4, b=3:0 (output with buffering)
	);

	//This module is pipelined by 2 clocks. Probably could be 1 but doesn't hurt the final product and also probably makes compile easier.

	logic [10:0] hcount [1:0] ;
	logic [9:0] vcount [1:0] ;
	logic hsync [1:0] ;
	logic vsync [1:0] ;
	logic blank [1:0] ;

	logic [11:0] pixel;

	//TODO: replace with real logic

	assign hcount_out = hcount[0];
	assign vcount_out = vcount[0];
	assign hsync_out = hsync[0];
	assign vsync_out = vsync[0];
	assign blank_out = blank[0];

	logic signed [10:0] relative_x;
	logic signed [9:0] relative_y;

	assign relative_x = hcount_in - mouse_x;
	assign relative_y = vcount_in - mouse_y;

	logic [3:0] x; //mouse pixel x
	logic [4:0] y; //mouse pixel y
	logic in_box;

	always_ff @(posedge clk_65mhz) begin

		//2 stage delay
		hcount[0] <= hcount[1];
		vcount[0] <= vcount[1];
		hsync[0] <= hsync[1];
		vsync[0] <= vsync[1];
		blank[0] <= blank[1];

		hcount[1] <= hcount_in;
		vcount[1] <= vcount_in;
		hsync[1] <= hsync_in;
		vsync[1] <= vsync_in;
		blank[1] <= blank_in;
		pixel <= pixel_in;

		//pipeline stage 0
		in_box <= (relative_x>=0) && (relative_x<=11) && (relative_y>=0) && (relative_y<=18);

		x <= relative_x[3:0]; // mouse icon pixel offset
		y <= relative_y[4:0];

		//pipeline stage 1
		if (in_box) begin
			if (
					(y==x) || 
					(y<=16 && x==0) ||
					(y==12 && x>=7) ||
					(y==13 && (x==4||x==7)) ||
					(y==14 && (x==3||x==5||x==8)) ||
					(y==15 && (x==2||x==5||x==8)) ||
					(y==16 && (x==1||x==6||x==9)) ||
					(y==17 && (x==6||x==9)) ||
					(y==18 && (x==7||x==8))
				) 
				pixel_out <= MOUSE_OUTER_COLOR;
			else if (
					(y <= 12 && x<=y) ||
					(y == 13 && x < 7) ||
					(y == 14 && (x==1||x==2||x==6||x==7)) ||
					(y == 15 && (x==1||x==6||x==7)) ||
					((y==16||y==17) && (x==7||x==8))
				)
				pixel_out <= MOUSE_INNER_COLOR;
			else
				pixel_out <= pixel;

		end else begin
			pixel_out <= pixel;
		end

	end


endmodule
