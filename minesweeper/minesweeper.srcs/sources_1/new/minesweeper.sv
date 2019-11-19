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

	input [15:0] sw,

	output [11:0] pixel_out,	// pixel r=11:8, g=7:4, b=3:0 

	output [31:0] seven_seg_out,	// seven segment display. Each nibble is 1 7 segment output

	output [2:0] sound_effect_select,	//indices and meanings TBD
	output sound_effect_start			//start the selected sound effect. Strobe for only 1 clock.
	);
	parameter GAME_SIZE = 3'd4;
	parameter HORIZ_DIV = 1024/GAME_SIZE;
	parameter VERT_DIV = 768/GAME_SIZE;


	//TODO: replace with real logic
	assign seven_seg_out = 0;
	assign sound_effect_select = 0;
	assign sound_effect_start = 0;

	logic [0:GAME_SIZE-1] bomb_locations [0:GAME_SIZE-1]; // if 1, there is a bomb, if 0, no bomb
	logic [0:GAME_SIZE-1] tile_status [0:GAME_SIZE-1]; //if 0 tile has not been cleared, if 1 tile has been cleared succesfully
	//logic [GAME_SIZE-1:0] [2:0] tile_numbers[0:GAME_SIZE-1]; //3 bit representation of each tile's adjacent bombs game_sizexgame_size aray of 3-bit numbers 
	logic [0:GAME_SIZE-1] [2:0] tile_numbers[0:GAME_SIZE-1]; //3 bit representation of each tile's adjacent bombs game_sizexgame_size aray of 3-bit numbers 

	logic[7:0] mouse_bin;
	logic[3:0] x_bin, y_bin;

	parameter IDLE = 3'b000;
	parameter IN_GAME = 3'b010;
	parameter GAME_OVER = 3'b011;
	logic [2:0] state=IDLE;; //states for resetting game and choosing difficulty

	assign bomb_locations = {4'b0010,4'b1000,4'b1111,4'b0000};
	assign tile_numbers = '{'{2,1,0,7},'{0,1,6,3},'{7,1,0,1},'{5,2,1,0}};
	assign tile_status = {{4'hF},{4'hF},{4'hF},{4'hF}}; //set all tiles to be cleared for checking viz

	//Every 65 MHz tick, draw pixel, every mouse click update tile_status
	logic [11:0] grid_pixel;
	logic [11:0] tile_pixel,tile_pixel_2;
	


	always_ff @(posedge clk_65mhz) begin
		//Draw game board

		if(mouse_left_click) begin //process a user action
			//first "bin" which tile the click occured in
			x_bin <= mouse_x/192;
			y_bin <= mouse_y/192;
			mouse_bin <= {x_bin,y_bin};

			case(state)
				IDLE: begin
					//if (user clicks start game)
					state <= IN_GAME;
					//tile_status <= {{4'hF},{4'hF},{4'hF},{4'hF}}; //set all tiles to be cleared for checking viz
					//tile_status <= {{4'b0},{4'b0},{4'b0},{4'b0}}; //set all tiles to not be cleared
				end
				
				IN_GAME: begin
					if(mouse_x>=1000) begin//on reset button, reset game
						state <= IDLE;
					end

					//Do game logic!
					tile_status[mouse_bin[3:0]][mouse_bin[7:4]] <= 1'b1; //Update tile with mouse location
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
	end

	//one_blob one(.pixel_clk_in(clk_65mhz),.hcount_in(hcount_in),.vcount_in(vcount_in),.pixel_out(tile_pixel),.x_in(0),.y_in(0));
	//fd_blob fd(.pixel_clk_in(clk_65mhz),.hcount_in(hcount_in),.vcount_in(vcount_in),.pixel_out(tile_pixel_2),.x_in(192),.y_in(0));


    //assign pixel_out = tile_pixel|tile_pixel_2;
	tile_drawer td(.pixel_clk_in(clk_65mhz),.hcount_in(hcount_in),.vcount_in(vcount_in),.tile_numbers(tile_numbers),.tile_status(tile_status),
		.sw(sw),.pixel_out(pixel_out));
endmodule

