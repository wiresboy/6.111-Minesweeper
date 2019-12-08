`default_nettype none

module sound_effect_manager (
	input wire clk_100mhz,
	input wire clk_25mhz,
	input wire reset,
	input wire [15:0] sw, //TEMP
	input wire [1:0] sound_effect_select,	//indices and meanings TBD
	input wire sound_effect_start,			//start the selected sound effect. Strobe for only 1 clock.
	output logic aud_pwm,
	output logic aud_sd,
	inout wire sd_reset, sd_cd, sd_sck, sd_cmd,
	inout wire [3:0] sd_dat,
	output logic [7:0] audio,
	output logic [31:0] debug
);
	parameter SAMPLE_PERIOD = 2083;//100000000/48000=2083.333;
	parameter SOUND_1_START_BLOCK = 512*2;

	logic initialized = 1;

	logic sd_rd;
	logic [7:0] sd_dout;
	logic sd_rd_strobe;
	logic sd_rd_slow, sd_rd_slow_last;
	logic [31:0] sd_address;
	logic sd_ready;

	always_ff @(posedge clk_100mhz) begin : proc_sd_rd
		if (reset) begin
			sd_rd_slow_last <= 0;
			sd_rd_strobe <= 0;
		end else begin
			sd_rd_strobe <= sd_rd_slow&&(~sd_rd_slow_last);
			sd_rd_slow_last <= sd_rd_slow;
		end
	end

	assign sd_dat[2] = 1; //1 bit spi mode - leave these as is
	assign sd_dat[1] = 1;
	assign sd_reset = 0;
	
	logic [7:0] status;
	
	sd_controller sd(
		.clk(clk_25mhz), .reset(reset), 
		.cs(sd_dat[3]),.mosi(sd_cmd),.miso(sd_dat[0]),.sclk(sd_sck),
		.rd(sd_rd), //read enable. 
		.dout(sd_dout), //read data out
		.byte_available(sd_rd_slow), //read byte available
		.wr(0),.din(0),//never write enable.
		.address(sd_address), //32 bit, must be multiple of 512
		.ready(sd_ready), .status(status));

	logic [4:0] data_request_flag;
	logic [4:0] data_access_granted;
	data_manager dm(clk_100mhz, reset, data_request_flag, data_access_granted, sd_rd_strobe);
	
	
	logic [25:0] data_request_offset [5];
	logic [31:0] song_duration_samples [4];
	logic [31:0] song_start_offset [4];
	brandon_fs_reader fs(.clk_100mhz(clk_100mhz), .reset(reset),
						.data_request_offset(data_request_offset[4]), .data_request_flag(data_request_flag[4]),
						.data_request_result(sd_dout), .data_ready_strobe(data_access_granted[4] && sd_rd_strobe),
						.start_offset(song_start_offset), .duration_samples(song_duration_samples));


	logic [11:0] sample_trigger_count = 0; //max 2083 - fits in 12 bits (4096)
	always_ff @(posedge clk_100mhz) begin : proc_sample_trigger_count
		if (reset) begin
			sample_trigger_count <= 0;
		end else begin
			if (sample_trigger_count == SAMPLE_PERIOD)
				sample_trigger_count <= 0;
			else
				sample_trigger_count <= sample_trigger_count+1;
		end
	end
	
	logic sample_trigger;
	assign sample_trigger = sample_trigger_count == 0; //initialized && 

	logic [7:0] audio_single [4];

	sound_effect_player sfx0(.clk_100mhz(clk_100mhz), .reset(reset),
							.sound_effect_start(sound_effect_start && (sound_effect_select==0)), .sample_trigger(sample_trigger),
							.data_request_offset(data_request_offset[0]), .data_request_flag(data_request_flag[0]),
							.data_request_result(sd_dout), .data_ready_strobe(data_access_granted[0] && sd_rd_strobe),
							.duration_samples(song_duration_samples[0]),.audio(audio_single[0]));

	sound_effect_player sfx1(.clk_100mhz(clk_100mhz), .reset(reset),
							.sound_effect_start(sound_effect_start && (sound_effect_select==1)), .sample_trigger(sample_trigger),
							.data_request_offset(data_request_offset[1]), .data_request_flag(data_request_flag[1]),
							.data_request_result(sd_dout), .data_ready_strobe(data_access_granted[1] && sd_rd_strobe),
							.duration_samples(song_duration_samples[1]),.audio(audio_single[1]));

	sound_effect_player sfx2(.clk_100mhz(clk_100mhz), .reset(reset),
							.sound_effect_start(sound_effect_start && (sound_effect_select==2)), .sample_trigger(sample_trigger),
							.data_request_offset(data_request_offset[2]), .data_request_flag(data_request_flag[2]),
							.data_request_result(sd_dout), .data_ready_strobe(data_access_granted[2] && sd_rd_strobe),
							.duration_samples(song_duration_samples[2]),.audio(audio_single[2]));

	sound_effect_player sfx3(.clk_100mhz(clk_100mhz), .reset(reset),
							.sound_effect_start(sound_effect_start && (sound_effect_select==3)), .sample_trigger(sample_trigger),
							.data_request_offset(data_request_offset[3]), .data_request_flag(data_request_flag[3]),
							.data_request_result(sd_dout), .data_ready_strobe(data_access_granted[3] && sd_rd_strobe),
							.duration_samples(song_duration_samples[3]),.audio(audio_single[3]));
	
	always_comb begin
		case (data_access_granted) 
			5'b00001 : begin 
				sd_rd = data_request_flag[0];
				sd_address = song_start_offset[0]+data_request_offset[0];
			end
			5'b00010 : begin 
				sd_rd = data_request_flag[1];
				sd_address = song_start_offset[1]+data_request_offset[1];
			end
			5'b00100 : begin 
				sd_rd = data_request_flag[2];
				sd_address = song_start_offset[2]+data_request_offset[2];
			end
			5'b01000 : begin 
				sd_rd = data_request_flag[3];
				sd_address = song_start_offset[3]+data_request_offset[3];
			end
			5'b10000 : begin //special - is fs loader
				sd_rd = data_request_flag[4];
				sd_address = data_request_offset[4];
			end
			default: begin
				sd_rd = 0;
				sd_address = 0;
			end
		endcase
	end

	//assign debug = {data_request_flag[0], status, audio, sd_dout, sample_trigger_count[11:4]};
	assign debug = sw[2]? song_start_offset[sw[1:0]]: song_duration_samples[sw[1:0]];


	logic [10:0] audio_sum;
	always_comb begin
		audio_sum = audio_single[0] + audio_single[1] + audio_single[2] + audio_single[3];
		if (audio_sum < 'h17E)
			audio = 0;
		else if (audio_sum >= 'h27D)
			audio = 'hFF;
		else
			audio = audio_sum-'h17E;
	end
	//assign audio = audio_single[0];

	//ila_0 ila(clk_100mhz, sd_rd_slow, sd_dout, sd_ready, sample_trigger, clk_25mhz, sd_status, sd_state);

	//logic [7:0] audio;
	//assign audio = audio_single[0];

	logic [7:0] vol_out;
	logic pwm_val;

	//volume_control vc (.vol_in(sw[15:13]), .signal_in(audio), .signal_out(vol_out));
	pwm (.clk_in(clk_100mhz), .rst_in(reset), .level_in(audio), .pwm_out(pwm_val));
	assign aud_pwm = pwm_val?1'bZ:1'b0;
	assign aud_sd = 1;

endmodule



module data_manager (
	input wire clk_100mhz,
	input wire reset,
	input wire [4:0] data_request,
	output logic [4:0] data_access_granted = 0,
	input wire sd_rd_strobe
	);

	logic [8:0] count;
	
	always_ff @(posedge clk_100mhz) begin : proc_data_access_granted
		if (reset) begin
			data_access_granted <= 0;
		end else begin
			if (data_access_granted == 0 || count == 0) begin
				if (data_request[4])
					data_access_granted <= 16; //highest priority to the initializer
				else if (data_request[0])
					data_access_granted <= 1;
				else if (data_request[1])
					data_access_granted <= 2;
				else if (data_request[2])
					data_access_granted <= 4;
				else if (data_request[3])
					data_access_granted <= 8;
				else
					data_access_granted <= 0;
			end
		end
	end

	always_ff @(posedge clk_100mhz) begin : proc_count_data_manager
		if (reset) begin
			count <= 0;
		end else begin
			count <= count + sd_rd_strobe;
		end
	end
	
endmodule
	
module brandon_fs_reader (
		input wire clk_100mhz,
		input wire reset,

		output logic [31:0] start_offset [4] = {0,0,0,0}, // where each file starts. In 
		output logic [31:0] duration_samples [4] = {0,0,0,0},
		output logic data_request_flag = 1, //1 for more data needed. Start in this state.
		output logic [25:0] data_request_offset = 0,
		input wire [7:0] data_request_result,
		input wire data_ready_strobe //1 for 1 cycle indicating data is available
	);
	parameter STATE_INIT = 'h200;
	parameter STATE_S0_ADDRESS_0 = 'h010;
	parameter STATE_S0_ADDRESS_1 = 'h011;
	parameter STATE_S0_ADDRESS_2 = 'h012;
	parameter STATE_S0_ADDRESS_3 = 'h013;
	parameter STATE_S0_LENGTH_0  = 'h014;
	parameter STATE_S0_LENGTH_1  = 'h015;
	parameter STATE_S0_LENGTH_2  = 'h016;
	parameter STATE_S0_LENGTH_3  = 'h017;
	parameter STATE_S1_ADDRESS_0 = 'h018;
	parameter STATE_S1_ADDRESS_1 = 'h019;
	parameter STATE_S1_ADDRESS_2 = 'h01A;
	parameter STATE_S1_ADDRESS_3 = 'h01B;
	parameter STATE_S1_LENGTH_0  = 'h01C;
	parameter STATE_S1_LENGTH_1  = 'h01D;
	parameter STATE_S1_LENGTH_2  = 'h01E;
	parameter STATE_S1_LENGTH_3  = 'h01F;
	parameter STATE_S2_ADDRESS_0 = 'h020;
	parameter STATE_S2_ADDRESS_1 = 'h021;
	parameter STATE_S2_ADDRESS_2 = 'h022;
	parameter STATE_S2_ADDRESS_3 = 'h023;
	parameter STATE_S2_LENGTH_0  = 'h024;
	parameter STATE_S2_LENGTH_1  = 'h025;
	parameter STATE_S2_LENGTH_2  = 'h026;
	parameter STATE_S2_LENGTH_3  = 'h027;
	parameter STATE_S3_ADDRESS_0 = 'h028;
	parameter STATE_S3_ADDRESS_1 = 'h029;
	parameter STATE_S3_ADDRESS_2 = 'h02A;
	parameter STATE_S3_ADDRESS_3 = 'h02B;
	parameter STATE_S3_LENGTH_0  = 'h02C;
	parameter STATE_S3_LENGTH_1  = 'h02D;
	parameter STATE_S3_LENGTH_2  = 'h02E;
	parameter STATE_S3_LENGTH_3  = 'h02F; //TODO is there a cleaner way to do all this???
	parameter STATE_LOADED		 = 'h1FE;

	logic [9:0] state = STATE_INIT;

	always_ff @(posedge clk_100mhz) begin : proc_state_brandon_fs_reader
		if (reset) begin
			state <= STATE_INIT;
			data_request_flag <= 1;
			data_request_offset <= 0;
			duration_samples <= {0,0,0,0};
			start_offset <= {0,0,0,0};
			
		end else begin
			case (state)
				STATE_INIT:
					state <= 0;
				STATE_LOADED : begin
					state <= state;
					data_request_flag <= 0;
					end
				default:
					state <= state + data_ready_strobe;
			endcase
			
			case (state)
				STATE_INIT: begin
					data_request_flag <= 1;
					data_request_offset <= 0;
				end
				STATE_S0_ADDRESS_0:
					start_offset[0][31:24] <= data_request_result;
				STATE_S0_ADDRESS_1:
					start_offset[0][23:16] <= data_request_result;
				STATE_S0_ADDRESS_2:
					start_offset[0][15:8] <= data_request_result;
				STATE_S0_ADDRESS_3:
					start_offset[0][7:0] <= data_request_result;
				STATE_S0_LENGTH_0 :
					duration_samples[0][31:24] <= data_request_result;
				STATE_S0_LENGTH_1 :
					duration_samples[0][23:16] <= data_request_result;
				STATE_S0_LENGTH_2 :
					duration_samples[0][15:8] <= data_request_result;
				STATE_S0_LENGTH_3 :
					duration_samples[0][7:0] <= data_request_result;
				STATE_S1_ADDRESS_0:
					start_offset[1][31:24] <= data_request_result;
				STATE_S1_ADDRESS_1:
					start_offset[1][23:16] <= data_request_result;
				STATE_S1_ADDRESS_2:
					start_offset[1][15:8] <= data_request_result;
				STATE_S1_ADDRESS_3:
					start_offset[1][7:0] <= data_request_result;
				STATE_S1_LENGTH_0 :
					duration_samples[1][31:24] <= data_request_result;
				STATE_S1_LENGTH_1 :
					duration_samples[1][23:16] <= data_request_result;
				STATE_S1_LENGTH_2 :
					duration_samples[1][15:8] <= data_request_result;
				STATE_S1_LENGTH_3 :
					duration_samples[1][7:0] <= data_request_result;
				STATE_S2_ADDRESS_0:
					start_offset[2][31:24] <= data_request_result;
				STATE_S2_ADDRESS_1:
					start_offset[2][23:16] <= data_request_result;
				STATE_S2_ADDRESS_2:
					start_offset[2][15:8] <= data_request_result;
				STATE_S2_ADDRESS_3:
					start_offset[2][7:0] <= data_request_result;
				STATE_S2_LENGTH_0 :
					duration_samples[2][31:24] <= data_request_result;
				STATE_S2_LENGTH_1 :
					duration_samples[2][23:16] <= data_request_result;
				STATE_S2_LENGTH_2 :
					duration_samples[2][15:8] <= data_request_result;
				STATE_S2_LENGTH_3 :
					duration_samples[2][7:0] <= data_request_result;
				STATE_S3_ADDRESS_0:
					start_offset[3][31:24] <= data_request_result;
				STATE_S3_ADDRESS_1:
					start_offset[3][23:16] <= data_request_result;
				STATE_S3_ADDRESS_2:
					start_offset[3][15:8] <= data_request_result;
				STATE_S3_ADDRESS_3:
					start_offset[3][7:0] <= data_request_result;
				STATE_S3_LENGTH_0 :
					duration_samples[3][31:24] <= data_request_result;
				STATE_S3_LENGTH_1 :
					duration_samples[3][23:16] <= data_request_result;
				STATE_S3_LENGTH_2 :
					duration_samples[3][15:8] <= data_request_result;
				STATE_S3_LENGTH_3 :
					duration_samples[3][7:0] <= data_request_result;
			endcase
		end
	end

endmodule

module sound_effect_player#(parameter LOOP = 0)
	(
		input wire clk_100mhz,
		input wire reset,
		input wire sound_effect_start,			//start the selected sound effect. Strobe for only 1 clock.
		input wire sample_trigger,

		input wire [31:0] duration_samples,

		output logic [25:0] data_request_offset = 0, //~20 minutes of audio!
		output logic data_request_flag, //1 for more data needed
		input wire [7:0] data_request_result,
		input wire data_ready_strobe, //1 for 1 cycle indicating data is available

		output logic [7:0] audio = 'h80
	);

	logic [7:0] fifo_out;
	logic fifo_full;
	logic fifo_reset;
	logic fifo_empty;
	logic playing = 0;
	fifo_generator_0 fifo(.clk(clk_100mhz), .srst(reset||fifo_reset), .din(data_request_result), 
				.wr_en(data_ready_strobe), .empty(fifo_empty), .prog_full(fifo_full), .dout(fifo_out), .rd_en( sample_trigger ));
	assign data_request_flag = (playing) && (!fifo_full) && (data_request_offset[8:0]==9'b0); 
	//always request data while fifo is not full, and when request offset is multiple of 512


	logic [31:0] sample_counter;

	assign fifo_reset = !playing;


	always_ff @(posedge clk_100mhz) begin : proc_sample_counter
		if (reset) begin
			sample_counter <= 0;
		end else begin
			if (sample_counter == duration_samples)
				sample_counter <= 0;
			else if ((playing||sample_counter[8:0]!=9'b0) && sample_trigger)
				sample_counter <= sample_counter + 1;
		end
	end

	always_ff @(posedge clk_100mhz) begin : proc_playing
		if (reset) begin
			playing <= 0;
		end else begin
			if (sound_effect_start)
				playing <= 1;
			else if (sample_counter == duration_samples)
				playing <= LOOP; //stop playing unless this sample loops
		end
	end

	always_ff @(posedge clk_100mhz) begin : proc_audio
		if (reset) begin
			audio <= 'h80;
		end else begin
			if (playing && ~fifo_empty) begin
				audio <= fifo_out;//read from fifo
			end else
				audio <= 'h80;
		end
	end

	always_ff @(posedge clk_100mhz) begin : proc_data_request_offset
		if (reset) begin
			data_request_offset <= 0;
		end else begin
			//always a multiple of 512
			if (
					(data_request_offset >= duration_samples) &&
					(data_request_offset[8:0] == 0)
				)
				data_request_offset <= 0;
			else
				data_request_offset <= data_request_offset + data_ready_strobe;
		end
	end
endmodule





//Volume Control
module volume_control (input wire [2:0] vol_in, input wire [7:0] signal_in, output logic [7:0] signal_out);
    logic [2:0] shift;
    assign shift = 3'd7 - vol_in;
    assign signal_out = signal_in>>>shift;
endmodule

//PWM generator for audio generation!
module pwm (input wire clk_in, input wire rst_in, input wire [7:0] level_in, output logic pwm_out);
    logic [7:0] count;
    assign pwm_out = count<level_in;
    always_ff @(posedge clk_in)begin
        if (rst_in)begin
            count <= 8'b0;
        end else begin
            count <= count+8'b1;
        end
    end
endmodule