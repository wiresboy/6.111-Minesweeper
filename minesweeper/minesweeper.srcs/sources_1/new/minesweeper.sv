`timescale 1ns / 1ps

module minesweeper(
	input clk_65mhz,		// 65MHz clock
	input reset,			// 1 to initialize module

	input [11:0] mouse_x,	// Mouse X coord.
	input [11:0] mouse_y,	// Mouse Y coord.
	input mouse_left_click,	// Mouse left button clicked. Debounced, but not edge triggered.
	input mouse_right_click,// Mouse right button clicked. Debounced, but not edge triggered.

	input [15:0] random,	// "Random" value. Updates every clock. Not very random at boot, but gets better

	input [10:0] hcount_in,	// horizontal index of current pixel (0..1023)
	input [9:0] vcount_in,	// vertical index of current pixel (0..767)
	input hsync_in,			// XVGA horizontal sync signal (active low)
	input vsync_in,			// XVGA vertical sync signal (active low)
	input blank_in,			// XVGA blanking (1 means output black pixel)


	output [10:0] hcount_out,    // buffered hindex
	output [9:0] vcount_out,     // buffered vindex
	output hsync_out,	     //buff hsync
	output vsync_out,		 //buff vsync 
	output blank_out,		 // buff blank

	input [15:0] sw,

	input [15:0] count_out,       // low frequency counter

	output logic start_timer,stop_timer,

	output [11:0] pixel_out,	// pixel r=11:8, g=7:4, b=3:0 

	output [31:0] seven_seg_out,	// seven segment display. Each nibble is 1 7 segment output

	output logic [5:0] sound_effect_select,	//indices and meanings 001 = bomb, 011 = flag

	output logic gg_pulse // One cycle pulse for leaderboard
	);

	parameter GAME_SIZE = 4'd15; 
	logic [6:0] BOMBS = 7'd25; //Number of bombs in the game board
	logic [6:0] temp_bomb_counter = 0; //variable for setting up random game array

	logic [0:GAME_SIZE-1] bomb_locations [0:GAME_SIZE-1]='{'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}; // if 1, there is a bomb, if 0, no bomb
	logic [0:GAME_SIZE-1] [1:0] tile_status [0:GAME_SIZE-1]='{'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}; //if 0 tile has not been cleared, if 1 tile has been cleared succesfully, 2'b11 if flagged
	logic [0:GAME_SIZE-1] [3:0] tile_numbers[0:GAME_SIZE-1]= '{'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}; //4 bit representation of each tile's adjacent bombs game_sizexgame_size aray of 4-bit numbers 

	logic [6:0] flag_counter=BOMBS; //counts how many flags have been placed
	logic [7:0] tile_cleared_count = 0; //Game is over when tile_cleared_count == num_tiles-bombs

	logic[15:0] dec_clk_data,dec_flag_data;
	hex_2_dec h2d_clk(.hex_in(count_out),.dec_out(dec_clk_data));
	hex_2_dec h2d_flag(.hex_in(flag_counter),.dec_out(dec_flag_data));

	logic [31:0] seven_seg_data;
	assign seven_seg_out = seven_seg_data;

	logic[3:0] x_bin, y_bin;
	logic[3:0] x_temp=0, y_temp=0; //temporary indexing vars for initializing the bomb counter array

	logic [3:0] local_bombs=0;

	assign x_bin = mouse_x/48;
	assign y_bin = mouse_y/48;

	parameter IDLE = 4'b000;
	parameter IN_GAME = 4'b010;
	parameter GAME_OVER = 4'b011;
	parameter GG = 4'b111;
	parameter PLACE_BOMBS = 4'b110;
	parameter TILES = 4'b101;
	parameter CLEAR = 4'b100;
	parameter CHECK_FIFO = 4'hF;

	logic [3:0] state=IDLE;; //states for resetting game and choosing difficulty
	
	//VGA Buffer vars
	logic vsync[5:0], hsync[5:0], blank [5:0];
	logic [10:0] hcount[5:0];
	logic [9:0] vcount[5:0]; 
	//buffering
	assign hcount_out = hcount[0];
	assign vcount_out = vcount[0];
	assign hsync_out = hsync[0];    //Buffer VGA timing signals by one clock cycle
	assign vsync_out = vsync[0];
	assign blank_out = blank[0];

	logic [7:0] fifo_tile_in ,fifo_tile_out;
	logic [3:0] fifo_y,fifo_x;
	logic [3:0] fifo_ind=0;
	logic fifo_empty,fifo_wr=0,fifo_rd=0,fifo_reset=0;
	clear_fifo clear_fifo(.clk(clk_65mhz),.srst(reset||fifo_reset),.din(fifo_tile_in),.dout(fifo_tile_out),.empty(fifo_empty),.wr_en(fifo_wr),.rd_en(fifo_rd));

	//rising mouse edge detect vars
	logic mouse_left_edge, mouse_right_edge, left_old_clean, right_old_clean; //edge triggered mouse inputs 
	

    always_ff @(posedge clk_65mhz)begin
		if(state == IN_GAME) begin
			seven_seg_data <= {dec_flag_data,dec_clk_data}; 
		end else if(state == GG) begin
			seven_seg_data <= {16'd1111,dec_clk_data};
		end else if(state == GAME_OVER) begin
			seven_seg_data <= {16'h0000,dec_clk_data};
		end
		//rising edge detector
        if (reset)begin
            left_old_clean <= 1'b0;
            right_old_clean <= 1'b0;
        end else begin
            left_old_clean <= mouse_left_click;
            right_old_clean <= mouse_right_click;
			mouse_left_edge <= mouse_left_click & !left_old_clean;
			mouse_right_edge <= mouse_right_click & !right_old_clean;
        end

		//Buffer VGA timing signals for tile_drawer module
		vsync[5] <= vsync_in;
		hsync[5] <= hsync_in;
		blank[5] <= blank_in;
		hcount[5] <= hcount_in;
		vcount[5] <= vcount_in;

		vsync[4] <= vsync[5];
		hsync[4] <= hsync[5];
		blank[4] <= blank[5];
		hcount[4] <= hcount[5];
		vcount[4] <= vcount[5];

		vsync[3] <= vsync[4];
		hsync[3] <= hsync[4];
		blank[3] <= blank[4];
		hcount[3] <= hcount[4];
		vcount[3] <= vcount[4];

		vsync[2] <= vsync[3];
		hsync[2] <= hsync[3];
		blank[2] <= blank[3];
		hcount[2] <= hcount[3];
		vcount[2] <= vcount[3];

		vsync[1] <= vsync[2];
		hsync[1] <= hsync[2];
		blank[1] <= blank[2];
		hcount[1] <= hcount[2];
		vcount[1] <= vcount[2];

		vsync[0] <= vsync[1];
		hsync[0] <= hsync[1];
		blank[0] <= blank[1];
		hcount[0] <= hcount[1];
		vcount[0] <= vcount[1];

		//Draw game board
		if(reset) begin
			state <= IDLE;
		end
		if(stop_timer) stop_timer <= 1'b0; //make stop_timer a single cycle pulse

		if(sound_effect_select[1]) sound_effect_select[1] <= 0;
		if(sound_effect_select[3]) sound_effect_select[3] <= 0;
		if(sound_effect_select[2]) sound_effect_select[2] <= 0;
		if(sound_effect_select[5]) sound_effect_select[5] <= 0;
		if(gg_pulse) gg_pulse <= 0;
		if(fifo_reset) fifo_reset <= 0;

		if(state == GAME_OVER||state == GG) begin
				tile_status <= '{'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
					'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
					'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
					'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
					'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},'{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01}}; //show all tile numbers and bombs
		end

		if(state == PLACE_BOMBS) begin
			if(random> 50000 && bomb_locations[y_temp][x_temp] != 1 && y_temp!= y_bin && x_temp!= x_bin && (y_temp!=y_bin-1 && x_temp!=x_bin-1) && (y_temp!=y_bin-1 && x_temp!=x_bin)&&(y_temp!=y_bin-1 && x_temp!=x_bin+1)
				&&(y_temp!=y_bin && x_temp!=x_bin-1)&&(y_temp!=y_bin && x_temp!=x_bin+1)&&(y_temp!=y_bin+1 && x_temp!=x_bin-1)&&(y_temp!=y_bin+1 && x_temp!=x_bin)&&(y_temp!=y_bin+1 && x_temp!=x_bin+1)) begin //no bombs placed in immedate area surrounding first click
				bomb_locations[y_temp][x_temp] <= 1;
				temp_bomb_counter <= temp_bomb_counter +1;
			end
			x_temp = x_temp+1;
			if(x_temp == 15) begin 
				x_temp <= 0;
				y_temp <= y_temp+1;
			end
			if(y_temp == 15) begin 
				y_temp <= 0;
				x_temp <= 0;
			end
			if(temp_bomb_counter == BOMBS) begin
				temp_bomb_counter <= 0;
				state <= TILES;
				x_temp <= 0;
				y_temp <= 0;
			end
		end
		if(state == TILES) begin // calculate tile_numbers
			if (bomb_locations[y_temp][x_temp]) begin
				tile_numbers[y_temp][x_temp] <= 4'hF; //mark tile as a bomb tile
			end else begin
				if(y_temp>0 && x_temp >0 && x_temp<14 && y_temp<14) begin //if tile is not on edge of board
					local_bombs = bomb_locations[y_temp-1][x_temp-1]+bomb_locations[y_temp-1][x_temp]+bomb_locations[y_temp-1][x_temp+1]
						+ bomb_locations[y_temp][x_temp-1] +  bomb_locations[y_temp][x_temp+1]+ bomb_locations[y_temp+1][x_temp-1]
						+ bomb_locations[y_temp+1][x_temp] + bomb_locations[y_temp+1][x_temp+1];
				end else if(x_temp == 0 && y_temp ==0) begin //deal w/ four corners
					local_bombs = bomb_locations[y_temp][x_temp+1]+ bomb_locations[y_temp+1][x_temp] + bomb_locations[y_temp+1][x_temp+1];
				end else if(x_temp == 14 && y_temp == 0) begin
					local_bombs = bomb_locations[y_temp][x_temp-1] + bomb_locations[y_temp+1][x_temp-1] + bomb_locations[y_temp+1][x_temp];
				end else if(x_temp == 0 && y_temp == 14) begin
					local_bombs = bomb_locations[y_temp-1][x_temp]+bomb_locations[y_temp-1][x_temp+1]+bomb_locations[y_temp][x_temp+1];
				end else if(x_temp == 14 && y_temp == 14) begin 
					local_bombs = bomb_locations[y_temp-1][x_temp-1]+bomb_locations[y_temp-1][x_temp] + bomb_locations[y_temp][x_temp-1];
				end else if(x_temp==0) begin //if tile is on left rim
					local_bombs = bomb_locations[y_temp-1][x_temp]+bomb_locations[y_temp-1][x_temp+1]
						 +  bomb_locations[y_temp][x_temp+1]
						+ bomb_locations[y_temp+1][x_temp] + bomb_locations[y_temp+1][x_temp+1];
				end else if(y_temp ==0) begin // if tile is on top rim
					local_bombs = bomb_locations[y_temp][x_temp-1] +  bomb_locations[y_temp][x_temp+1]+ bomb_locations[y_temp+1][x_temp-1]
						+ bomb_locations[y_temp+1][x_temp] + bomb_locations[y_temp+1][x_temp+1];
				end else if(y_temp == 14) begin //if tile is on bottom rim
					local_bombs = bomb_locations[y_temp-1][x_temp-1]+bomb_locations[y_temp-1][x_temp]+bomb_locations[y_temp-1][x_temp+1]
						+ bomb_locations[y_temp][x_temp-1] +  bomb_locations[y_temp][x_temp+1];
				end else begin //tile must be on right rim
					local_bombs = bomb_locations[y_temp-1][x_temp-1]+bomb_locations[y_temp-1][x_temp]
						+ bomb_locations[y_temp][x_temp-1] + bomb_locations[y_temp+1][x_temp-1]
						+ bomb_locations[y_temp+1][x_temp];
				end
				tile_numbers[y_temp][x_temp] <= local_bombs;
			end
			x_temp = x_temp+1;
			if(y_temp == 15 && x_temp == 15) begin
				x_temp <= 0;
				y_temp <= 0;
				state <= IN_GAME;
				start_timer <= 1; //Start the 1 Hz counter
				if(sw[15]) begin
					sound_effect_select[4] <= 1;
					sound_effect_select[0] <= 0;
				end else begin
					sound_effect_select[0] <= 1;
					sound_effect_select[4] <= 0;
				end
			end
			if(x_temp == 15) begin 
				x_temp <= 0;
				y_temp <= y_temp+1;
			end
		end
		if(state == IDLE) begin
			x_temp <= 0;
			tile_status <='{'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}};
			tile_numbers[0:GAME_SIZE-1]<= '{'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
					'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}; 
			bomb_locations <='{'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
				'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}; 
			tile_cleared_count <= 0;
			temp_bomb_counter <= 0;
			fifo_reset <= 1;
		end

		if(state == CLEAR) begin //clearing adjacent tiles
			if (fifo_ind[0] == sw[15]||sw[13]) begin
			fifo_ind <= fifo_ind + 1;
			case (fifo_ind) 
				0: begin
					if(fifo_y>0 && fifo_x > 0) begin
						if(tile_status[fifo_y-1][fifo_x-1] != 1) begin
							tile_status[fifo_y-1][fifo_x-1] <= 1;
							tile_cleared_count <= tile_cleared_count+1;
							if(tile_numbers[fifo_y-1][fifo_x-1] == 0) begin // if top left tile is also a 0-tile
								fifo_wr <= 1;
								fifo_tile_in[7:4] <= fifo_y-1;
								fifo_tile_in[3:0] <= fifo_x-1;
								//fifo_tile_in <= {fifo_y-1,fifo_x-1};
							end else begin
								fifo_wr <= 0;
							end
						end
					end
				end
				1: begin
					if(fifo_y>0) begin
						if(tile_status[fifo_y-1][fifo_x] != 1) begin
							tile_status[fifo_y-1][fifo_x] <= 1;
							tile_cleared_count <= tile_cleared_count+1;
							if(tile_numbers[fifo_y-1][fifo_x] == 0) begin // if top left tile is also a 0-tile
								fifo_wr <= 1;
								fifo_tile_in[7:4] <= fifo_y-1;
								fifo_tile_in[3:0] <= fifo_x;
								//fifo_tile_in <= {fifo_y-1,fifo_x};
							end else begin
								fifo_wr <= 0;
							end
						end
					end
				end
				2: begin
					if(fifo_y>0 && fifo_x<14) begin
						if(tile_status[fifo_y-1][fifo_x+1] != 1) begin
							tile_status[fifo_y-1][fifo_x+1] <= 1;
							tile_cleared_count <= tile_cleared_count+1;
							if(tile_numbers[fifo_y-1][fifo_x+1] == 0) begin // if top left tile is also a 0-tile
								fifo_wr <= 1;
								fifo_tile_in[7:4] <= fifo_y-1;
								fifo_tile_in[3:0] <= fifo_x+1;
								//fifo_tile_in <= {fifo_y-1,fifo_x+1};
							end else begin
								fifo_wr <= 0;
							end
						end
					end
				end
				3: begin
					if(fifo_x>0) begin
						if(tile_status[fifo_y][fifo_x-1] != 1) begin
							tile_status[fifo_y][fifo_x-1] <= 1;
							tile_cleared_count <= tile_cleared_count+1;
							if(tile_numbers[fifo_y][fifo_x-1] == 0) begin // if top left tile is also a 0-tile
								fifo_wr <= 1;
								fifo_tile_in[7:4] <= fifo_y;
								fifo_tile_in[3:0] <= fifo_x-1;
								//fifo_tile_in <= {fifo_y,fifo_x-1};
							end else begin
								fifo_wr <= 0;
							end
						end
					end
				end
				4: begin
					if(fifo_x<14) begin
						if(tile_status[fifo_y][fifo_x+1] != 1) begin
							tile_status[fifo_y][fifo_x+1] <= 1;
							tile_cleared_count <= tile_cleared_count+1;
							if(tile_numbers[fifo_y][fifo_x+1] == 0) begin // if top left tile is also a 0-tile
								fifo_wr <= 1;
								fifo_tile_in[7:4] <= fifo_y;
								fifo_tile_in[3:0] <= fifo_x+1;
								//fifo_tile_in <= {fifo_y,fifo_x+1};
							end else begin
								fifo_wr <= 0;
							end
						end
					end
				end
				5: begin
					if(fifo_y<14&&fifo_x>0) begin
						if(tile_status[fifo_y+1][fifo_x-1] != 1) begin
							tile_status[fifo_y+1][fifo_x-1] <= 1;
							tile_cleared_count <= tile_cleared_count-1;
							if(tile_numbers[fifo_y+1][fifo_x-1] == 0) begin // if top left tile is also a 0-tile
								fifo_wr <= 1;
								fifo_tile_in[7:4] <= fifo_y+1;
								fifo_tile_in[3:0] <= fifo_x-1;
								//fifo_tile_in <= {fifo_y+1,fifo_x-1};
							end else begin
								fifo_wr <= 0;
							end
						end
					end
				end
				6: begin
					if(fifo_y<14) begin
						if(tile_status[fifo_y+1][fifo_x] != 1) begin
							tile_status[fifo_y+1][fifo_x] <= 1;
							tile_cleared_count <= tile_cleared_count-1;
							if(tile_numbers[fifo_y+1][fifo_x] == 0) begin // if top left tile is also a 0-tile
								fifo_wr <= 1;
								fifo_tile_in[7:4] <= fifo_y+1;
								fifo_tile_in[3:0] <= fifo_x;
								//fifo_tile_in <= {fifo_y+1,fifo_x};
							end else begin
								fifo_wr <= 0;
							end
						end
					end
				end
				7: begin
					if(fifo_x<14 && fifo_y<14) begin
						if(tile_status[fifo_y+1][fifo_x+1] != 1) begin
							tile_status[fifo_y+1][fifo_x+1] <= 1;
							tile_cleared_count <= tile_cleared_count-1;
							if(tile_numbers[fifo_y+1][fifo_x+1] == 0) begin // if top left tile is also a 0-tile
								fifo_wr <= 1;
								fifo_tile_in[7:4] <= fifo_y+1;
								fifo_tile_in[3:0] <= fifo_x+1;
								//fifo_tile_in <= {fifo_y+1,fifo_x+1};
							end else begin
								fifo_wr <= 0;
							end
						end
					end
				end
			endcase
			if(fifo_ind == 8) begin
				state <= CHECK_FIFO;
				fifo_rd <= 1;
				fifo_wr <= 0;
			end
			end
		end

		if(state == CHECK_FIFO) begin
			fifo_rd <= 0;
			fifo_x <= fifo_tile_out[3:0];
			fifo_y <= fifo_tile_out[7:4];
			if(fifo_empty)
				state <= IN_GAME;
			else begin
				state <= CLEAR;
				fifo_ind <= 0;
			end
		end

		if(state == IN_GAME) begin
			if(tile_cleared_count == 225-BOMBS) begin
				stop_timer <= 1'b1;
				state <= GG;
				sound_effect_select[2] <= 1;
				gg_pulse <= 1;
			end
		end

		if(mouse_left_edge||mouse_right_edge) begin //process a user action
			if(mouse_left_edge && mouse_x>900) begin
				state <= IDLE;
			end
			case(state)
				IDLE: begin
					case(sw[1:0])
						2'b00: BOMBS = 20;
						2'b01: BOMBS = 25;
						2'b10: BOMBS = 35;
						2'b11: BOMBS = 45;
					endcase
					flag_counter <= BOMBS;
					state <= PLACE_BOMBS;
				end
				IN_GAME: begin
					start_timer <= 0;
					if(mouse_left_edge && x_bin>=0 && x_bin <= 14 && y_bin>=0 && y_bin<=14) begin
						if(tile_status[y_bin][x_bin]!=2'b11) begin //if user left clicks on a non-flag tile
							if(bomb_locations[y_bin][x_bin]) begin //if tile is not a flag and there's a bomb, end the game
								state <= GAME_OVER;
								sound_effect_select[1] <= 1;
								stop_timer <= 1'b1;
							end
							tile_status[y_bin][x_bin] <= 2'b1; //Update tile with mouse location
							tile_cleared_count <= tile_cleared_count+1;
							if(tile_numbers[y_bin][x_bin] == 0 && tile_status[y_bin][x_bin]!=2'b11) begin//if clicked on a tile with no adjacent bombs, need to clear all adjacent tiles 
								state <= CLEAR;
								fifo_y <= y_bin;
								fifo_x <= x_bin;
								fifo_ind <= 0;
							end
						end
					end else begin //process user right click
						if(x_bin>=0 && x_bin <= 14 && y_bin>=0 && y_bin<=14) begin
							if(tile_status[y_bin][x_bin] == 2'b00) begin
								sound_effect_select[3] <= 1;
								tile_status[y_bin][x_bin] <= 2'b11; //Update tile with flag
								flag_counter <= flag_counter-1;
							end else if(tile_status[y_bin][x_bin] == 2'b11) begin
								sound_effect_select[5] <= 1;
								tile_status[y_bin][x_bin] <= 2'b00; //Turn flag into empty tile
								flag_counter <= flag_counter+1;
							end
						end
					end
				end
			endcase
		end
	end

	tile_drawer td(.pixel_clk_in(clk_65mhz),.hcount_in(hcount_in),.vcount_in(vcount_in),.tile_numbers(tile_numbers),.tile_status(tile_status),.pixel_out(pixel_out),.vcount_out(vcount_out),.hcount_out(hcount_out));
endmodule

module tile_drawer
	#(parameter WIDTH = 48, HEIGHT = 48,GAME_SIZE = 15)
	(input pixel_clk_in,
    input [10:0] hcount_in,hcount_out,
    input [9:0] vcount_in,vcount_out,
	input [0:GAME_SIZE-1] [3:0] tile_numbers[0:GAME_SIZE-1],
	logic [0:GAME_SIZE-1] [1:0] tile_status [0:GAME_SIZE-1],
    output logic [11:0] pixel_out
	);
    
    logic [3:0] curr_tile; //0-8 are possible tile numbers, F is a bomb temporary variable for indexing into tile_numbers array
	//ROM vars
	logic [15:0] image_addr;
	logic [10:0] hcount_temp[1:0];
	logic [9:0] vcount_temp[1:0];
	assign image_addr = (hcount_in-hcount_temp[0]) + (vcount_in-vcount_temp[0]) * WIDTH; //determine where top left corner of each pixel is for image_addr 
	//assign image_addr = (hcount_in-(hcount_in/WIDTH)*WIDTH) + (vcount_in-HEIGHT*(vcount_in/HEIGHT)) * WIDTH; //determine where top left corner of each pixel is for image_addr 
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
	
	//Seven tile ROMs
	
	logic[15:0] seven_pixel_out;
	logic [7:0] seven_image_bits, seven_red_mapped, seven_green_mapped, seven_blue_mapped;
	seven_image_rom  seven_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(seven_image_bits));
	seven_rcm seven_rcm (.clka(pixel_clk_in), .addra(seven_image_bits), .douta(seven_red_mapped));
	seven_gcm seven_gcm (.clka(pixel_clk_in), .addra(seven_image_bits), .douta(seven_green_mapped));
	seven_bcm seven_bcm (.clka(pixel_clk_in), .addra(seven_image_bits), .douta(seven_blue_mapped));
	
	//Eight tile ROMs
	
	logic[15:0] eight_pixel_out;
	logic [7:0] eight_image_bits, eight_red_mapped, eight_green_mapped, eight_blue_mapped;
	eight_image_rom  eight_rom(.clka(pixel_clk_in), .addra(image_addr), .douta(eight_image_bits));
	eight_rcm eight_rcm (.clka(pixel_clk_in), .addra(eight_image_bits), .douta(eight_red_mapped));
	eight_gcm eight_gcm (.clka(pixel_clk_in), .addra(eight_image_bits), .douta(eight_green_mapped));
	eight_bcm eight_bcm (.clka(pixel_clk_in), .addra(eight_image_bits), .douta(eight_blue_mapped));

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
		
		hcount_temp[1] <= hcount_in/WIDTH;
		vcount_temp[1] <= vcount_in/HEIGHT;
		hcount_temp[0] <= hcount_temp[1]*WIDTH;
		vcount_temp[0] <= vcount_temp[1]*HEIGHT;
		
		if(hcount_out<=720&&vcount_out<=720) begin //only draw out the game tile region
		//if(hcount_in<=720&&vcount_in<=720) begin //only draw in the game tile region
			//if(!tile_status[vcount_in/HEIGHT][hcount_in/WIDTH]) begin//if tile has not been cleared, draw uncleared tile symbol
			if(!tile_status[vcount_out/HEIGHT][hcount_out/WIDTH]) begin //if tile has not been cleared, draw uncleared tile symbol
				pixel_out <= {fd_red_mapped[7:4], fd_red_mapped[7:4], fd_red_mapped[7:4]}; // greyscale
			end else if (tile_status[vcount_out/HEIGHT][hcount_out/WIDTH]==2'b11) begin //draw flag if flagged
			//end else if (tile_status[vcount_in/HEIGHT][hcount_in/WIDTH]==2'b11) begin //draw flag if flagged
				pixel_out <= {flag_red_mapped[7:4], flag_green_mapped[7:4], flag_blue_mapped[7:4]}; 
			end else begin //if tile has been cleared, draw the number of surrounding bombs
				curr_tile <= tile_numbers[vcount_out/HEIGHT][hcount_out/WIDTH]; 
				//curr_tile <= tile_numbers[vcount_in/HEIGHT][hcount_in/WIDTH]; 
				case(curr_tile)
					0: begin
						pixel_out <= {zero_red_mapped[7:4], zero_green_mapped[7:4], zero_blue_mapped[7:4]}; 
					end
					4'd1: begin
						pixel_out <= {one_red_mapped[7:4], one_green_mapped[7:4], one_blue_mapped[7:4]}; 
					end
					4'd2: begin
						pixel_out <= {two_red_mapped[7:4], two_green_mapped[7:4], two_blue_mapped[7:4]}; 
					end
					4'd3: begin
						pixel_out <= {three_red_mapped[7:4], three_green_mapped[7:4], three_blue_mapped[7:4]}; 
					end
					4'd4: begin
						pixel_out <= {four_red_mapped[7:4], four_green_mapped[7:4], four_blue_mapped[7:4]}; 
					end
					4'd5: begin
						pixel_out <= {five_red_mapped[7:4], five_green_mapped[7:4], five_blue_mapped[7:4]}; 
					end
					4'd6: begin
						pixel_out <= {six_red_mapped[7:4], six_green_mapped[7:4], six_blue_mapped[7:4]}; 
					end
					4'd7: begin
						pixel_out <= {seven_red_mapped[7:4], seven_green_mapped[7:4], seven_blue_mapped[7:4]}; 
					end
					4'd8: begin
						pixel_out <= {eight_red_mapped[7:4], eight_green_mapped[7:4], eight_blue_mapped[7:4]}; 
					end
					4'hF: begin
						pixel_out <= {bomb_red_mapped[7:4], bomb_green_mapped[7:4], bomb_blue_mapped[7:4]}; 
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
 
module hex_2_dec (
	input[15:0] hex_in,
	output [15:0] dec_out
);
	//Converts a hex number to decimal form for both flags and low freq timer
	logic [3:0] digit_3,digit_2,digit_1,digit_0; //0-9, one for each seven seg digit
	assign dec_out = {digit_3,digit_2,digit_1,digit_0};
	always_comb begin
		digit_0 = hex_in%10;
		digit_1 = (hex_in/10)%10;
		digit_2 = (hex_in/100)%10;
		digit_3 = (hex_in/1000)%10;
	end
endmodule //hex_2_dec
