module MatrixMonSTARS_Wrapper (

    input logic clk, nrst,
    
    // Wrapper
    input logic ncs, // Chip Select (Active Low)
    input logic [33:0] gpio_in, // Breakout Board Pins
    output logic [33:0] gpio_out, // Breakout Board Pins
    output logic [33:0] gpio_oeb // Active Low Output Enable
);

    calculator DESIGN (
        .clk(clk),
        .nrst(nrst),
        .pb(gpio_in[9:0]),
        .ss(gpio_out[23:10]),
        .red(gpio_out[24]),
        .blue(gpio_out[25])
    );

    // assign gpio_oeb outputs
    assign gpio_oeb = {{8{1'b1}}, {16{1'b0}}, {10{1'b1}}};

    // assign 0s to unused gpio_out pins
    assign {gpio_out[33:26], gpio_out[9:0]} = {18{1'b0}};

endmodule
