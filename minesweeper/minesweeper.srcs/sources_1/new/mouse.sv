`timescale 1ns / 1ps

module mouse_renderer
	#(	parameter SCREEN_WIDTH=1024, 
		parameter SCREEN_HEIGHT=768,
		parameter MOUSE_INNER_COLOR = 'hFFF,
		parameter MOUSE_OUTER_COLOR = 'h000)
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

	//This module is pipelined by 2 clocks. Probably could be 1 but doesn't hurt the final product and also probably makes compile easier.

	logic [10:0] hcount [1:0] ;
	logic [9:0] vcount [1:0] ;
	logic hsync [1:0] ;
	logic vsync [1:0] ;
	logic blank [1:0] ;

	logic [11:0] pixel;

	//TODO: replace with real logic
	assign hcount_out = hcount[1];
	assign vcount_out = vcount[1];
	assign hsync_out = hsync[1];
	assign vsync_out = vsync[1];
	assign blank_out = blank[1];

	signed logic [10:0] relative_x;
	signed logic [9:0] relative_y;
	assign relative_x = hcount_in - mouse_x;
	assign relative_y = vcount_in - mouse_y;

	logic [3:0] mouse_pixel_x;
	logic [4:0] mouse_pixel_y;
	logic in_box;

	always_ff @(posedge clk_65mhz) begin

		//2 stage delay
		hcount[1] <= hcount[0];
		vcount[1] <= vcount[0];
		hsync[1] <= hsync[0];
		vsync[1] <= vsync[0];
		blank[1] <= blank[0];

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
			pixel_out <= pixel
		end

	end


endmodule


module mouse_ps2(
	input clk_65mhz, 
	input rst_n,
	inout ps2_clk, ps2_data,
	output logic received_packet,
	output logic [32:0] packet);

	logic [32:0] packet_buf;
	logic [3:0] state;

	parameter STATE_INIT = 0;
	parameter STATE_WAITING = 1; //data == 1, waiting for start of next packet
	parameter STATE_RECIEVING = 2; 
	parameter STATE_DONE = 3;
	parameter STATE_INITIAL_DELAY = 4;
	parameter STATE_SETUP = 5; //Todo will be split into multiple probably.

	always_ff @(posedge clk_65mhz or negedge rst_n) begin : proc_state
		if(~rst_n) begin
			state <= 0;
		end else begin
			case (state)
				STATE_INIT: begin
					received_packet <= 0;
					packet <= 0;
				end
				STATE_WAITING: 
					received_packet <= 0;
					if (ps2_data == 0 && )

				default: state <= 0; //Should not be reachable!
			endcase // state
		end
	end


endmodule


module mouse
	#(	parameter SCREEN_WIDTH=1024, 
		parameter SCREEN_HEIGHT=768)
	(
	input clk_65mhz,
	input rst_n,
	inout ps2_clk, ps2_data, 	// physical connections 
	output logic [10:0] mouse_x = 0,	// Mouse X coord.
	output logic [9:0] mouse_y = 0,		// Mouse Y coord.
	output logic mouse_left_click = 0,	// Mouse left button clicked. Not edge triggered.
	output logic mouse_right_click = 0	// Mouse right button clicked. Not edge triggered.
	);

	logic received_packet;
	logic [32:0] packet;
	logic [7:0] p_dx;
	logic [7:0] p_dy;
	logic p_l, p_r;
	logic p_xs, p_ys;
	logic p_valid;

	logic [7:0] new_x_inc; //Holds new x,y locations assuming increase or decrease, includes the max limit functionality.
	logic [7:0] new_x_dec;
	logic [7:0] new_y_inc;
	logic [7:0] new_y_dec;

	assign mouse_left_click = 0;
	assign mouse_right_click = 0;
	assign p_valid = (~packet[32]) && (~^packet[31:24] == packet[23]) && (packet[22]) &&
					 (~packet[21]) && (~^packet[20:13] == packet[12]) && (packet[11]) &&
					 (~packet[10]) && (~^packet[9:2] == packet[1]) && (packet[0]);
	assign p_dy = packet[9:2];
	assign p_dx = packet[20:13];
	assign p_l = packet[31];
	assign p_r = packet[30];
	assign p_xs = packet[27];
	assign p_ys = packet[26];

	assign new_x_inc = ( SCREEN_WIDTH - mouse_x < p_dx) ? SCREEN_WIDTH : mouse_x + p_dx;
	assign new_x_dec = ( mouse_x < p_dx) ? 0 : mouse_x - p_dx;
	assign new_y_inc = ( SCREEN_HEIGHT - mouse_y < p_dy) ? SCREEN_HEIGHT : mouse_y + p_dy;
	assign new_y_dec = ( mouse_y < p_dy) ? 0 : mouse_y + p_dy;

	always_ff @(posedge clk_65mhz or negedge rst_n) begin : proc_mouse
		if(~rst_n) begin
			mouse_x <= SCREEN_WIDTH/2;
			mouse_y <= SCREEN_HEIGHT/2;
		end else begin
			if (received_packet && p_valid) begin
				mouse_x <= (p_xs) ? new_x_dec : new_x_inc;
				mouse_y <= (p_ys) ? new_y_dec : new_y_inc;
				mouse_left_click <= p_l;
				mouse_right_click <= p_r;
			end
		end
	end

endmodule



