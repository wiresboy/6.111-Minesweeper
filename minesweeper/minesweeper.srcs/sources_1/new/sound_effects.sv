
module sound_effect_manager (
	input clk_100mhz,
	input clk_25mhz,
	input reset,
	input [15:0] sw, //TEMP
	input [1:0] sound_effect_select,	//indices and meanings TBD
	input sound_effect_start,			//start the selected sound effect. Strobe for only 1 clock.
	output logic aud_pwm,
	output logic aud_sd,
	inout sd_reset, sd_cd, sd_sck, sd_cmd,
	inout[3:0] sd_dat,
	output logic [7:0] audio,
	output logic [31:0] debug
);
	parameter SAMPLE_PERIOD = 2083;//100000000/48000=2083.333;
	parameter SOUND_1_START_BLOCK = 512*128;

	logic initialized = 1;

	logic sd_rd;
	logic [7:0] sd_dout;
	logic sd_rd_strobe;
	logic sd_rd_slow, sd_rd_slow_last;
	logic [31:0] sd_address;

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

	sd_controller sd(
		.clk(clk_25mhz), .reset(reset), 
		.cs(sd_dat[3]),.mosi(sd_mosi),.miso(sd_dat[0]),.sclk(sd_sck),
		.rd(1),//TEMP OVERRIDE sd_rd), //read enable. 
		.dout(sd_dout), //read data out
		.byte_available(sd_rd_slow), //read byte available
		.wr(0),.din(0),//never write enable.
		.address(1024),//TEMP OVERRIDE sd_address), //32 bit, must be multiple of 512
		.ready(sd_ready));

	logic [3:0] data_request;
	logic [3:0] data_access_granted;
	data_manager dm(clk_100mhz, reset, data_request, data_access_granted, sd_rd_strobe);



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
	assign sample_trigger = sample_trigger_count ==0; //initialized && 

	logic [25:0] data_request_offset [1:0];
	logic [1:0] data_request_flag;
	logic [7:0] audio_single [1:0];

	sound_effect_player sfx0(.clk_100mhz(clk_100mhz), .reset(reset),
							.sound_effect_start(sound_effect_start/* && sound_effect_select==0*/), .sample_trigger(sample_trigger),
							.data_request_offset(data_request_offset[0]), .data_request_flag(data_request_flag[0]),
							.data_request_result(sd_dout), .data_ready_strobe(/*data_access_granted[0] && */sd_rd_strobe),
							.duration_samples(9070550),.audio(audio/*audio_single[0]*/));

	//temp
	assign sd_rd = data_request_flag[0];
	assign sd_address = 1024+data_request_offset[0];

	assign debug[13:0] = {data_request_flag[0], sd_dout, sample_trigger_count[11:4]};


	//logic [7:0] audio;
	//assign audio = audio_single[0];

	logic [7:0] vol_out;

	volume_control vc (.vol_in(sw[15:13]), .signal_in(audio), .signal_out(vol_out));
	pwm (.clk_in(clk_100mhz), .rst_in(reset), .level_in(audio/*{~vol_out[7],vol_out[6:0]}*/), .pwm_out(pwm_val));
	assign aud_pwm = pwm_val?1'bZ:1'b0;
	assign aud_sd = 1;

endmodule



module data_manager ( //TODO for multi-audio-allowed
	input clk_100mhz,
	input reset,
	input [3:0] data_request,
	output logic [3:0] data_access_granted,
	input sd_rd_strobe
	);
	logic [8:0] count;
	
	assign data_access_granted = 15;

	always_ff @(posedge clk_100mhz) begin : proc_data_manager
		if (reset) begin
			count <= 0;
		end else begin
			count <= count + sd_rd_strobe;
		end
	end
	
endmodule
	


module sound_effect_player#(parameter LOOP = 1)
	(
		input clk_100mhz,
		input reset,
		input sound_effect_start,			//start the selected sound effect. Strobe for only 1 clock.
		input sample_trigger,

		input [31:0] duration_samples,

		output logic [25:0] data_request_offset = 0, //~20 minutes of audio!
		output logic data_request_flag, //1 for more data needed
		input [7:0] data_request_result,
		input data_ready_strobe, //1 for 1 cycle indicating data is available

		output logic [7:0] audio
	);

	logic [7:0] fifo_out;
	logic fifo_full;
	logic fifo_reset = 0;
	logic playing = 0;
	fifo_generator_0 fifo(.clk(clk_100mhz), .srst(reset||fifo_reset), .din(data_request_result), .wr_en(data_ready_strobe), .prog_empty(fifo_empty), .dout(fifo_out), .rd_en( sample_trigger ));
	assign data_request_flag = (!fifo_full) && (data_request_offset[8:0]==9'b0); 
	//always request data while fifo is not full, and when request offset is multiple of 512


	logic [25:0] sample_counter;


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
			audio <= 0;
		end else begin
			if (playing) begin
				audio <= fifo_out;//read from fifo
			end else
				audio <= 0;
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
module volume_control (input [2:0] vol_in, input [7:0] signal_in, output logic [7:0] signal_out);
    logic [2:0] shift;
    assign shift = 3'd7 - vol_in;
    assign signal_out = signal_in>>>shift;
endmodule

//PWM generator for audio generation!
module pwm (input clk_in, input rst_in, input [7:0] level_in, output logic pwm_out);
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