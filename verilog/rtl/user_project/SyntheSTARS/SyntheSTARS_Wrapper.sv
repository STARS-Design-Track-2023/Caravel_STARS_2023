module SyntheSTARS_Wrapper (
    input logic clk, nrst,
    
    // Wrapper
    input logic ncs, // Chip Select (Active Low)
    input logic [33:0] gpio_in, // Breakout Board Pins
    output logic [33:0] gpio_out, // Breakout Board Pins
    output logic [33:0] gpio_oeb // Active Low Output Enable
);

    Synthia DESIGN (
        .clk(clk),
        .reset(nrst),
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
