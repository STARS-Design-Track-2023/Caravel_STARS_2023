/************************************************************************************************************/
// Inputs:
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//    play -> A play/pause signal which when 1 allows the measure counter to continue counting through measures and when 0 pauses the sequencer
//    beat_pulse -> A pulse which delays the system clock signal down to the desired tempo of the sequencer, tells measure_counter when to count
//
// Outputs:
//    beat -> current beat the sycnroniser is on (0-7)
/*************************************************************************************************************/
module measure_counter (input logic play, beat_pulse, clk, n_rst, output logic [3:0]beat);

    logic [3:0]next_beat;

    always_ff @(posedge clk, negedge n_rst) begin
        if(n_rst)
        beat <= next_beat;
        else
        beat <= 0;
    end

    always_comb begin
        if(beat_pulse & play) begin
            if(beat == 15)
            next_beat = 0;
            else
            next_beat = beat + 1;
        end
        else
        next_beat = beat;

    end

endmodule