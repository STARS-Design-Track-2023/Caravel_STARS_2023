module input_driver (
    input logic clk, nrst,
    input logic [16:0] keypad,
    output logic [17:0] divider,
    output logic [1:0] mode,
    output logic strobe
);

logic [16:0] sync_keys;
logic [5:0] goof_index;
logic [3:0] note;
logic [2:0] octave;
logic octave_up, octave_down, mode_key, up_pulse, down_pulse, mode_pulse, goof, pulse;

synch keypad_synchronizer (clk, nrst, keypad, sync_keys);
keypad key_encoder (sync_keys, octave_up, octave_down, mode_key, goof, note, strobe);
edge_det up (clk, nrst, octave_up, up_pulse);
edge_det down (clk, nrst, octave_down, down_pulse);
edge_det mode_edge (clk, nrst, mode_key, mode_pulse);
clock_div4Hz #(2500000) random_update_clock (clk, nrst, pulse);
rng random_note_generator (clk, nrst, pulse, goof, goof_index);
octaves octave_fsm (clk, nrst, up_pulse, down_pulse, octave);
wavetype wavetype_fsm (clk, nrst, mode_pulse, mode);
freq_table frequency_lut (goof, octave, goof_index, note, divider);

endmodule