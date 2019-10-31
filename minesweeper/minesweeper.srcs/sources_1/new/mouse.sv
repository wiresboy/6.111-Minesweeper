`timescale 1ns / 1ps

module mouse_renderer
	#(	parameter SCREEN_WIDTH=1024, 
		parameter SCREEN_HEIGHT=768)
	(	
	input [10:0] mouse_x,	// Mouse X coord.
	input [9:0] mouse_y,	// Mouse Y coord.

	input [10:0] hcount_in,	// horizontal index of current pixel (0..1023)
	input [9:0] vcount_in,	// vertical index of current pixel (0..767)
	input hsync_in,			// XVGA horizontal sync signal (active low)
	input vsync_in,			// XVGA vertical sync signal (active low)
	input blank_in,			// XVGA blanking (1 means output black pixel)
	input [11:0] pixel_in,	// input pixel to pass through if not under cursor.

	input [10:0] hcount_out,// horizontal index of current pixel (buffered)
	input [9:0] vcount_out,	// vertical index of current pixel (buffered)
	output hsync_out,		// horizontal sync (output with buffering)
	output vsync_out,		// vertical sync (output with buffering)
	output blank_out,		// blanking (output with buffering)
	output [11:0] pixel_out	// pixel r=11:8, g=7:4, b=3:0 (output with buffering)
	);

	//TODO: replace with real logic
	assign hcount_out = hcount_in;
	assign vcount_out = vcount_in;
	assign hsync_out = hsync_in;
	assign vsync_out = vsync_in;
	assign blank_out = blank_in;
	assign pixel_out = pixel_in;

endmodule


module mouse
	#(	parameter SCREEN_WIDTH=1024, 
		parameter SCREEN_HEIGHT=768)
	(
	inout ps2_clk, ps2_data, 	// physical connections 
	output [10:0] mouse_x,		// Mouse X coord.
	output [9:0] mouse_y,		// Mouse Y coord.
	output mouse_left_click,	// Mouse left button clicked. Debounced, but not edge triggered.
	output mouse_right_click	// Mouse right button clicked. Debounced, but not edge triggered.
	);
	assign mouse_x = SCREEN_WIDTH/2;
	assign mouse_y = SCREEN_HEIGHT/2;
	assign mouse_left_click = 0;
	assign mouse_right_click = 0;

endmodule