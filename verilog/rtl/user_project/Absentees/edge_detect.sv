module edge_detect (
    input logic async_in, clk, nrst,
    output logic pos_edge
);

    logic intermediate, edge_d, sync;

    always_ff @(posedge clk, negedge nrst) begin : blockName
        if(!nrst) begin

            intermediate <= 0;
            sync <= 0;
            edge_d <= 0;

        end else begin

            intermediate <= async_in;
            sync <= intermediate;
            edge_d <= sync;

        end
    end

    assign pos_edge = ~(edge_d) & sync;

endmodule