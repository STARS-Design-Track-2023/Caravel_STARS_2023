/************************************************************************************************************/
// Inputs:
//    clk -> 10MHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//    tempo_button -> Pulse signal to determine to change tempos
//    beat_pulse -> A pulse which delays the system clock signal down to the desired tempo of the sequencer, tells measure_counter when to count
//
// Outputs:
//    tempo -> 23 bit value which determines the rate at which the measure counter counts
/*************************************************************************************************************/

module tempo_select (input logic tempo_button, clk, n_rst, output logic [21:0]tempo);

    logic [21:0]next_tempo;
    parameter BPM120 = 22'd2499999;
    parameter BPM240 = 22'd1249999;
    parameter BPM480 = 22'd624999;
    parameter BPM320 = 22'd937499;

    logic [1:0]state, next_state;

    always_ff @(posedge clk, negedge n_rst) begin
        if(n_rst)
        state <= next_state;
        else
        state <= 0;
    end

    always_comb begin

        case(state)
        2'd0: begin next_state = tempo_button ? 2'd1 : 2'd0; tempo = BPM240; end
        2'd1: begin next_state = tempo_button ? 2'd2 : 2'd1; tempo = BPM320; end
        2'd2: begin next_state = tempo_button ? 2'd3 : 2'd2; tempo = BPM480; end
        2'd3: begin next_state = tempo_button ? 2'd0 : 2'd3; tempo = BPM120; end
        default: begin next_state = 2'd0; tempo = BPM240; end
        endcase 

    end

endmodule