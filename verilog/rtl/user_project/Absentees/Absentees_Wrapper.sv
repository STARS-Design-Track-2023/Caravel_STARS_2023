module Absentees_Wrapper (
    input logic clk, nrst,
    
    // Wrapper
    input logic ncs, // Chip Select (Active Low)
    input logic [33:0] gpio_in, // Breakout Board Pins
    output logic [33:0] gpio_out, // Breakout Board Pins
    output logic [33:0] gpio_oeb // Active Low Output Enable
);

    stopwatch DESIGN (
        .clk(clk),
        .nrst(nrst),
        .pb_0(gpio_in[0]),
        .pb_1(gpio_in[1]),
        .out_0(gpio_out[8:2]),
        .out_1(gpio_out[15:9]),
        .out_2(gpio_out[22:16]),
        .out_3(gpio_out[29:23]),
        .time_done(gpio_out[30])
    );

    // assign gpio_oeb outputs
    assign gpio_oeb = {{3{1'b1}}, {29{1'b0}}, {2{1'b1}}};

    // assign 0s to unused gpio_out pins
    assign {gpio_out[33:31], gpio_out[1:0]} = {5{1'b0}};

endmodule
