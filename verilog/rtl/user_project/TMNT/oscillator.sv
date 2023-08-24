
module oscillator (
    input logic clk,                    // clock input
    input logic n_rst,                  // reset input active low
    //input [15:0] freq_div_table [0:11], // frequency division table
    input logic [17:0] freq_in,         // input frequency
    //output [15:0] counts [0:11]         // output counts
    output logic [17:0] count_out
 
    );

    //instances of clkdiv
    clkdiv #(
        .BITLEN(18)
    ) clkdiv_C (
        .clk(clk),
        .n_rst(n_rst),
        .lim(freq_in),
        .cnt_out(count_out),
        .hzX()
    );

endmodule
