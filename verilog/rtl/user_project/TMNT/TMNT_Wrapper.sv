module TMNT_Wrapper (

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

    top_asic DUT
    (
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif
        .clk(clk),
        .reset(n_rst),
        .sigout(gpio_out[15]),
        .mode_out(gpio_out[17:16]),
        .pb(gpio_in[14:0])
    );

    assign gpio_out[14:0] = 'b0;
    assign gpio_out[33:18] = 'b0;
    
    assign gpio_oeb[14:0] = 'b1;
    assign gpio_oeb[17:15] = 'b0;
    assign gpio_oeb[33:18] = 'b1;

    
endmodule
