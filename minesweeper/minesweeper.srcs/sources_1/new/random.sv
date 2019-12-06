`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// PRNG lfsr function. Technically is deterministic, but the games will be different every time
// because the cycle that the random number is read will be determined based on when the user clicks
// a button, and there will be more than enough varience from this.
// Additional Comments:
//   https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
//////////////////////////////////////////////////////////////////////////////////


module random(
	input clk,
	input rst,
    output logic [15:0] random
    );

	logic [30:0] lfsr = 0; //internal
	//note that optimal taps for 31 bits are are 30,27.
	
	assign random = lfsr;
	
	always_ff @(posedge clk or posedge rst) begin : proc_LFSR
		if(rst) begin
			lfsr <= 31'h4606ad21; //Certified random :P
		end else begin
			lfsr <= { lfsr[0] ~^ lfsr[3], lfsr[30:1]};
		end
	end

    
    
endmodule
