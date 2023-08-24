/************************************************************************************************************/
// Inputs:
//    keys -> Input keys to be used for the scyncroniser [9:2] are used for syncronyser toggle between notes, 1 is used for syncroniser_on and 0 is used for pause/play
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//
// Outputs:
//    note_sustain -> Outputted value of note to be played. Delayed so that it lasts more than one clock cycle
/*************************************************************************************************************/

module sequencer (input logic [10:0]keys, input logic clk, n_rst, output logic [3:0]note_sustain, output logic sequencer_on, output logic [7:0]to_led);

    logic play, beat_pulse, tempo_button;
    logic [7:0] toggle, button_press;
    logic [3:0] beat;
    logic [3:0]note_sus1, note_sus2, note_sus3, note_sus4, note_sus5, note_sus6, note_sus7, note_sus8;
    logic [21:0] tempo;

    sequencer_encoder encode (.keys(keys), .clk(clk), .n_rst(n_rst), .toggle(toggle), .sequencer_on(sequencer_on), .play(play), .tempo_button(tempo_button), .button_press(button_press));
    tempo_select tempo_select (.tempo_button(tempo_button), .clk(clk), .n_rst(n_rst), .tempo(tempo));
    sequencer_clk_div clk_div (.sequencer_on(sequencer_on), .clk(clk), .n_rst(n_rst), .beat_pulse(beat_pulse), .tempo(tempo));
    measure_counter measure_counter (.play(play), .beat_pulse(beat_pulse), .clk(clk), .n_rst(n_rst), .beat(beat));
    beat_to_led_dec dec (.beat(beat), .to_led(to_led), .sequencer_on(sequencer_on));
    sequencer_player #(.PLAY_ON(0)) player_1
                         (.toggle(toggle[0]), 
                          .beat(beat), 
                          .button_press(button_press[0]),
                          .sequencer_on(sequencer_on), .clk(clk), .n_rst(n_rst),
                          .note_sustain(note_sus1));
    sequencer_player #(.PLAY_ON(2)) player_2
                         (.toggle(toggle[1]), 
                          .beat(beat), 
                          .button_press(button_press[1]),
                          .sequencer_on(sequencer_on), .clk(clk), .n_rst(n_rst),
                          .note_sustain(note_sus2));
    sequencer_player #(.PLAY_ON(4)) player_3
                         (.toggle(toggle[2]), 
                          .beat(beat),
                          .button_press(button_press[2]), 
                          .sequencer_on(sequencer_on), .clk(clk), .n_rst(n_rst),
                          .note_sustain(note_sus3));
    sequencer_player #(.PLAY_ON(6)) player_4
                         (.toggle(toggle[3]), 
                          .beat(beat), 
                          .button_press(button_press[3]),
                          .sequencer_on(sequencer_on), .clk(clk), .n_rst(n_rst),
                          .note_sustain(note_sus4));
    sequencer_player #(.PLAY_ON(8)) player_5
                         (.toggle(toggle[4]), 
                          .beat(beat), 
                          .button_press(button_press[4]),
                          .sequencer_on(sequencer_on), .clk(clk), .n_rst(n_rst),
                          .note_sustain(note_sus5));
    sequencer_player #(.PLAY_ON(10)) player_6
                         (.toggle(toggle[5]), 
                          .beat(beat), 
                          .button_press(button_press[5]),
                          .sequencer_on(sequencer_on), .clk(clk), .n_rst(n_rst),
                          .note_sustain(note_sus6));
    sequencer_player #(.PLAY_ON(12)) player_7
                         (.toggle(toggle[6]), 
                          .beat(beat), 
                          .button_press(button_press[6]),
                          .sequencer_on(sequencer_on), .clk(clk), .n_rst(n_rst),
                          .note_sustain(note_sus7));
    sequencer_player #(.PLAY_ON(14)) player_8
                         (.toggle(toggle[7]), 
                          .beat(beat),
                          .button_press(button_press[7]),
                          .sequencer_on(sequencer_on), .clk(clk), .n_rst(n_rst),
                          .note_sustain(note_sus8));


    always_comb begin
        if(|note_sus1 && (play || button_press[0]))
        note_sustain = note_sus1;
        else if(|note_sus2 && (play || button_press[1]))
        note_sustain = note_sus2;
        else if(|note_sus3 && (play || |button_press[2]))
        note_sustain = note_sus3;
        else if(|note_sus4 && (play || |button_press[3]))
        note_sustain = note_sus4;
        else if(|note_sus5 && (play || |button_press[4]))
        note_sustain = note_sus5;
        else if(|note_sus6 && (play || |button_press[5]))
        note_sustain = note_sus6;
        else if(|note_sus7 && (play || |button_press[6]))
        note_sustain = note_sus7;
        else if(|note_sus8 && (play || |button_press[7]))
        note_sustain = note_sus8;
        else
        note_sustain = 0;
    end



endmodule