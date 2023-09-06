`default_nettype none
module silly_synth_wrapper (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // HW
    input wire clk, n_rst,
    
    // Wrapper
    input wire ncs, // Chip Select (Active Low)
    input wire [33:0] gpio_in, // Breakout Board Pins
    output wire [33:0] gpio_out, // Breakout Board Pins
    output wire [33:0] gpio_oeb // Active Low Output Enable
);

    assign gpio_oeb = {1'b0, {33{1'b1}}};

    silly_synthesizer synth (
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif
        .clk(clk),
        // .nrst(ff2),
        .nrst(n_rst),
        .cs(ncs),
        .gpio(gpio_in[16:0]),
        .pwm(gpio_out[33])
    );

    assign gpio_out[32:0] = {33{1'b0}};

endmodule
