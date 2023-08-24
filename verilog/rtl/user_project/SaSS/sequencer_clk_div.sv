/************************************************************************************************************/
// Inputs:
//    sequencer_on -> A 1 or 0 value which denotes that the chip is in sequencer mode if 1 and piano mode if 0
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//
// Outputs:
//    beat_pulse -> A pulse which delays the system clock signal down to the desired tempo of the sequencer, sends pulse to measure counter telling it when to count
/*************************************************************************************************************/

module sequencer_clk_div (input logic sequencer_on, clk, n_rst, input logic [21:0] tempo, output logic beat_pulse);

    logic [21:0]count, next_count;

    always_ff @(posedge clk, negedge n_rst) begin
        if(n_rst)
        count <= next_count;
        else
        count <= 0;
    end

    always_comb
        if(sequencer_on) begin
            if(count == tempo) begin
                beat_pulse = 1;
                next_count = 0;
            end
            else begin
                beat_pulse = 0;
                next_count = count + 1;
            end
        end
        else begin
            beat_pulse = 0;
            next_count = 0;
        end

endmodule