/************************************************************************

IF YOU ARE PART OF MY GROUP, THERE IS NOTHING BELOW THIS COMMENT BLOCK :)

    - Spencer B

************************************************************************/

module ref_top (
    input wire clk, nrst, spi_clk, spi_en,
    input wire spi_data,
    output reg valid_out,
    output wire is_mandelbrot,
    output wire [23:0] color 
);

    wire spi_valid_data, mandelbrot_valid_output, next_valid_output;
    wire [7:0] iterations;
    wire [`SPI_MESSAGE_WIDTH * `SPI_MESSAGE_DEPTH - 1:0] spi_data_out;

    ref_spi #(
        .DATA_WIDTH(`SPI_MESSAGE_WIDTH),
        .DATA_DEPTH(`SPI_MESSAGE_DEPTH)
    ) input_spi (
        .clk(clk), .nrst(nrst),
        .spi_clk(spi_clk),
        .spi_en(spi_en),
        .spi_data(spi_data),
        .valid_data(spi_valid_data),
        .data_out(spi_data_out)
    );

    ref_mandelbrotetron #(
        .FIXED_POINT_WIDTH(`SPI_MESSAGE_DEPTH),
        .MAX_ITER(`MANDELBROT_MAX_ITERATIONS)
    ) mandelbrot (
        .clk(clk), .nrst(nrst),
        .start(spi_valid_data), 
        .c_real_in(spi_data_out[2*`SPI_MESSAGE_DEPTH-1:`SPI_MESSAGE_DEPTH]), 
        .c_imaginary_in(spi_data_out[`SPI_MESSAGE_DEPTH-1:0]),
        .valid(mandelbrot_valid_output),
        .is_mandelbrot(is_mandelbrot),
        .iterations(iterations) 
    );

    ref_color_converter color_module (
        .iteration(iterations),
        .ismandelbrot(is_mandelbrot),
        .RGB(color)
    );

    always @(posedge clk, negedge nrst) begin
        if (~nrst)
            valid_out <= 0;
        else
            valid_out <= next_valid_output;
    end

    assign next_valid_output = mandelbrot_valid_output && ~spi_valid_data;

endmodule

module ref_color_converter(
    input wire [7:0] iteration, 
    input wire ismandelbrot, 
    output wire [23:0] RGB
);

    reg [7:0] R, G, B;

    always @(*) begin 
        if (ismandelbrot) begin
            R = 0;
            G = 0;
            B = 0;
        end
        else begin
            R = iteration;
            G = iteration;
            B = iteration;
        end
    end

    assign RGB = {R, G, B};

endmodule

/*

Blue - gray - yellow
R = iteration;
G = (iteration < 128) ? ~iteration : iteration; 
B = ~iteration;

Blue - green - red
R = iteration >= 128 ? iteration << 1 : 0;
G = (iteration >= 128 && iteration <  192) ? ~(iteration << 2) : 
    (iteration <  128 && iteration >  64)  ?  (iteration << 2) : 0;
B = iteration < 128 ? ~(iteration << 1) : 0; 

Black - white stripes
R = ^(iteration[3:2]) ? 0 : 8'hFF;
G = ^(iteration[3:2]) ? 0 : 8'hFF;
B = ^(iteration[3:2]) ? 0 : 8'hFF;

Vaporwave (orange)
R = (iteration < 128) ? ~iteration : (iteration > 128) ? 8'h80 + (iteration << 1 >> 1) : 8'h80;
G = (iteration < 128) ? iteration : 8'h80;
B = (iteration < 128) ? 8'hFF : 255 - (iteration << 1);

Vaporwave (yellow)
R = (iteration < 128) ? ~iteration : (iteration > 128) ? 8'h80 + (iteration << 1 >> 1) : 8'h80;
G = (iteration < 128) ? iteration : (iteration > 192) ? 8'h80 + (iteration << 2 >> 1) : 8'h80;
B = (iteration < 128) ? 8'hFF : 255 - (iteration << 1);

// R = (iteration < 128) ? ~iteration : (iteration > 128) ? 8'h80 + (iteration << 1 >> 1) : 8'h80;
// G = (iteration < 128) ? iteration : (iteration > 192) ? 8'h80 + (iteration << 2 >> 2) + (iteration << 2 >> 3) : 8'h80;
// B = (iteration < 128) ? 8'hFF : 255 - (iteration << 1);

*/

module ref_mandelbrotetron #(
    parameter FIXED_POINT_WIDTH = 16,
    parameter MAX_ITER = 256
) (
    input wire clk, nrst, start, 
    input wire signed [FIXED_POINT_WIDTH-1:0] c_real_in, c_imaginary_in,
    output reg valid,
    output wire is_mandelbrot,
    output wire [$clog2(MAX_ITER)-1:0] iterations 
);

    wire stop;
    assign stop = max_iter_reached | ~is_mandelbrot;

    //////////////////////////////
    // MANDELBROT-IFICATION!!!! //
    //////////////////////////////

    reg signed [FIXED_POINT_WIDTH-1:0] c_real, c_imaginary, z_real, z_imaginary;
    reg signed [FIXED_POINT_WIDTH-1:0] next_c_real, next_c_imaginary, next_z_real, next_z_imaginary;
    wire signed [FIXED_POINT_WIDTH-1:0] computed_z_real, computed_z_imaginary;

    always @(posedge clk, negedge nrst) begin
        if (~nrst) begin
            c_real <= 0;
            c_imaginary <= 0; 
            z_real <= 0; 
            z_imaginary <= 0;
        end
        else begin
            c_real <= next_c_real;
            c_imaginary <= next_c_imaginary; 
            z_real <= next_z_real; 
            z_imaginary <= next_z_imaginary;
        end
    end

    always @(*) begin
        if (start) begin
            next_c_real = c_real_in;
            next_c_imaginary = c_imaginary_in;
            next_z_real = 0;
            next_z_imaginary = 0;
        end
        else if (~stop) begin
            next_c_real = c_real;
            next_c_imaginary = c_imaginary;
            next_z_real = computed_z_real;
            next_z_imaginary = computed_z_imaginary;
        end
        else begin
            next_c_real = c_real;
            next_c_imaginary = c_imaginary;
            next_z_real = z_real;
            next_z_imaginary = z_imaginary;
        end
    end

    ref_new_z #(
        .FIXED_POINT_WIDTH(FIXED_POINT_WIDTH)
    ) z_function (
        .z_real(z_real),
        .z_imaginary(z_imaginary),
        .c_real(c_real),
        .c_imaginary(c_imaginary),
        .new_z_real(computed_z_real),
        .new_z_imaginary(computed_z_imaginary),
        .is_mandelbrot(is_mandelbrot)
    );

    ///////////////////////
    // ITERATION COUNTER //
    ///////////////////////

    wire max_iter_reached;

    ref_counter #(
        .N($clog2(MAX_ITER))
    ) iteration_counter (
        .clk(clk), .nrst(nrst),
        .clear(start),
        .wrap(1'b0),
        .en(~stop),
        .max(MAX_ITER[$clog2(MAX_ITER)-1:0]),
        .count(iterations),
        .at_max(max_iter_reached)
    );

    /////////////////////////
    // MANDELBROT DETECTOR //
    /////////////////////////

    // Sees wether the 2^1 bit on either input is high (edit: two's compliment)
    // Now is part of new_z

    /////////////////////////////////////
    // Start and valid signal handling //
    /////////////////////////////////////

    wire next_valid;

    always @(posedge clk, negedge nrst) begin
        if (~nrst)
            valid <= 0;
        else 
            valid <= next_valid;
    end

    assign next_valid = stop && ~start;

    //////////////
    // DEBUGGER //
    //////////////

    // always @(posedge start) begin
    //     $display("Recieved: %f %f", $itor(c_real_in) / `SCALING_FACTOR / 2, $itor(c_imaginary_in) / `SCALING_FACTOR / 2);
    //     $display("Recieved: %b %b", c_real_in, c_imaginary_in);
    // end

    // real a, b, c, d;

    // always @(negedge stop)
    //     $display("START!");
    
    // always @(posedge stop)
    //     $display("END!");

    // always @(negedge clk) begin
    //     if (~stop) begin
    //         a = $itor(z_real) / `SCALING_FACTOR;
    //         b = $itor(z_imaginary) / `SCALING_FACTOR;
    //         c = $itor(c_real) / `SCALING_FACTOR;
    //         d = $itor(c_imaginary) / `SCALING_FACTOR;
    //         if (a > 2 || a < -2)
    //             $display("%b", z_real);

    //         $display("(%.4f + %.4fi)^2 + (%.4f + %.4fi)", a, b, c, d);
    //     end
    // end

endmodule

// This module may totally not work!
// Inputs: One sign, two integral, the rest are fractional (e.g. SII.FFFF...)
module ref_new_z #(
    parameter FIXED_POINT_WIDTH = 16 
) (
    input wire signed [FIXED_POINT_WIDTH-1:0] z_real, z_imaginary, c_real, c_imaginary,
    output reg signed [FIXED_POINT_WIDTH-1:0] new_z_real, new_z_imaginary,
    output reg is_mandelbrot
);
    reg signed [2*FIXED_POINT_WIDTH-1:0] z_a, z_b, c_a, c_b;
    reg signed [2*FIXED_POINT_WIDTH-1:0] z_a2_untruncated, z_b2_untruncated;
    reg signed [2*FIXED_POINT_WIDTH-1:0] z_real_squared, z_imag_squared, zab;
    reg signed [2*FIXED_POINT_WIDTH-1:0] intermediate_real, intermediate_imag;
    reg signed [FIXED_POINT_WIDTH:0] square_sum;
    
    // z_a = {{FIXED_POINT_WIDTH{z_real[FIXED_POINT_WIDTH-1]}}, z_real};
    // z_b = {{FIXED_POINT_WIDTH{z_imaginary[FIXED_POINT_WIDTH-1]}}, z_imaginary};
    // c_a = {{FIXED_POINT_WIDTH{c_real[FIXED_POINT_WIDTH-1]}}, c_real};
    // c_b = {{FIXED_POINT_WIDTH{c_imaginary[FIXED_POINT_WIDTH-1]}}, c_imaginary};

    always @(z_real, z_imaginary, c_real, c_imaginary) begin
        z_a = {{FIXED_POINT_WIDTH{z_real[FIXED_POINT_WIDTH-1]}}, z_real};
        z_b = {{FIXED_POINT_WIDTH{z_imaginary[FIXED_POINT_WIDTH-1]}}, z_imaginary};
        c_a = {{FIXED_POINT_WIDTH{c_real[FIXED_POINT_WIDTH-1]}}, c_real};
        c_b = {{FIXED_POINT_WIDTH{c_imaginary[FIXED_POINT_WIDTH-1]}}, c_imaginary};

        z_a2_untruncated = z_a * z_a;
        z_real_squared = z_a2_untruncated >>> (FIXED_POINT_WIDTH - 4);
        // $display("%f : %f : %f, %b", $itor(z_real) / `SCALING_FACTOR, $itor(z_a) / `SCALING_FACTOR, $itor(z_real_squared) / `SCALING_FACTOR / 2, z_a2_untruncated);
        z_b2_untruncated = z_b * z_b;
        z_imag_squared = z_b2_untruncated >>> (FIXED_POINT_WIDTH - 4);
        intermediate_real = z_real_squared - z_imag_squared; 

        zab = z_a * z_b;
        intermediate_imag = zab >>> (FIXED_POINT_WIDTH - 4) <<< 1;

        new_z_real = intermediate_real[FIXED_POINT_WIDTH-1:0] + c_a;
        new_z_imaginary = intermediate_imag[FIXED_POINT_WIDTH-1:0] + c_b;

        square_sum = z_real_squared + z_imag_squared;
        // $display("Square sum: %f", $itor(square_sum) / `SCALING_FACTOR);
        is_mandelbrot = square_sum >>> (FIXED_POINT_WIDTH - 4) < 4 && !z_real_squared[FIXED_POINT_WIDTH-1] && !z_imag_squared[FIXED_POINT_WIDTH-1];
    end

endmodule

                            ////////////////
                            // SPI MODULE //
                            ////////////////

module ref_spi #(
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
    ref_syncronizer #(.DEPTH(2)) spi_clk_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_clk),
        .sync_out(spi_clk_sync)
    );

    ref_posedge_detector spi_clk_posedge_detector (
        .clk(clk), .nrst(nrst),
        .signal(spi_clk_sync),
        .posedge_detected(spi_clk_edge)
    );

    // SPI Enable Input
    ref_syncronizer #(.DEPTH(2)) spi_en_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_en),
        .sync_out(spi_en_sync)
    );

    ref_syncronizer #(.DEPTH(2)) spi_en_edge_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_en),
        .sync_out(spi_en_edge_sync)
    );

    ref_posedge_detector spi_en_posedge_detector (
        .clk(clk), .nrst(nrst),
        .signal(spi_en_edge_sync),
        .posedge_detected(spi_en_edge)
    );

    // SPI Data Input
    ref_syncronizer #(.DEPTH(2)) 
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

    ref_shift_reg #(.DEPTH(DATA_DEPTH * DATA_WIDTH)) spi_shift_reg (
        .clk(clk), .nrst(nrst),
        .en(spi_clk_edge),
        .q(spi_data_sync),
        .p_out(data_out)
    );

    /////////////////////////////////////////
    // CRAZY COUNTER CARNIVAL (I AM SANE!) //
    /////////////////////////////////////////

    wire all_data_received, next_valid_data;

    ref_counter #(.N($clog2(DATA_DEPTH*DATA_WIDTH+1))) spi_data_counter (
        .clk(clk), .nrst(nrst),
        .clear(spi_en_edge), 
        .en(spi_clk_edge),
        .wrap(1'b0),
        .max(DATA_DEPTH*DATA_WIDTH),
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

    ref_posedge_detector data_valid_pulser (
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

module ref_syncronizer #(
    parameter WIDTH = 1,
    parameter DEPTH = 2
) (
    input wire clk, nrst, 
    input wire [WIDTH-1:0] async_in,
    output wire [WIDTH-1:0] sync_out
);
    generate
        if (DEPTH == 0) begin
            assign sync_out = async_in;
        end
        else begin
            reg [DEPTH*WIDTH-1:0] internal_shift_reg;

            always @(posedge clk, negedge nrst) begin
                if (~nrst)
                    internal_shift_reg <= 0;
                else begin
                    internal_shift_reg <= {async_in, internal_shift_reg[DEPTH*WIDTH-1:WIDTH]};
                end
            end
            
            assign sync_out = internal_shift_reg[WIDTH-1:0];
        end
    endgenerate
    
endmodule

module ref_posedge_detector (
    input wire clk, nrst, 
    input wire signal,
    output wire posedge_detected
);
    reg q;

    always @(posedge clk, negedge nrst) begin
        if (~nrst)
            q <= 0;
        else
            q <= signal;
    end

    assign posedge_detected = ~q & signal;
endmodule

// Only supports 1 wide b/c yosys shits itself at 2D module i/o
module ref_shift_reg #( 
    parameter DEPTH = 24,
    parameter ENTERS_AT_LSB = 1
) (
    input wire clk, nrst, en, q,
    output reg [DEPTH-1:0] p_out
);
    
    wire [DEPTH-1:0] next_p_out, p_shifted;

    always @(posedge clk, negedge nrst) begin
        if (~nrst) 
            p_out <= 0;
        else
            p_out <= next_p_out;
    end

    assign next_p_out = en ? p_shifted : p_out;

    generate
        if (ENTERS_AT_LSB) begin
            assign p_shifted = {p_out[DEPTH-2:0], q};
        end
        else begin
            assign p_shifted = {q, p_out[DEPTH-1:1]};
        end
    endgenerate

endmodule

module ref_counter #(
    parameter N = 4
) (
    input wire clk, nrst, clear, wrap, en, 
    input wire [N-1:0] max,
    output reg [N-1:0] count,
    output wire at_max
);

    // IS REG OKAY???
    reg [N-1:0] next_count;

    always @(posedge clk, negedge nrst) begin
        if (~nrst)
            count <= 0;
        else
            count <= next_count;
    end

    always @(*) begin
        casex ({clear, en, wrap})
            3'b1xx: next_count = 0; // Clear condition
            3'b00x: next_count = count; // Unenabled condition
            3'b010: next_count = (count == max) ? count : count + 1; // Unwraped condition
            3'b011: next_count = (count == max) ? 0 : count + 1; // Wrapped condition
            default: next_count = 'bx; // "Oh shit something went wrong" condition
        endcase
    end

    assign at_max = (count == max);
    
endmodule