module tile_drawer
	#(parameter WIDTH = 192, HEIGHT = 192)
	(input pixel_clk_in,
    input [10:0] hcount_in,
    input [9:0] vcount_in,
	input [0:3] [2:0] tile_numbers[0:3],
	logic [0:3] tile_status [0:3],
	input [15:0] sw,
    output logic [11:0] pixel_out
	);
    
    logic [2:0] curr_tile; //0-6 are possible tile numbers, 7 is flag, temporary variable for indexing into tile_numbers array
	//ROM vars
	logic [15:0] image_addr;
	assign image_addr = (hcount_in-(hcount_in/192)*192) + (vcount_in-192*(vcount_in/192)) * WIDTH; //determine where top left corner of each pixel is for image_addr

	//ROM Instantiations
	
	//Facing Down tile ROMs
	logic [15:0] fd_pixel_out;
	logic [7:0] fd_image_bits, fd_red_mapped, fd_green_mapped, fd_blue_mapped;
	facing_down_image_rom  fd_img_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(fd_image_bits));
	facing_down_rcm fd_rcm (.clka(pixel_clk_in), .addra(fd_image_bits), .douta(fd_red_mapped));
	
	//Zero tile ROMs
	logic[15:0] zero_pixel_out;
	logic [7:0] zero_image_bits, zero_red_mapped, zero_green_mapped, zero_blue_mapped;
	zero_image_rom  zero_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(zero_image_bits));
	zero_rcm zero_rcm (.clka(pixel_clk_in), .addra(zero_image_bits), .douta(zero_red_mapped));
	zero_gcm zero_gcm (.clka(pixel_clk_in), .addra(zero_image_bits), .douta(zero_green_mapped));
	zero_bcm zero_bcm (.clka(pixel_clk_in), .addra(zero_image_bits), .douta(zero_blue_mapped));

	//One tile ROMs
	logic[15:0] one_pixel_out;
	logic [7:0] one_image_bits, one_red_mapped, one_green_mapped, one_blue_mapped;
	one_image_rom  one_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(one_image_bits));
	one_rcm one_rcm (.clka(pixel_clk_in), .addra(one_image_bits), .douta(one_red_mapped));
	one_gcm one_gcm (.clka(pixel_clk_in), .addra(one_image_bits), .douta(one_green_mapped));
	one_bcm one_bcm (.clka(pixel_clk_in), .addra(one_image_bits), .douta(one_blue_mapped));
	

	//Given the tile_numbers and tile_status array, draws the tiles
	
    always_ff @(posedge pixel_clk_in) begin
		if(hcount_in<=768) begin //only draw in the game tile region
			if(!tile_status[vcount_in/192][hcount_in/192]) begin//if tile has not been cleared, draw uncleared tile symbol
				pixel_out <= {fd_red_mapped[7:4], fd_red_mapped[7:4], fd_red_mapped[7:4]}; // greyscale
				//pixel_out <= 12'hEEE;
			end else begin //if tile has been cleared, draw the number of surrounding bombs
				curr_tile <= tile_numbers[vcount_in/192][hcount_in/192];
				//curr_tile <= sw[2:0];
				case(curr_tile)
					0: begin
						pixel_out <= {zero_red_mapped[7:4], zero_green_mapped[7:4], zero_blue_mapped[7:4]}; 
						//pixel_out <= 12'h000; //Sim test
					end
					1: begin
						pixel_out <= {one_red_mapped[7:4], one_green_mapped[7:4], one_blue_mapped[7:4]}; 
						//pixel_out <= 12'h111; //sim test
					end
					/*
					2: begin
						pixel_out <= {two_red_mapped[7:4], two_green_mapped[7:4], two_blue_mapped[7:4]}; 
						//pixel_out <= 12'h222; //sim test
					end
					3: begin
						pixel_out <= {three_red_mapped[7:4], three_green_mapped[7:4], three_blue_mapped[7:4]}; 
						//pixel_out <= 12'h333; //sim test
					end
					*/
					default: begin
						pixel_out <= {fd_red_mapped[7:4], fd_red_mapped[7:4], fd_red_mapped[7:4]};  //greyscale
						//pixel_out <= {fd_red_mapped[7:4], fd_green_mapped[7:4], fd_blue_mapped[7:4]}; 
						//pixel_out <= 12'h000; //sim test
					end
				endcase
			end
		end else begin
			pixel_out <= 12'h000;
		end
	end
endmodule //tile_drawer


/*
module fd_blob 
   #(parameter WIDTH = 192,     // default picture width
               HEIGHT = 192)    // default picture height
   (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    output logic [11:0] pixel_out);

   logic [15:0] image_addr;   // num of bits for 256*240 ROM
   logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

   // calculate rom address and read the location
   assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
   facing_down_image_rom  rom(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   // use color map to create 4 bits R, 4 bits G, 4 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   facing_down_color_map rcm (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
   //green_coe gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
   //blue_coe bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
          (vcount_in >= y_in && vcount_in < (y_in+HEIGHT)))
        // use MSB 4 bits
        pixel_out <= {red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
        //pixel_out <= {red_mapped[7:4], 8h'0}; // only red hues
        else pixel_out <= 0;
   end
endmodule

module one_blob 
   #(parameter WIDTH = 192,     // default picture width
               HEIGHT = 192)    // default picture height
   (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    output logic [11:0] pixel_out);

   logic [15:0] image_addr;   // num of bits for 256*240 ROM
   logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

   // calculate rom address and read the location
   assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
   one_image_rom  rom(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

   // use color map to create 4 bits R, 4 bits G, 4 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   one_color_map rcm (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
   green_coe gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
   blue_coe bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk_in) begin
     if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
          (vcount_in >= y_in && vcount_in < (y_in+HEIGHT)))
        // use MSB 4 bits
        pixel_out <= {red_mapped[7:4], green_mapped[7:4], blue_mapped[7:4]}; // greyscale
        //pixel_out <= {red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
        //pixel_out <= {red_mapped[7:4], 8h'0}; // only red hues
        else pixel_out <= 0;
   end
endmodule
*/
