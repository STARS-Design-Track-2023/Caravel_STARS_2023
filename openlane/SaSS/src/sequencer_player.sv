/************************************************************************************************************/
// Inputs:
//    PLAY_ON -> The beat value (0-7) on which the selected note plays
//    toggle -> edge-detected signal which cycles through note modes which the player is on
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//    beat -> current beat the sycnroniser is on, given by measure counter
//    sequencer_on -> A 1 or 0 value which denotes that the chip is in sequencer mode if 1 and piano mode if 0
//
// Outputs:
//    note_sustain -> Outputted value of note to be played. Delayed so that it lasts more than one clock cycle
/*************************************************************************************************************/

module sequencer_player #(parameter PLAY_ON = 0)
                         (input logic toggle, 
                          input logic button_press,
                          input logic [3:0]beat, 
                          input logic sequencer_on, clk, n_rst,
                          output logic [3:0]note_sustain);

    logic [3:0]state, next_state, note, next_note_sustain; // States for note values


    parameter [3:0] OFF = 4'd0;
    parameter [3:0] lowC = 4'd1;
    parameter [3:0] C_sharp = 4'd2;
    parameter [3:0] D = 4'd3;
    parameter [3:0] D_sharp = 4'd4;
    parameter [3:0] E = 4'd5;
    parameter [3:0] F = 4'd6;
    parameter [3:0] F_sharp = 4'd7;
    parameter [3:0] G = 4'd8;
    parameter [3:0] G_sharp = 4'd9;
    parameter [3:0] A = 4'd10;
    parameter [3:0] A_sharp = 4'd11;
    parameter [3:0] B = 4'd12;
    parameter [3:0] highC = 4'd13;

    always_ff @(posedge clk, negedge n_rst) begin
        if(n_rst) begin
            state <= next_state;
            //note_sustain <= next_note_sustain;
        end
        else begin
            state <= OFF;
            //note_sustain <= 0;
        end

    end

    always_comb begin
        
        if(sequencer_on) begin
            case(state)
                    OFF: next_state = toggle ? lowC : OFF;
                    lowC: next_state = toggle ? C_sharp : lowC;
                    C_sharp: next_state = toggle ? D : C_sharp;
                    D: next_state = toggle ? D_sharp : D;
                    D_sharp: next_state = toggle ? E : D_sharp;
                    E: next_state = toggle ? F : E;
                    F: next_state = toggle ? F_sharp : F;
                    F_sharp: next_state = toggle ? G : F_sharp;
                    G: next_state = toggle ? G_sharp : G;
                    G_sharp: next_state = toggle ? A : G_sharp;
                    A: next_state = toggle ? A_sharp : A;
                    A_sharp: next_state = toggle ? B : A_sharp;
                    B: next_state = toggle ? highC : B;
                    highC: next_state = toggle ? OFF : highC;
                    default: next_state = OFF;
                endcase

                note = ((PLAY_ON == beat) || button_press) ? state : 0;
        end
        else begin
            note = 0;
            next_state = OFF;
        end
    end

    assign note_sustain = note;


endmodule