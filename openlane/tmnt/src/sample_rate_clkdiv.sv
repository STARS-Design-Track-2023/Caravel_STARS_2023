`default_nettype none



module sample_rate_clkdiv(
    //inputs
    input logic clk,                   // clock
    input logic n_rst,                 // active high reset
    //outputs
    output logic sample_now            // sample now
    );

//internal signals
    clkdiv #(
        .BITLEN(8)
    ) clkDiv_inst (
        .clk(clk),
        .n_rst(n_rst),
        .lim(8'd255),
        .hzX(sample_now),
        .cnt_out()
    ); 

endmodule

