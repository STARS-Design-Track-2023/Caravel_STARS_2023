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
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif
        .clk(clk),
        .nrst(n_rst),
        .cs(~ncs),
        .gpi(gpio_in),
        .gpo(gpio_out),
        .store_en(store_en)
    );

    // assign gpio_oeb outputs
    assign gpio_oeb = {{10{1'b0}}, {1'b1}, {15{1'b0}}, {8{~store_en}}};  // gpi[23] is needed as input

endmodule
