`default_nettype none

module input_handler(
    input logic clk, nrst,
    input logic [15:0] in,
    output logic [15:0] in_sync,
    output logic int_fire
);
    logic [15:0] input_rising_edge, input_held;
    edge_detector #(.WIDTH(16)) ih(
        .clk(clk),
        .nrst(nrst),
        .data_in(in),
        .rising_edge(input_rising_edge),
        .held(input_held)
    );
    edge_detector int_f(
        .clk(clk),
        .nrst(nrst),
        .data_in(|input_rising_edge),
        .rising_edge(int_fire),
        .held()
    );

    assign in_sync = in;
endmodule
