`timescale 1ns / 1ps


module sound_effect_tb;

	logic reset=1;
	logic clk=0;
	
	logic sound_effect_start = 0;
	logic [25:0] data_request_offset [1:0];
	logic [1:0] data_request_flag;
	logic [7:0] audio_single [1:0];
	logic [7:0] audio;
	
	always #0.001 clk<=!clk;
	

	logic [11:0] sample_trigger_count = 0; //max 2083 - fits in 12 bits (4096)
	always_ff @(posedge clk) begin : proc_sample_trigger_count
		if (reset) begin
			sample_trigger_count <= 0;
		end else begin
			if (sample_trigger_count == 10)
				sample_trigger_count <= 0;
			else
				sample_trigger_count <= sample_trigger_count+1;
		end
	end	
	
	logic [7:0] sd_dout;
	always #0.00032423 sd_dout <= sd_dout + 1;
	
	logic sample_trigger;
	assign sample_trigger = sample_trigger_count ==0;
	assign sd_rd_strobe = sample_trigger;
	
	sound_effect_player sfx0(.clk_100mhz(clk), .reset(reset),
		.sound_effect_start(sound_effect_start/* && sound_effect_select==0*/), .sample_trigger(sample_trigger),
		.data_request_offset(data_request_offset[0]), .data_request_flag(data_request_flag[0]),
		.data_request_result(sd_dout), .data_ready_strobe(/*data_access_granted[0] && */sd_rd_strobe),
		.duration_samples(9070550),.audio(audio/*audio_single[0]*/));
	
	initial begin
		#0.01
		reset=0;
		#0.01
		sound_effect_start <= 1;
		#0.003
		sound_effect_start <= 0;
	end

endmodule