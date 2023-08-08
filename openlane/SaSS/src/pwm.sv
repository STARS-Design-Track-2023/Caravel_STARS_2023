/************************************************************************************************************/
// Inputs:
//    comb_waveform -> Final combined waveform value to be outputed to pwm
//    ready -> 1 or 0 value asserted when the output of the waveform combiner is valid and ready to be taken
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//
// Outputs:
//    pwm_o -> 1 or 0 output of pusle width modulated square wave ouputted from the pwm
/*************************************************************************************************************/


module pwm (input logic [8:0]comb_waveform, input logic clk, n_rst, ready, output logic pwm_o);

    logic [8:0]count, next_count; // Delaring local use variables, count stores current count and next_count is for flip-flop
    logic [8:0]current_waveform, next_waveform; // Declaring waveform values to be used in flip-flop storage
    logic next_pwm_o; // Declaring a flip-flop value for the output to get rid of ghost signals

    always_ff @ (posedge clk, negedge n_rst) begin
        if(n_rst) begin
            count <= next_count;
            current_waveform <= next_waveform;
        end
        else begin
            count <= 0; // Count resets to zero if reset
            current_waveform <= 9'd0;
        end
    end

    always_comb begin

        if(ready)
        next_waveform = comb_waveform;
        else 
        next_waveform = current_waveform;

        next_count = (count == 9'd255) ? 9'd0 : (count + 1); // If the count = 255 it wraps to zero, if not it adds 1

        if(count < current_waveform)
            next_pwm_o = 1; // PWM 1 when its count is less than inputted value from waveform combiner
        else
            next_pwm_o = 0; // PWM 0 when its count is greater than or equal to inputted value from waveform combiner

    end

    always_ff @(posedge clk, negedge n_rst) begin
        if(n_rst)
        pwm_o <= next_pwm_o;
        else
        pwm_o <= 0;
    end

endmodule