`default_nettype none

module completion_control(
    input logic clk, nrst,
    input logic enable,
    input logic [3:0] max,
    output logic cmp
);
    logic [3:0] count, next_count;
    logic enable_edge_detector_rising_edge;

    edge_detector enable_edge_detector(
        .clk(clk),
        .nrst(nrst),
        .data_in(enable),
        .rising_edge(enable_edge_detector_rising_edge),
        .held()
    );

    always_ff @(posedge clk, negedge nrst) begin
        if (!nrst) begin
            count <= max;
        end else begin
            count <= next_count;
        end
    end

    always_comb begin
        if (enable) begin //completion control counter
            if (enable_edge_detector_rising_edge) begin
                next_count = max;
                cmp = 0;
            end else begin
                if (count >= 1) begin
                    next_count = count - 1;
                    cmp = 0;
                end else begin
                    cmp = 1;
                    next_count = max;
                end
            end
        end else begin
            next_count = count;
            cmp = 0;
        end
    end
endmodule
