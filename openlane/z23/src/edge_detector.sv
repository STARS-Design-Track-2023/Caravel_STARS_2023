module edge_detector#(parameter WIDTH=1)(
    input logic clk, nrst,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] rising_edge,
    output logic [WIDTH-1:0] held
);
    logic [WIDTH-1:0] prev_data;

    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) prev_data <= 0;
        else prev_data <= data_in;
    end

    assign rising_edge = data_in & ~prev_data;
    assign held = ~(data_in ^ prev_data);
endmodule
