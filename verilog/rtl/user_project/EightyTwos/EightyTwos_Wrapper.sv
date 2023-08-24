module EightyTwos_Wrapper (
    input logic clk, nrst,
    
    // Wrapper
    input logic ncs, // Chip Select (Active Low)
    input logic [33:0] gpio_in, // Breakout Board Pins
    output logic [33:0] gpio_out, // Breakout Board Pins
    output logic [33:0] gpio_oeb // Active Low Output Enable
);

    logic store_en;

    Eighty_Twos DESIGN (
        .clk(clk),
        .nrst(nrst),
        .cs(ncs),
        .gpi(gpio_in),  // CHECK gpi[23] function
        .gpo(gpio_out),
        .store_en(store_en)
    );

    // assign gpio_oeb outputs
    assign gpio_oeb = {{26{1'b0}}, {8{~store_en}}};

endmodule
