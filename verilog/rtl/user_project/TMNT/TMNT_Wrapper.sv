module TMNT_Wrapper (
    input wire clk, n_rst,
    
    // Wrapper
    input wire ncs, // Chip Select (Active Low)
    input wire [33:0] gpio_in, // Breakout Board Pins
    output wire [33:0] gpio_out, // Breakout Board Pins
    output wire [33:0] gpio_oeb // Active Low Output Enable
);

    top_asic DUT
    (
        .clk(clk),
        .reset(n_rst),
        .sigout(gpio_out[15]),
        .mode_out(gpio_out[17:16]),
        .pb(gpio_in[14:0])
    );

    always @ (*) begin 
        gpio_out[14:0] = 'b0;
        gpio_out[18:33] = 'b0;
        gpio_oeb = {{34{1'b1}}};
        gpio_oeb[17:15] = 'b0;
    end
    
endmodule