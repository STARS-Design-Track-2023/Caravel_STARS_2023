`default_nettype none
module reset_router (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    input clk,
    input n_rst,
    input [12:1] designs_cs,
    output wire [12:1] designs_n_rst
);

    wire [12:1] cs_n_rst;

    assign cs_n_rst[1] = n_rst & ~designs_cs[1];
    async_reset_sync designs_sync_rst_1 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[1]),
        .n_rst(designs_n_rst[1])
    );

    assign cs_n_rst[2] = n_rst & ~designs_cs[2];
    async_reset_sync designs_sync_rst_2 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[2]),
        .n_rst(designs_n_rst[2])
    );

    assign cs_n_rst[3] = n_rst & ~designs_cs[3];
    async_reset_sync designs_sync_rst_3 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[3]),
        .n_rst(designs_n_rst[3])
    );

    assign cs_n_rst[4] = n_rst & ~designs_cs[4];
    async_reset_sync designs_sync_rst_4 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[4]),
        .n_rst(designs_n_rst[4])
    );

    assign cs_n_rst[5] = n_rst & ~designs_cs[5];
    async_reset_sync designs_sync_rst_5 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[5]),
        .n_rst(designs_n_rst[5])
    );

    assign cs_n_rst[6] = n_rst & ~designs_cs[6];
    async_reset_sync designs_sync_rst_6 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[6]),
        .n_rst(designs_n_rst[6])
    );

    assign cs_n_rst[7] = n_rst & ~designs_cs[7];
    async_reset_sync designs_sync_rst_7 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[7]),
        .n_rst(designs_n_rst[7])
    );

    assign cs_n_rst[8] = n_rst & ~designs_cs[8];
    async_reset_sync designs_sync_rst_8 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[8]),
        .n_rst(designs_n_rst[8])
    );

    assign cs_n_rst[9] = n_rst & ~designs_cs[9];
    async_reset_sync designs_sync_rst_9 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[9]),
        .n_rst(designs_n_rst[9])
    );

    assign cs_n_rst[10] = n_rst & ~designs_cs[10];
    async_reset_sync designs_sync_rst_10 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[10]),
        .n_rst(designs_n_rst[10])
    );

    assign cs_n_rst[11] = n_rst & ~designs_cs[11];
    async_reset_sync designs_sync_rst_11 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[11]),
        .n_rst(designs_n_rst[11])
    );

    assign cs_n_rst[12] = n_rst & ~designs_cs[12];
    async_reset_sync designs_sync_rst_12 (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif
        .clk,
        .asyncrst_n(cs_n_rst[12]),
        .n_rst(designs_n_rst[12])
    );

    // genvar i;
    // generate
    //     for (i = 1; i <= 12; i = i + 1) begin
    //         assign cs_n_rst[i] = n_rst & ~designs_cs[i];
    //         async_reset_sync designs_sync_rst (
    //             .clk,
    //             .asyncrst_n(cs_n_rst[i]),
    //             .n_rst(designs_n_rst[i])
    //         );
    //     end
    // endgenerate

endmodule

// Async assert, sync deassert nrst
module async_reset_sync (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    input clk,
    input asyncrst_n,
    output reg n_rst
);
    reg rff;
    wire next_n_rst;
    assign next_n_rst = rff;

    always @ (posedge clk or negedge asyncrst_n) begin
        if(!asyncrst_n) begin
            n_rst <= 1'b0;
            rff <= 1'b0;
        end 
        else begin
            n_rst <= next_n_rst;
            rff <= asyncrst_n;
        end
    end
endmodule

