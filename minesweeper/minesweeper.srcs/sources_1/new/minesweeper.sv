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
	assign tile_numbers = '{'{2,1,0,4},'{0,1,6,3},'{5,1,0,1},'{5,2,1,0}};
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
	#(parameter WIDTH = 48, HEIGHT = 48)
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
	assign image_addr = (hcount_in-(hcount_in/WIDTH)*WIDTH) + (vcount_in-HEIGHT*(vcount_in/HEIGHT)) * WIDTH; //determine where top left corner of each pixel is for image_addr 
	//ROM Instantiations
	
	//Facing Down tile ROMs
	logic [15:0] fd_pixel_out;
	logic [7:0] fd_image_bits, fd_red_mapped, fd_green_mapped, fd_blue_mapped;
	facing_down_image_rom  fd_img_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(fd_image_bits));
	facing_down_rcm fd_rcm (.clka(pixel_clk_in), .addra(fd_image_bits), .douta(fd_red_mapped));
	facing_down_gcm fd_gcm (.clka(pixel_clk_in), .addra(fd_image_bits), .douta(fd_green_mapped));
	facing_down_bcm fd_bcm (.clka(pixel_clk_in), .addra(fd_image_bits), .douta(fd_blue_mapped));
	
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
	
	//Two tile ROMs
	logic[15:0] two_pixel_out;
	logic [7:0] two_image_bits, two_red_mapped, two_green_mapped, two_blue_mapped;
	two_image_rom  two_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(two_image_bits));
	two_rcm two_rcm (.clka(pixel_clk_in), .addra(two_image_bits), .douta(two_red_mapped));
	two_gcm two_gcm (.clka(pixel_clk_in), .addra(two_image_bits), .douta(two_green_mapped));
	two_bcm two_bcm (.clka(pixel_clk_in), .addra(two_image_bits), .douta(two_blue_mapped));
	
	//Three tile ROMs
	logic[15:0] three_pixel_out;
	logic [7:0] three_image_bits, three_red_mapped, three_green_mapped, three_blue_mapped;
	three_image_rom  three_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(three_image_bits));
	three_rcm three_rcm (.clka(pixel_clk_in), .addra(three_image_bits), .douta(three_red_mapped));
	three_gcm three_gcm (.clka(pixel_clk_in), .addra(three_image_bits), .douta(three_green_mapped));
	three_bcm three_bcm (.clka(pixel_clk_in), .addra(three_image_bits), .douta(three_blue_mapped));
	
	//Four tile ROMs
	logic[15:0] four_pixel_out;
	logic [7:0] four_image_bits, four_red_mapped, four_green_mapped, four_blue_mapped;
	four_image_rom  four_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(four_image_bits));
	four_rcm four_rcm (.clka(pixel_clk_in), .addra(four_image_bits), .douta(four_red_mapped));
	four_gcm four_gcm (.clka(pixel_clk_in), .addra(four_image_bits), .douta(four_green_mapped));
	four_bcm four_bcm (.clka(pixel_clk_in), .addra(four_image_bits), .douta(four_blue_mapped));
	
	//Five tile ROMs
	logic[15:0] five_pixel_out;
	logic [7:0] five_image_bits, five_red_mapped, five_green_mapped, five_blue_mapped;
	five_image_rom  five_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(five_image_bits));
	five_rcm five_rcm (.clka(pixel_clk_in), .addra(five_image_bits), .douta(five_red_mapped));
	five_gcm five_gcm (.clka(pixel_clk_in), .addra(five_image_bits), .douta(five_green_mapped));
	five_bcm five_bcm (.clka(pixel_clk_in), .addra(five_image_bits), .douta(five_blue_mapped));
	
	//Six tile ROMs
	logic[15:0] six_pixel_out;
	logic [7:0] six_image_bits, six_red_mapped, six_green_mapped, six_blue_mapped;
	six_image_rom  six_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(six_image_bits));
	six_rcm six_rcm (.clka(pixel_clk_in), .addra(six_image_bits), .douta(six_red_mapped));
	six_gcm six_gcm (.clka(pixel_clk_in), .addra(six_image_bits), .douta(six_green_mapped));
	six_bcm six_bcm (.clka(pixel_clk_in), .addra(six_image_bits), .douta(six_blue_mapped));
	
	//flag tile ROMs
	logic[15:0] flag_pixel_out;
	logic [7:0] flag_image_bits, flag_red_mapped, flag_green_mapped, flag_blue_mapped;
	flag_image_rom  flag_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(flag_image_bits));
	flag_rcm flag_rcm (.clka(pixel_clk_in), .addra(flag_image_bits), .douta(flag_red_mapped));
	flag_gcm flag_gcm (.clka(pixel_clk_in), .addra(flag_image_bits), .douta(flag_green_mapped));
	flag_bcm flag_bcm (.clka(pixel_clk_in), .addra(flag_image_bits), .douta(flag_blue_mapped));
	
	//Bomb tile ROMs
	logic[15:0] bomb_pixel_out;
	logic [7:0] bomb_image_bits, bomb_red_mapped, bomb_green_mapped, bomb_blue_mapped;
	bomb_image_rom  bomb_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(bomb_image_bits));
	bomb_rcm bomb_rcm (.clka(pixel_clk_in), .addra(bomb_image_bits), .douta(bomb_red_mapped));
	bomb_gcm bomb_gcm (.clka(pixel_clk_in), .addra(bomb_image_bits), .douta(bomb_green_mapped));
	bomb_bcm bomb_bcm (.clka(pixel_clk_in), .addra(bomb_image_bits), .douta(bomb_blue_mapped));
	

	//Given the tile_numbers and tile_status array, draws the tiles
	
    always_ff @(posedge pixel_clk_in) begin
		if(hcount_in<=192&&vcount_in<=192) begin //only draw in the game tile region
			if(!tile_status[vcount_in/HEIGHT][hcount_in/WIDTH]) begin//if tile has not been cleared, draw uncleared tile symbol
				pixel_out <= {fd_red_mapped[7:4], fd_red_mapped[7:4], fd_red_mapped[7:4]}; // greyscale
			end else begin //if tile has been cleared, draw the number of surrounding bombs
				curr_tile <= tile_numbers[vcount_in/HEIGHT][hcount_in/WIDTH]; //curr_tile <= sw[2:0];
				case(curr_tile)
					0: begin
						pixel_out <= {zero_red_mapped[7:4], zero_green_mapped[7:4], zero_blue_mapped[7:4]}; 
					end
					1: begin
						pixel_out <= {one_red_mapped[7:4], one_green_mapped[7:4], one_blue_mapped[7:4]}; 
					end
					2: begin
						pixel_out <= {two_red_mapped[7:4], two_green_mapped[7:4], two_blue_mapped[7:4]}; 
					end
					3: begin
						pixel_out <= {three_red_mapped[7:4], three_green_mapped[7:4], three_blue_mapped[7:4]}; 
					end
					4: begin
						pixel_out <= {four_red_mapped[7:4], four_green_mapped[7:4], four_blue_mapped[7:4]}; 
					end
					5: begin
						pixel_out <= {five_red_mapped[7:4], five_green_mapped[7:4], five_blue_mapped[7:4]}; 
					end
					6: begin
						pixel_out <= {six_red_mapped[7:4], six_green_mapped[7:4], six_blue_mapped[7:4]}; 
					end
					7: begin
						pixel_out <= {flag_red_mapped[7:4], flag_green_mapped[7:4], flag_blue_mapped[7:4]}; 
					end
					default: begin
						pixel_out <= {fd_red_mapped[7:4], fd_green_mapped[7:4], fd_blue_mapped[7:4]}; 
					end
				endcase
			end
		end else begin
			pixel_out <= 12'h000;
		end
	end
endmodule //tile_drawer
