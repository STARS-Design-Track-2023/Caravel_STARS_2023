module Reduced_Macro_Wrapper (

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

    reducedMacroMain DESIGN (

`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif
        .clk(clk),
        .nrst(n_rst),
        .in(gpio_in[9:0]),
        .out(gpio_out[23:10])
    );

    // assign gpio_oeb outputs
    assign gpio_oeb = {{3{1'b1}}, {29{1'b0}}, {2{1'b1}}};

    // assign 0s to unused gpio_out pins
    assign {gpio_out[33:24], gpio_out[9:0]} = {20{1'b0}};

endmodule
