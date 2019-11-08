

module sound_effect_player
	(
		input clk_100mhz,
		input [2:0] sound_effect_select,	//indices and meanings TBD
		input sound_effect_start,			//start the selected sound effect. Strobe for only 1 clock.
		input [2:0] vol_in,
		output logic aud_pwm,
		output logic aud_sd
	);
	parameter SAMPLE_COUNT = 2082;//gets approximately (will generate audio at approx 48 kHz sample rate.

	logic [15:0] sample_counter;
	logic sample_trigger;

	logic [7:0] audio;

	assign sample_trigger = (sample_counter == SAMPLE_COUNT);
	always_ff @(posedge clk_100mhz) begin
		if (sample_counter == SAMPLE_COUNT)
			sample_counter <= 0;
		else
			sample_counter <= sample_counter + 1;
	end


	volume_control vc (.vol_in(sw[15:13]),
					.signal_in(audio), .signal_out(vol_out));
	pwm (.clk_in(clk_100mhz), .rst_in(btnd), .level_in({~vol_out[7],vol_out[6:0]}), .pwm_out(pwm_val));
	assign aud_pwm = pwm_val?1'bZ:1'b0;
	assign aud_sd = 1;

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