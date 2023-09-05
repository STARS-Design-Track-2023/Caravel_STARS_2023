module Geriatrics_Wrapper (

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

    wire memory_wr;
    wire [7:0] programmable_gpio_wr;
    // unused signals
    wire [15:0] keypad_input;  // CHECK
    wire [7:0] ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0;

    // DESIGN
    z23 DESIGN (
        .clk(clk),
        .nrst(n_rst),
        .memory_data_in(gpio_in[23:16]),
        .programmable_gpio_in(gpio_in[33:26]),
        .interrupt_gpio_in(gpio_in[25]),
        .keypad_input(16'b0),  // CHECK
        .memory_address_out(gpio_out[15:0]),
        .memory_data_out(gpio_out[23:16]),
        .programmable_gpio_out(gpio_out[33:26]),
        .memory_wr(memory_wr),
        .programmable_gpio_wr(programmable_gpio_wr),
        .ss7, .ss6, .ss5, .ss4,
        .ss3, .ss2, .ss1, .ss0
    );

    assign gpio_out[24] = memory_wr;

    // assign gpio_oeb outputs
    assign gpio_oeb = {{~programmable_gpio_wr}, {1{1'b1}}, {1{1'b0}}, {8{~memory_wr}}, {16{1'b0}}};

    // assign 0s to unused gpio_out pins
    assign gpio_out[25] = 1'b0;

endmodule
