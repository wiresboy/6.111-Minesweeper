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

	output [11:0] pixel_out,	// pixel r=11:8, g=7:4, b=3:0 

	output [31:0] seven_seg_out,	// seven segment display. Each nibble is 1 7 segment output

	output [2:0] sound_effect_select,	//indices and meanings TBD
	output sound_effect_start			//start the selected sound effect. Strobe for only 1 clock.

	);
	parameter GAME_SIZE = 3'd4;


	//TODO: replace with real logic
	assign seven_seg_out = 0;
	assign sound_effect_select = 0;
	assign sound_effect_start = 0;

	logic  [GAME_SIZE-1:0] bomb_locations  [0:GAME_SIZE-1]; // if 1, there is a bomb, if 0, no bomb
	logic [GAME_SIZE-1:0] tile_status  [0:GAME_SIZE-1]; //Game board for the tile status, if 0 tile has not been cleared, if 1 tile has been cleared succesfully

	logic[7:0] mouse_bin;
	logic[3:0] x_bin, y_bin;

	logic [2:0] state=3'b00;; //states for resetting game and choosing difficulty
	parameter IDLE = 3'b0;
	parameter IN_GAME = 3'b10;
	parameter GAME_OVER = 3'b011;

	assign bomb_locations = {4'b0010,4'b1000,4'b1111,4'b0000};

	//Every 65 MHz tick, draw pixel, every mouse click update tile_status
	logic [11:0] grid_pixel;


	always_ff @(posedge clk_65mhz) begin
		if(mouse_left_click) begin //process a user action
			//first "bin" which tile the click occured in
			x_bin <= mouse_x/256;
			y_bin <= mouse_y/192;
			mouse_bin <= {x_bin,y_bin};


			case(state)
				IDLE: begin
					//if (user clicks start game)
					state <= IN_GAME;
				end
				IN_GAME: begin
					if(mouse_x>=1000) begin//on reset button, reset game
						state <= IDLE;
					end
					//Do game logic!
					if(bomb_locations[mouse_bin[3:0]][mouse_bin[7:4]]) begin
						state <= GAME_OVER;
					end
				end
				GAME_OVER: begin
					//make sure screen shows that game is over
					//after some time transition to idle state?
					//state <= IDLE;
				end
			endcase
		end
		//Draw game board
		//First draw grid lines	starting with 4x4
		if((hcount_in%256==0)||(vcount_in%192==0)) begin
			grid_pixel <= 12'hFFF;
        end
			
		//pixel_out <= grid_pixel;
	end
endmodule


