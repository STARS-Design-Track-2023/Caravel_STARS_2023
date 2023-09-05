module EightyTwos_Wrapper (

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

    wire store_en;

    Eighty_Twos DESIGN (
        .clk(clk),
        .nrst(n_rst),
        .cs(ncs),
        .gpi(gpio_in),  // CHECK gpi[23] function
        .gpo(gpio_out),
        .store_en(store_en)
    );

    // assign gpio_oeb outputs
    assign gpio_oeb = {{26{1'b0}}, {8{~store_en}}};

endmodule
