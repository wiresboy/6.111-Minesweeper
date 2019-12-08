module timer(clock, start_timer, count_out, reset, stop_timer);
 //lab 3 low frequency timer.
    input clock, start_timer, stop_timer, reset; //clock is system 65 MHz clock, start_timer is input from FSM

    output logic [15:0] count_out=0;
    logic counting=0; 
    logic one_hz;

    logic[25:0] internal_count=0; //25 MHz -> 1 Hz converter
   
	always_ff @(posedge clock)begin
		if(reset) begin
            counting <= 0;
            count_out <= 0;
            internal_count <= 0;
        end
        
        if(start_timer) begin 
			counting <= 1'b1;
			internal_count <= 0;
			count_out <= 0;
		end
		if(stop_timer) begin
			counting <= 1'b0;
		end
        
        if(one_hz) begin //One second has passed
            if(counting) begin
                count_out<= count_out + 1; 
            end
            one_hz <= 0; //make one_hz one cycle long
        end  
    
        if(internal_count==4) begin //Simulation clock
        //if(internal_count == 65_000_000) begin //After 65e6 cycles, give a 1Hz pulse
            one_hz <= 1'b1;
            internal_count<=1'b0; //Restart internal counter
        end else begin
            internal_count<=internal_count+1'b1;
        end
    end  
endmodule
