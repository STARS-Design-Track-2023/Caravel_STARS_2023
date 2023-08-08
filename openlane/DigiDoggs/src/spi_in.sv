`default_nettype none

module spi_in #(
    parameter DATA_WIDTH = 2,
    parameter DATA_DEPTH = 16
) (
    input wire clk, nrst, spi_clk, spi_en, 
    input wire spi_data, 
    output reg valid_data, // Output of edge detector, valid for 1 clock cylce
    output wire [DATA_WIDTH * DATA_DEPTH - 1:0] data_out // Valid when valid_data is high
);
    ///////////////////////////////////////
    // SYNCRONIZATION AND EDGE DETECTION //
    ///////////////////////////////////////

    wire spi_clk_sync;
    wire spi_clk_edge;
    wire spi_en_sync;
    wire spi_en_edge_sync;
    wire spi_en_edge;
    wire spi_data_sync;

    // SPI Clock Input  
    syncronizer #(.DEPTH(2)) spi_clk_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_clk),
        .sync_out(spi_clk_sync)
    );

    posedge_detector spi_clk_posedge_detector (
        .clk(clk), .nrst(nrst),
        .signal(spi_clk_sync),
        .posedge_detected(spi_clk_edge)
    );

    // SPI Enable Input
    syncronizer #(.DEPTH(2)) spi_en_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_en),
        .sync_out(spi_en_sync)
    );

    syncronizer #(.DEPTH(2)) spi_en_edge_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_en),
        .sync_out(spi_en_edge_sync)
    );

    posedge_detector spi_en_posedge_detector (
        .clk(clk), .nrst(nrst),
        .signal(spi_en_edge_sync),
        .posedge_detected(spi_en_edge)
    );

    // SPI Data Input
    syncronizer #(.DEPTH(2)) 
    spi_data_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_data),
        .sync_out(spi_data_sync)
    );

    ////////////////////////////////
    // SHIFT REGISTER SHENANIGANS //
    ////////////////////////////////

    // wire [DATA_WIDTH * DATA_DEPTH - 1:0] next_data_out;

    // always @(posedge clk, negedge nrst) begin
    //     if (~nrst)
    //         data_out <= 0;
    //     else
    //         data_out <= next_data_out; 
    // end

    shift_reg #(.DEPTH(DATA_DEPTH * DATA_WIDTH)) spi_shift_reg (
        .clk(clk), .nrst(nrst),
        .en(spi_clk_edge),
        .q(spi_data_sync),
        .p_out(data_out)
    );

    /////////////////////////////////////////
    // CRAZY COUNTER CARNIVAL (I AM SANE!) //
    /////////////////////////////////////////

    wire all_data_received, next_valid_data;

    parameter NUM_BITS = (DATA_DEPTH*DATA_WIDTH);

    counter #(.N($clog2(DATA_DEPTH*DATA_WIDTH+1))) spi_data_counter (
        .clk(clk), .nrst(nrst),
        .clear(spi_en_edge), 
        .en(spi_clk_edge),
        .wrap(1'b0),
        .max(8'd64),
        .count(),
        .at_max(all_data_received)
    );

    // wire [8:0] spi_bits;
    // always @(spi_bits) begin
    //     $display("SPI: %d", spi_bits);
    // end

    // always @(posedge all_data_received) begin
    //     $display("SPI DATA RECIEVED");
    //     // $display("Packets %b", data_out);
    //     // @(posedge clk);
    //     // @(negedge clk);
    //     // $display("Packets %b", data_out);
    // end

    posedge_detector data_valid_pulser (
        .clk(clk), .nrst(nrst),
        .signal(all_data_received),
        .posedge_detected(next_valid_data)
    );

    always @(posedge clk, negedge nrst) begin
        if (~nrst)
            valid_data <= 0;
        else
            valid_data <= next_valid_data;
    end
    
endmodule


// `include "sync.sv"
// `include "edge_detector.sv"
// `include "shift_register.sv"
// `include "counter.sv"

// module spi_in #(
//     parameter DATA_WIDTH = 2,
//     parameter DATA_DEPTH = 16
// ) (
//     input logic clk, nrst, spi_clk, spi_en, 
//     input logic spi_data, 
//     output logic valid_data, // Output of edge detector, valid for 1 clock cylce
//     output logic [DATA_WIDTH * DATA_DEPTH - 1:0] data_out // Valid when valid_data is high
// );

// logic [DATA_WIDTH * DATA_DEPTH - 1:0] next_data_out;
// logic spi_clk_sync;
// logic spi_clk_edge;
// logic spi_en_sync;
// logic spi_en_edge_sync;
// logic spi_en_edge;
// logic spi_data_sync;
// wire all_data_received;

// ///////////////////////////////////////
// // SYNCRONIZATION AND EDGE DETECTION //
// ///////////////////////////////////////

// // SPI Clock Input  
// syncronizer #(.DEPTH(2)) spi_clk_syncronizer (.clk(clk), .nrst(nrst), .async_in(spi_clk), .sync_out(spi_clk_sync));
// posedge_detector spi_clk_posedge_detector (.clk(clk), .nrst(nrst), .signal(spi_clk_sync), .posedge_detected(spi_clk_edge));

// // SPI Enable Input
// syncronizer #(.DEPTH(2)) spi_en_syncronizer (.clk(clk), .nrst(nrst), .async_in(spi_en), .sync_out(spi_en_sync));
// syncronizer #(.DEPTH(2)) spi_en_edge_syncronizer (.clk(clk), .nrst(nrst), .async_in(spi_en), .sync_out(spi_en_edge_sync));
// posedge_detector spi_en_posedge_detector (.clk(clk), .nrst(nrst), .signal(spi_en_edge_sync), .posedge_detected(spi_en_edge));

// // SPI Data Input
// syncronizer #(.DEPTH(2)) spi_data_syncronizer (.clk(clk), .nrst(nrst), .async_in(spi_data), .sync_out(spi_data_sync));

// ////////////////////////////////
// // SHIFT REGISTER SHENANIGANS //
// ////////////////////////////////

// shift_reg #(.DEPTH(DATA_DEPTH * DATA_WIDTH)) spi_shift_reg (.clk(clk), .nrst(nrst), .en(spi_clk_edge), .q(spi_data_sync), .p_out(data_out));

// /////////////////////////////////////////
// // CRAZY COUNTER CARNIVAL (I AM SANE!) //
// /////////////////////////////////////////

//     counter #(.N($clog2(DATA_DEPTH*DATA_WIDTH+1))) 
//     spi_data_counter (
//         .clk(clk), 
//         .nrst(nrst), 
//         .clear(spi_en_edge),  
//         .en(spi_clk_edge), 
//         .wrap(1'b0), 
//         .max(DATA_DEPTH*DATA_WIDTH), 
//         .count(), 
//         .at_max(all_data_received)
//     );

// posedge_detector data_valid_pulser (.clk(clk), .nrst(nrst), .signal(all_data_received), .posedge_detected(valid_data));

// endmodule
