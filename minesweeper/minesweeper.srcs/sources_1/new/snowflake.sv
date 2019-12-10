`timescale 1ns / 1ps

module snowflakes
	#(	parameter RANDOM_RANGE = 2100, 
		parameter MAX_FLAKES = 25,
		parameter UPDATE_PERIOD_CLOCKS = 1083333) //60fps ish
	(
		input clk_65mhz,
		input reset,

		input [15:0] random,

		input [10:0] hcount_in,	// horizontal index of current pixel (0..1023)
		input [9:0] vcount_in,	// vertical index of current pixel (0..767)
		input hsync_in,			// XVGA horizontal sync signal (active low)
		input vsync_in,			// XVGA vertical sync signal (active low)
		input blank_in,			// XVGA blanking (1 means output black pixel)
		input [11:0] pixel_in,	// input pixel to pass through if not under flake.

		output [10:0] hcount_out,// horizontal index of current pixel (buffered)
		output [9:0] vcount_out,	// vertical index of current pixel (buffered)
		output hsync_out,		// horizontal sync (output with buffering)
		output vsync_out,		// vertical sync (output with buffering)
		output blank_out,		// blanking (output with buffering)
		output logic [11:0] pixel_out	// pixel r=11:8, g=7:4, b=3:0 (output with buffering)
		);

	logic [23:0] update_count = 0;
	always @(posedge clk_65mhz) begin : proc_update_count
		if (reset) begin
			update_count <= 0;
		end else begin
			if (update_count == UPDATE_PERIOD_CLOCKS)
				update_count <= 0;
			else
				update_count <= update_count + 1;
		end
	end

	logic [10:0] flake_x [MAX_FLAKES];
	logic [9:0] flake_y [MAX_FLAKES];

	wire flake_hsync[MAX_FLAKES+1];
	wire flake_vsync[MAX_FLAKES+1];
	wire flake_blank[MAX_FLAKES+1];//delayed timing signals
	wire [10:0] flake_hcount[MAX_FLAKES+1]; 
	wire [9:0] flake_vcount[MAX_FLAKES+1];
	wire [11:0] flake_pixel[MAX_FLAKES+1];

	genvar i;
	generate
		for (i=0; i<MAX_FLAKES; i=i+1) begin : generated_snowflakes
			snowflake_tracker sf (
				.update_strobe(update_count == 1 + (1001*i)), 
				.reset(reset), .random(random), 
				.flake_x(flake_x[i]), .flake_y(flake_y[i]));
			snowflake_renderer sf_r (
				.clk_65mhz(clk_65mhz),
				.flake_x(flake_x[i]),.flake_y(flake_y[i]),
				.hcount_in(flake_hcount[i]),.vcount_in(flake_vcount[i]),
				.hsync_in(flake_hsync[i]),.vsync_in(flake_vsync[i]),.blank_in(flake_blank[i]),
				.hcount_out(flake_hcount[i+1]),.vcount_out(flake_vcount[i+1]),
				.hsync_out(flake_hsync[i+1]),.vsync_out(flake_vsync[i+1]),.blank_out(flake_blank[i+1]),
				.pixel_in(flake_pixel[i]),.pixel_out(flake_pixel[i+1])
				);
		end
	endgenerate

	assign flake_hsync[0] = hsync_in;
	assign flake_vsync[0] = vsync_in;
	assign flake_blank[0] = blank_in;
	assign flake_hcount[0] = hcount_in;
	assign flake_vcount[0] = vcount_in;
	assign flake_pixel[0] = pixel_in;

	assign hsync_out  = flake_hsync[MAX_FLAKES];
	assign vsync_out  = flake_vsync[MAX_FLAKES];
	assign blank_out  = flake_blank[MAX_FLAKES];
	assign hcount_out = flake_hcount[MAX_FLAKES];
	assign vcount_out = flake_vcount[MAX_FLAKES];
	assign pixel_out = flake_pixel[MAX_FLAKES];

endmodule

module snowflake_tracker
	#(	parameter SCREEN_WIDTH=1024,
		parameter SCREEN_HEIGHT=768,
		parameter RANDOM_BASE=10000,
		parameter RANDOM_RANGE=2100)
	(
		input update_strobe, //clock ish
		input reset,
		input [15:0] random,
		output logic [10:0] flake_x,
		output logic [9:0] flake_y
	);

	logic [1:0] state;
	logic [2:0] velocity; //goal velocity of ~7pixels/frame, allowable range of 3 to 10.
	//STATE: 0 = init, wait for random chance to initialize drop
	//STATE: 1 = ready to fall, selecy velocity
	//STATE: 2 = ready to fall, select x position
	//STATE: 3 = falling until bottom edge passed.
	always @(posedge update_strobe or posedge reset) begin : proc_state
		if (reset) begin
			state <= 0;
		end else begin
			case (state)
				0: begin
					flake_x <= 1800;
					flake_y <= 0;
					if (random>RANDOM_BASE && random<RANDOM_BASE+RANDOM_RANGE) //begin falling?
						state<=1;
				end
				1: begin
					velocity <= random[2:0];//{3'b0,random[0]}+{3'b0,random[1]}+{3'b0,random[2]}+{3'b0,random[3]};
					state<=2;
				end
				2: begin
					flake_x <= random[10:0]-20;
					state<=3;
				end
				3: begin
					flake_y <= flake_y + velocity + 3;
					if (flake_y > 768)
						state<=0;
				end

			endcase
		end
	end
endmodule

module snowflake_renderer
	#(	parameter SCREEN_WIDTH=1024, 
		parameter SCREEN_HEIGHT=768,
		parameter SNOWFLAKE_COLOR = 'hFFF)
	(	
	input clk_65mhz,
	
	input [10:0] flake_x,	// flake X coord.
	input [9:0] flake_y,	// flake Y coord.

	input [10:0] hcount_in,	// horizontal index of current pixel (0..1023)
	input [9:0] vcount_in,	// vertical index of current pixel (0..767)
	input hsync_in,			// XVGA horizontal sync signal (active low)
	input vsync_in,			// XVGA vertical sync signal (active low)
	input blank_in,			// XVGA blanking (1 means output black pixel)
	input [11:0] pixel_in,	// input pixel to pass through if not under flake.

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

	assign relative_x = hcount_in - flake_x;
	assign relative_y = vcount_in - flake_y;

	logic [5:0] x; //flake pixel x
	logic [5:0] y; //flake pixel y
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
		in_box <= (relative_x>=0) && (relative_x<=20) && (relative_y>=0) && (relative_y<=20);

		x <= relative_x[5:0]; // flake icon pixel offset
		y <= relative_y[5:0];

		//pipeline stage 1
		if (in_box) begin
			if (
					(y==x && y!=0 && y!=20) || 
					(y==(20-x) && y!=0 && y!=20) ||
					(y==10) ||
					(x==10) ||
					((y==2||y==18)&& (x==6||x==14)) ||
					((y==3||y==17)&& (x==8||x==12)) ||
					((y==5||y==15)&& (x==6||x==14)) ||
					((y==6||y==14)&& (x==2||x==5||x==15||x==18)) ||
					((y==8||y==12)&& (x==3||x==17))
				) 
				pixel_out <= SNOWFLAKE_COLOR;
			else
				pixel_out <= pixel;

		end else begin
			pixel_out <= pixel;
		end
	end
endmodule
