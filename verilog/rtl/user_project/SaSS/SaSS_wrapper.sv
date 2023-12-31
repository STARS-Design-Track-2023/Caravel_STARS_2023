module SaSS_wrapper (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    input wire clk, n_rst,
    
    // Wrapper
    input wire ncs, // Chip Select (Active Low)
    input wire [33:0] gpio_in, // Breakout Board Pins
    output wire [33:0] gpio_out, // Breakout Board Pins
    output wire [33:0] gpio_oeb // Active Low Output Enable
);

    wire [3:0] note1, note2, note3, note4, multi;

    sass_synth DESIGN (
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif
        .hwclk(clk),
        .n_rst(n_rst),
        .cs(ncs),

        .piano_keys(gpio_in[14:0]),
        .seq_power(gpio_in[15]),
        .tempo_select(gpio_in[16]),
        .seq_play(gpio_in[17]),

        .mode_out(gpio_out[19:18]),
        .beat_led(gpio_out[27:20]),
        .seq_led_on(gpio_out[28]),

        .pwm_o(gpio_out[29]),

        // unused
        .note1(note1),
        .note2(note2),
        .note3(note3),
        .note4(note4),
        .multi(multi)
    );

    // correctly assign gpio_oeb outputs
    assign gpio_oeb = {{4{1'b1}}, {12{1'b0}}, {18{1'b1}} }; 

    // assign 0s to unused gpio_output pins
    assign {gpio_out[33:30], gpio_out[17:0]} = {22{1'b0}}; 

endmodule
