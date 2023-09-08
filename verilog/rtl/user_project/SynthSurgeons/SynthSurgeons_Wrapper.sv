module SynthSurgeons_Wrapper (

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

    synth DESIGN (
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif
        .clk(clk),
        .n_rst(n_rst),
        .en(~ncs),
        .keypad_i(gpio_in[14:0]),
        .pwm_o(gpio_out[15]),
        .sound_series(gpio_out[19:16])
    );

    // assign gpio_oeb outputs
    assign gpio_oeb = {{14{1'b1}}, {5{1'b0}}, {15{1'b1}}};

    // assign 0s to unused gpio_out
    assign {gpio_out[33:20], gpio_out[14:0]} = {29{1'b0}};

endmodule
