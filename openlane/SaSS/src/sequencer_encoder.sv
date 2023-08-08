/************************************************************************************************************/
// Inputs:
//    keys -> Input keys to be used for the scyncroniser [9:2] are used for syncronyser toggle between notes, 1 is used for syncroniser_on and 0 is used for pause/play
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//
// Outputs:
//    toggle -> Outputted edge-detected signal of each button for each beat in sycnronyser pressed
//    sequencer_on -> A 1 or 0 value which denotes that the chip is in sequencer mode if 1 and piano mode if 0
//    play -> A play/pause signal which when 1 allows the measure counter to continue counting through measures and when 0 pauses the sequencer
/*************************************************************************************************************/

module sequencer_encoder (input logic [10:0]keys, input logic clk, n_rst, output logic [7:0]toggle, button_press, output logic sequencer_on, play, tempo_button);

    // First key is used for tempo select, next 8 keys (9:2) are used for toggles 7:0, key 1 is for sequencer_on, and key 0 is for play

    logic [10:0]inter_keys, keys_sync, keys_edge_det, keys_pos_edge; // Intermiediate signal for keys in syncronyser
    logic next_play, next_sequencer_on;

// Syncroniser
  
    always_ff @(posedge clk, negedge n_rst) begin 
        if(n_rst) begin
        keys_sync <= inter_keys;
        inter_keys <= keys;
        end
        else begin
        keys_sync <= 0;
        inter_keys <= 0;
        end
    end

// Edge detector
    always_ff @(posedge clk, negedge n_rst) begin 
        if(n_rst)
        keys_edge_det <= keys_sync;
        else
        keys_edge_det <= 0;
    end

    assign keys_pos_edge = (keys_sync & ~keys_edge_det); // Edge detected key signals
    assign toggle = keys_pos_edge[9:2];
    assign tempo_button = keys_pos_edge[10];
    assign button_press = keys_sync[9:2];

// Key value sustainer
    always_ff @(posedge clk, negedge n_rst) begin 
        if(n_rst) begin
            sequencer_on <= next_sequencer_on;
            play <= next_play;
        end
        else begin
            sequencer_on <= 0;
            play <= 0;
        end
    end

    always_comb begin

        case(sequencer_on)
        0: next_sequencer_on = keys_pos_edge[1] ? 1 : 0;
        1: next_sequencer_on = keys_pos_edge[1] ? 0 : 1;
        endcase

        case(play)
        0: next_play = keys_pos_edge[0] ? 1 : 0;
        1: next_play = keys_pos_edge[0] ? 0 : 1;
        endcase
        
    end

    

endmodule