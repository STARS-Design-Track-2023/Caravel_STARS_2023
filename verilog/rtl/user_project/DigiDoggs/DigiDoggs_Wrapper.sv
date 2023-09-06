module DigiDoggs_Wrapper (

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

    pushing_pixels DESIGN (
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif
        .clk(clk),
        .nrst(n_rst),
        .cs(ncs),
        .spi_clk(gpio_in[0]),
        .spi_en(gpio_in[1]),
        .spi_data(gpio_in[2]),
        .valid_out(gpio_out[3]),
        .is_mandelbrot(gpio_out[4]),
        .color(gpio_out[28:5])
    );

    // assign gpio_oeb outputs
    assign gpio_oeb = {{5{1'b1}}, {26{1'b0}}, {3{1'b1}}};

    // assign 0s to unused gpio_out pins
    assign {gpio_out[33:29], gpio_out[2:0]} = {8{1'b0}};

endmodule
