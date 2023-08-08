/************************************************************************************************************/
// Inputs:
//    multi -> 1 or 0 value describing if there are multiple note buttons pressed
//    done1 -> Signal from first waveshaper signaling if the value outputted is a valid value for a waveshaper
//    done2 -> Signal from second waveshaper signaling if the value outputted is a valid value for a waveshaper
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//    sample1 -> Waveform from first waveshaper 8 bits
//    sample2 -> Waveform from second waveshaper 8 bits
//
// Outputs:
//    ready -> 1 or 0 value asserted when the output of the waveform combiner is valid and ready to be taken
//    comb_waveform -> Final combined waveform value to be outputed to pwm
/*************************************************************************************************************/

module waveform_comb (input logic multi, done1, done2, input logic [8:0]sample1, sample2, output logic ready, output logic [8:0] comb_waveform);

    logic [9:0] new_sample1, new_sample2, sum, inter_waveform; // Creating new varibales with one extra bit to handle overflow when adding

    // Inter_waveform is just an intermediate value for the waveform which stores it in 9 bits instead of 8, the final wavbeform takes the last 8 of it

    assign new_sample1 = {1'b0, sample1}; // Appending one zero on the most significant bit of input numbers to aviod bit length issues
    assign new_sample2 = {1'b0, sample2}; // Appending one zero on the most significant bit of input numbers to aviod bit length issues
    assign comb_waveform = inter_waveform[8:0]; // Seting output waveform to last 8 bits of the extended 9 bit intermediate waveform

    always_comb begin

        if(multi) begin // Executed only when multiple voices are detected
            if(done1 && done2) begin
                sum = new_sample1 + new_sample2; // Adding the two waves
                inter_waveform = (sum >> 1); // Dividing by two
                ready = 1'b1; // Setting ready signal to 1
            end
            else begin // If both signals are not yet ready all intermediate sums and waveforms are set to 0, it is not ready yet
                sum = 0;
                inter_waveform = 10'b0;
                ready = 0;    
            end
        end
        else begin // If only one voice is detected it will just pass through without being changed
            sum = new_sample1;
            inter_waveform = new_sample1;
            ready = done1;
        end
    end


endmodule