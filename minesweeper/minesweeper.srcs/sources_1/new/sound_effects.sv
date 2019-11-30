
module sound_effect_manager (
	input clk_100mhz,
	input reset,
	input [2:0] sound_effect_select,	//indices and meanings TBD
	input sound_effect_start,			//start the selected sound effect. Strobe for only 1 clock.
	output logic aud_pwm,
	output logic aud_sd);




	volume_control vc (.vol_in(sw[15:13]),
					.signal_in(audio), .signal_out(vol_out));
	pwm (.clk_in(clk_100mhz), .rst_in(btnd), .level_in({~vol_out[7],vol_out[6:0]}), .pwm_out(pwm_val));
	assign aud_pwm = pwm_val?1'bZ:1'b0;
	assign aud_sd = 1;

endmodule



module sound_effect_player#(parameter DURATION_SAMPLES = 48000, parameter LOOP = 0);
	(
		input clk_100mhz,
		input reset,
		input sound_effect_start,			//start the selected sound effect. Strobe for only 1 clock.
		input sample_trigger,

		output logic [25:0] data_request_offset, //~20 minutes of audio!
		output logic data_request_flag, //1 for next data needed
		input [7:0] data_request_result,
		input data_ready_strobe, //1 for 1 cycle indicating data is available

		output logic signed [7:0] audio
	);

	logic [15:0] sample_counter;
	logic playing = 0;

	logic [7:0] audio;

	always_ff @(posedge clk_in) begin : proc_sample_counter
		if (reset) begin
			sample_counter <= 0;
		end else begin
			if (sample_counter == DURATION_SAMPLES)
				sample_counter <= 0;
			else if (playing && sample_trigger)
				sample_counter <= sample_counter + 1;
		end
	end

	always_ff @(posedge clk_in) begin : proc_playing
		if (reset) begin
			playing <= 0;
		end else begin
			if (sound_effect_start)
				playing <= 1;
			else if (sample_counter == DURATION_SAMPLES)
				playing <= LOOP; //stop playing unless this sample loops?
		end
	end

	always_ff @(posedge clk_in) begin : proc_audio
		if (reset) begin
			audio <= 0;
		end else begin
			if (playing) begin
				audio <= 0;//todo: how to get audio value?
			end else
				audio <= 0;
		end
	end
endmodule





//Volume Control
module volume_control (input [2:0] vol_in, input signed [7:0] signal_in, output logic signed[7:0] signal_out);
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