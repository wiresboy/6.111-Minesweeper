`timescale 1ns / 1ps

module minesweeper#(parameter SCREEN_WIDTH=1024, parameter SCREEN_HEIGHT=768)
	(
	input clk_65mhz,		// 65MHz clock
	input reset,			// 1 to initialize module

	input center_in,		// unused?
	input up_in,			// unused?
	input down_in,			// unused?
	input left_in,			// unused?
	input right_in,			// unused?

	input [10:0] mouse_x,	// Mouse X coord.
	input [9:0] mouse_y,	// Mouse Y coord.
	input mouse_left_click,	// Mouse left button clicked. Debounced, but not edge triggered.
	input mouse_right_click,// Mouse right button clicked. Debounced, but not edge triggered.

	input [15:0] random,	// "Random" value. Updates every clock. Not very random at boot, but gets better

	input [10:0] hcount_in,	// horizontal index of current pixel (0..1023)
	input [9:0] vcount_in,	// vertical index of current pixel (0..767)
	input hsync_in,			// XVGA horizontal sync signal (active low)
	input vsync_in,			// XVGA vertical sync signal (active low)
	input blank_in,			// XVGA blanking (1 means output black pixel)

	output [10:0] hcount_out,	// horizontal index of current pixel, with buffering
	output [9:0] vcount_out,	// vertical index of current pixel, with buffering
	output hsync_out,			// horizontal sync (output with buffering)
	output vsync_out,			// vertical sync (output with buffering)
	output blank_out,			// blanking (output with buffering)
	output [11:0] pixel_out,	// pixel r=11:8, g=7:4, b=3:0 (output with buffering)

	output [31:0] seven_seg_out,	// seven segment display. Each nibble is 1 7 segment output

	output [2:0] sound_effect_select,	//indices and meanings TBD
	output sound_effect_start			//start the selected sound effect. Strobe for only 1 clock.

	);



	//TODO: replace with real logic
	assign hcount_out = hcount_in;
	assign vcount_out = vcount_in;
	assign hsync_out = hsync_in;
	assign vsync_out = vsync_in;
	assign blank_out = blank_in;
	assign pixel_out = pixel_in;
	assign seven_seg_out = 0;
	assign sound_effect_select = 0;
	assign sound_effect_start = 0;


endmodule
