module reset_router (
    input clk,
    input n_rst,
    input [12:1] designs_cs,
    output wire [12:1] designs_n_rst
);

    wire [12:1] cs_n_rst;

    genvar i;
    generate
        for (i = 1; i <= 12; i = i + 1) begin
            assign cs_n_rst[i] = n_rst & ~designs_cs[i];
            async_reset_sync designs_sync_rst (
                .clk,
                .asyncrst_n(cs_n_rst[i]),
                .n_rst(designs_n_rst[i])
            );
        end
    endgenerate

endmodule

// Async assert, sync deassert nrst
module async_reset_sync (
    input clk,
    input asyncrst_n,
    output reg n_rst
);
    reg rff;

    always @(posedge clk, negedge asyncrst_n) begin
        if(!asyncrst_n) begin
            {n_rst, rff} <= 2'b0;
        end else begin
            {n_rst, rff} <= {rff, 1'b1};
        end
    end
endmodule

