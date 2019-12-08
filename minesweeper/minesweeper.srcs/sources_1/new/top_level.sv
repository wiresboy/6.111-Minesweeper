`timescale 1ns / 1ps
`default_nettype none

module top_level(
	input wire clk_100mhz,
	input wire [15:0] sw,
	input wire btnc, btnu, btnl, btnr, btnd, reset_n, //reset is active low 
	output logic [15:0] led,
	output logic [3:0] vga_r,
	output logic [3:0] vga_b,
	output logic [3:0] vga_g,
	output logic vga_hs,
	output logic vga_vs,
	output logic ca, cb, cc, cd, ce, cf, cg, dp,  // segments a-g, dp
	output logic [7:0] an,    // Display location 0-7
	inout wire sd_reset, sd_cd, sd_sck, sd_cmd, //SD control
	inout wire [3:0] sd_dat, //SD data
	output logic aud_pwm, aud_sd, //audio output
	inout wire ps2_clk, ps2_data //Mouse
	);

	wire reset;
	assign reset = ~reset_n;
	
	
	// ***** CLOCK *****
	wire clk_25mhz;
	wire clk_65mhz;
	wire clk_200mhz;
	// create 65mhz system clock, happens to match 1024 x 768 XVGA timing
	// create 200mhz clock for ddram
	// 25mhz for SD card
	clk_wiz_0 clkdivider(.clk_in1(clk_100mhz), .reset(reset), .clk_out1(clk_200mhz)/*, .clk_out2(clk_65mhz)*/, .clk_out2(clk_25mhz));
	
	// ***** SEVEN SEGMENT *****
	wire [31:0] ms_seven_segment_data;	// data from minesweeper module
	wire [31:0] seven_segment_data;		// sent to display - (8) 4-bit hex
	wire [6:0] segments;
	assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
	display_8hex display(.clk_in(clk_100mhz/*clk_65mhz*/),.data_in(seven_segment_data), .seg_out(segments), .strobe_out(an));
	assign  dp = 0; //decimal is off
	assign seven_segment_data = ms_seven_segment_data; //TODO: can be muxed 

	// ***** LED outputs *****
	assign led[15:10] = sw[15:10];		// turn leds on based on switches
	

	// ***** Button Debounce *****
	// all button uses are TBD
	wire center_pressed,up_pressed,down_pressed,left_pressed,right_pressed;
	debounce db1(.reset_in(reset),.clock_in(clk_100mhz),.noisy_in(btnc),.clean_out(center_pressed));
	debounce db2(.reset_in(reset),.clock_in(clk_100mhz),.noisy_in(btnu),.clean_out(up_pressed));
	debounce db3(.reset_in(reset),.clock_in(clk_100mhz),.noisy_in(btnd),.clean_out(down_pressed));
	debounce db4(.reset_in(reset),.clock_in(clk_100mhz),.noisy_in(btnl),.clean_out(left_pressed));
	debounce db5(.reset_in(reset),.clock_in(clk_100mhz),.noisy_in(btnr),.clean_out(right_pressed));
	
	
	// ***** Sound *****
	logic [1:0] sound_effect_select;
	logic sound_effect_start;
	assign sound_effect_select = sw[1:0];
	assign sound_effect_start = center_pressed;
	sound_effect_manager sfx_manager(.clk_100mhz(clk_100mhz), .clk_25mhz(clk_25mhz), .reset(reset), .sw(sw), 
			.sound_effect_select(sound_effect_select), .sound_effect_start(sound_effect_start), 
			.aud_pwm(aud_pwm), .aud_sd(aud_sd),
			.sd_reset(sd_reset), .sd_cd(sd_cd), .sd_sck(sd_sck), .sd_cmd(sd_cmd), .sd_dat(sd_dat),
			.audio(led[7:0]), .debug(ms_seven_segment_data) );
	assign led[8] = aud_pwm;
	assign led[9] = center_pressed;

