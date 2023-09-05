module SyntheSTARS_Wrapper (

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

    Synthia DESIGN (
        .clk(clk),
        .reset(n_rst),
        .pb(gpio_in[12:0]),
        .modes(gpio_in[13]),
        .octaves(gpio_in[14]),
        .PWM_o(gpio_out[15])
    );

    // assign gpio_oeb outputs
    assign gpio_oeb = {{18{1'b1}}, {1{1'b0}}, {15{1'b1}}};

    // assign 0s to unused gpio_out
    assign {gpio_out[33:16], gpio_out[14:0]} = {33{1'b0}};

endmodule
