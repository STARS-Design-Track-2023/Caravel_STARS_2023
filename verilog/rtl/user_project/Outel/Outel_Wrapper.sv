module Outel_Wrapper (
    input wire clk, nrst,
    
    // Wrapper
    input wire ncs, // Chip Select (Active Low)
    input wire [33:0] gpio_in, // Breakout Board Pins
    output wire [33:0] gpio_out, // Breakout Board Pins
    output wire [33:0] gpio_oeb // Active Low Output Enable
);

    wire dataBusSelect;
    wire [25:0] gpio;

    outel8227 DESIGN (
        .clk(clk),
        .nrst(nrst),
        .cs(ncs),
        .dataBusIn(gpio_in[33:26]),
        .dataBusOut(gpio_out[33:26]),
        .dataBusSelect(dataBusSelect),  // input when low
        .gpio(gpio)
    );

    // assign internal 'gpio' pins
    assign gpio_out[15:0] = gpio[15:0];
    assign gpio[20:16] = gpio_in[20:16];
    assign gpio_out[24:21] = gpio[24:21];

    // assign gpio_oeb outputs
    assign gpio_oeb = {{8{~dataBusSelect}}, {5{1'b0}}, {5{1'b1}}, {16{1'b0}}};

    // assign 0s to unused gpio_out
    assign gpio[20:16] = 5'b0;
    assign gpio_out[25] = 1'b0;

endmodule
