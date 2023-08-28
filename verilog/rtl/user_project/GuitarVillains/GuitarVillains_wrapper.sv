module GuitarVillains_wrapper (

    input wire clk, n_rst,
    
    // Wrapper
    input wire ncs, // Chip Select (Active Low)
    input wire [33:0] gpio_in, // Breakout Board Pins
    output wire [33:0] gpio_out, // Breakout Board Pins
    output wire [33:0] gpio_oeb // Active Low Output Enable
);

    Guitar_Villains DESIGN (
        .clk(clk),
        .n_rst(n_rst),
        .chip_select(ncs), 
        
        .button(gpio_in[3:0]),
        .top_row(gpio_out[10:4]),
        .buttom_row(gpio_out[17:11]), 
        .red_disp(gpio_out[32]),
        .green_disp(gpio_out[33]),
        .ss0(gpio_out[24:18]),
        .ss1(gpio_out[31:25])
    );

    // correctly assign gpio_oeb outputs
    assign gpio_oeb = {{30{1'b0}}, {4{1'b1}}}; 

    // assign 0s to unused gpio_output pins
    assign gpio_out[3:0] = 4'b0000; 

endmodule
