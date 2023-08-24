/************************************************************************************************************/
// Inputs:
//    num_signals -> Value depicting number of keys currently pressed
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
`default_nettype none
module new_waveform_comb (input logic [2:0]num_signals, input logic done, input logic clk, n_rst, seq_on, input logic [8:0]sample1, sample2, sample3, sample4, output logic ready, output logic [8:0] comb_waveform);

    logic [10:0] new_sample1, new_sample2, new_sample3, new_sample4, sum;
    logic [10:0] inter_waveform; // Creating new varibales with one extra bit to handle overflow when adding

    logic [8:0] comb_waveform_i;
    logic ready_i;

    // Inter_waveform is just an intermediate value for the waveform which stores it in 9 bits instead of 8, the final waveform takes the last 8 of it

    assign new_sample1 = {2'b0, sample1}; // Appending one zero on the most significant bit of input numbers to aviod bit length issues
    assign new_sample2 = {2'b0, sample2}; // Appending one zero on the most significant bit of input numbers to aviod bit length issues
    assign new_sample3 = {2'b0, sample3}; 
    assign new_sample4 = {2'b0, sample4}; 
    //assign comb_waveform = inter_waveform[8:0]; // Seting output waveform to last 8 bits of the extended 9 bit intermediate waveform

    assign sum = new_sample1 + new_sample2 + new_sample3 + new_sample4;
    seqdiv_comb u1 (.sample_part(sum), .voice(num_signals), .sample(done), .clk(clk), .RST(n_rst), .sample_comb(comb_waveform_i), .done(ready_i));
    always_comb begin
        if(seq_on || num_signals == 3'b0) begin
            comb_waveform = sample1;
            ready = done;
        end
        else
            comb_waveform = comb_waveform_i;
            ready = ready_i;
    end

endmodule