/*
	// ***** Random *****
	logic [15:0] random_number;
	random random(clk_65mhz, reset, random_number);
	

	// ***** Mouse *****
	logic [11:0] mouse_x;
	logic [11:0] mouse_y;
	logic mouse_left_click, mouse_right_click;
*/

	/*mouse mouse(.clk_65mhz(clk_65mhz), .rst(reset),
				.ps2_clk(ps2_clk), .ps2_data(ps2_data),
				.mouse_x(mouse_x), .mouse_y(mouse_y),
				.mouse_left_click(mouse_left_click),
				.mouse_right_click(mouse_right_click));*/
/*	MouseCtl MouseCtl(	.clk(clk_65mhz), .rst(reset),
						.ps2_clk(ps2_clk), .ps2_data(ps2_data),
						.xpos(mouse_x), .ypos(mouse_y),
						.left(mouse_left_click), .right(mouse_right_click)
						);
	assign led = {mouse_left_click, mouse_right_click};
	//assign seven_segment_data = {mouse_x, 4'b0, mouse_y}; 

	// ***** VGA Gen *****
	wire [10:0] hcount;    // pixel on current line
	wire [9:0] vcount;     // line number
	wire hsync, vsync, blank;
	xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
		  .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));


	// ***** Minesweeper Game *****
	wire ms_hsync,ms_vsync,ms_blank;//delayed timing signals
	wire [10:0] ms_hcount; 
	wire [9:0] ms_vcount;
	wire [11:0] ms_pixel;
	minesweeper minesweeper(
			.clk_65mhz(clk_65mhz),.reset(reset),
			.up_in(up_pressed),.down_in(down_pressed),
			.center_in(center_pressed),.left_in(left_pressed),
			.right_in(right_pressed),
			.mouse_x(mouse_x),.mouse_y(mouse_y),
			.mouse_left_click(mouse_left_click),
			.mouse_right_click(mouse_right_click),
			.sw(sw),
			.random(random_number),
			.hcount_in(hcount),.vcount_in(vcount),
			.hsync_in(hsync),.vsync_in(vsync),.blank_in(blank),
			.pixel_out(ms_pixel),
			.seven_seg_out(ms_seven_segment_data)
			//,  TODO sound
			);


	// ***** Mouse Video Gen *****
	wire mouse_hsync,mouse_vsync,mouse_blank;//delayed timing signals
	wire [10:0] mouse_hcount; 
	wire [9:0] mouse_vcount;
	wire [11:0] mouse_pixel;

	assign ms_hsync = hsync;
	assign ms_vsync = vsync;
	assign ms_blank = blank;
	assign ms_vcount = vcount;
	assign ms_hcount = hcount;
	mouse_renderer mouse_renderer(
			.clk_65mhz(clk_65mhz),.reset(reset),
			.mouse_x(mouse_x),.mouse_y(mouse_y),
			.hcount_in(ms_hcount),.vcount_in(ms_vcount),
			.hsync_in(ms_hsync),.vsync_in(ms_vsync),.blank_in(ms_blank),
			.hcount_out(mouse_hcount),.vcount_out(mouse_vcount),
			.hsync_out(mouse_hsync),.vsync_out(mouse_vsync),.blank_out(mouse_blank),
			.pixel_in(ms_pixel),.pixel_out(mouse_pixel));


	// ***** VIDEO OUT *****
	reg [11:0] rgb;    
	logic hs, vs, b;
	always_ff @(posedge clk_65mhz) begin
		hs <= mouse_hsync;
		vs <= mouse_vsync;
		b <= mouse_blank;
		rgb <= mouse_pixel;
	end

	assign vga_r = ~b ? rgb[11:8]: 0;
	assign vga_g = ~b ? rgb[7:4] : 0;
	assign vga_b = ~b ? rgb[3:0] : 0;
	assign vga_hs = ~hs;
	assign vga_vs = ~vs;
*/
	
	
endmodule
