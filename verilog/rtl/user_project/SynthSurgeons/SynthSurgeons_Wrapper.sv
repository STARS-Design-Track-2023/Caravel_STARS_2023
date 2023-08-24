module SynthSurgeons_Wrapper (
    input logic clk, nrst,
    
    // Wrapper
    input logic ncs, // Chip Select (Active Low)
    input logic [33:0] gpio_in, // Breakout Board Pins
    output logic [33:0] gpio_out, // Breakout Board Pins
    output logic [33:0] gpio_oeb // Active Low Output Enable
);

    synth DESIGN (
        .clk(clk),
        .n_rst(nrst),
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
