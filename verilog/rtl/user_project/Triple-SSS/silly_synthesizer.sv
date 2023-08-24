`default_nettype none
module silly_synthesizer (
    // HW
    input logic clk, nrst,
    
    // Wrapper
    input logic cs, // Chip Select (Active Low)
    //inout logic [33:0] gpio // Breakout Board Pins
    input logic [16:0] gpio,
    output logic pwm
);

logic [17:0] divider;
logic [16:0] keypad;
logic [12:0] keys;
logic [1:0] mode;
logic strobe, pwm_output, octave_key_up, octave_key_down, mode_key, goof_key;

// Inputs
assign octave_key_up = gpio[15];
assign octave_key_down = gpio[14];
assign mode_key = gpio[13];
assign goof_key = gpio[16];
assign keys = gpio[12:0];
assign keypad = cs ? 17'b0 : {octave_key_up, octave_key_down, mode_key, goof_key, keys};

// Output
assign /*gpio[33]*/ pwm = cs ? 1'b0 : pwm_output;

input_driver inputs (clk, nrst, keypad, divider, mode, strobe);
sound_driver outputs (clk, nrst, divider, mode, strobe, pwm_output);

endmodule