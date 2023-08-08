`timescale 1ns/100ps
`define CLOCK_PERIOD 100
`define SPI_MASTER_CLOCK_PERIOD 425
`define RESET_INACTIVE 1
`define RESET_ACTIVE 0

`define SPI_MESSAGE_WIDTH 2
`define SPI_MESSAGE_DEPTH 32
`define MANDELBROT_MAX_ITERATIONS 255

module tb_top ();

    integer i;
    
    reg tb_clk, tb_nrst;
    reg tb_spi_data, tb_imaginary_in, tb_spi_clk, tb_spi_en;
    wire tb_is_mandelbrot, tb_valid_out;
    wire [23:0] tb_RGB;

    reg tb_spi_clk_active;
    reg [63:0] tb_spi_packet;
    reg [63:0] tb_spi_next_packet;

    task inputs_to_zero;
        begin
            tb_spi_data = 0;
            tb_imaginary_in = 0; 
            tb_spi_clk_active = 0;
            tb_spi_en = 0; 
        end
    endtask

    task send_packet;
        begin
            @(negedge tb_clk);

            tb_spi_packet = tb_spi_next_packet;
            tb_spi_en = 1;
            tb_spi_clk_active = 1;
            
            tb_spi_data = tb_spi_packet[0];
            for (i = 0; i < `SPI_MESSAGE_DEPTH * `SPI_MESSAGE_WIDTH; i = i + 1) begin
                @(negedge tb_spi_clk);
                tb_spi_packet = tb_spi_packet >> 1;
                tb_spi_data = tb_spi_packet[0];
                #(0.1);
            end

            tb_spi_en = 0;
            tb_spi_clk_active = 0;
        end
    endtask


    initial begin
        $dumpfile ("dump.vcd");
        $dumpvars;
    end

    
    always begin
        tb_clk = 1'b0;
        #(`CLOCK_PERIOD / 2);
        tb_clk = 1'b1;
        #(`CLOCK_PERIOD / 2);
    end

    always begin
        tb_spi_clk = 1'b0;
        #(`SPI_MASTER_CLOCK_PERIOD / 2);
        tb_spi_clk = tb_spi_clk_active;
        #(`SPI_MASTER_CLOCK_PERIOD / 2);
    end

    pushing_pixels DUT (
        .clk(tb_clk), .nrst(tb_nrst),
        .spi_clk(tb_spi_clk),
        .spi_en(tb_spi_en),
        .spi_data(tb_spi_data),
        .is_mandelbrot(tb_is_mandelbrot),
        .valid_out(tb_valid_out)
    );

    initial begin
        tb_nrst = `RESET_ACTIVE;
        #(`CLOCK_PERIOD * 1);
        inputs_to_zero();
        #(`CLOCK_PERIOD * 2);
        tb_nrst = `RESET_INACTIVE;
        #(`CLOCK_PERIOD * 10);

        // -0 + 0i
        tb_spi_next_packet = 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001;
        send_packet();

        @(posedge tb_valid_out);
        #(`CLOCK_PERIOD * 5);

        // -1 + 0.5i
        //                       FFFF FFFF FFFF FFFF FFFF FFFF FFFF FIIS FFFF FFFF FFFF FFFF FFFF FFFF FFFF FIIS
        tb_spi_next_packet = 64'b0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_1111;
        send_packet();

        @(posedge tb_valid_out);
        #(`CLOCK_PERIOD * 10);

        $finish;
    end

endmodule

/************************************************************************

IF YOU ARE PART OF MY GROUP, THERE IS NOTHING BELOW THIS COMMENT BLOCK :)

    - Spencer B

************************************************************************/

/*

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
            R = 8'b0;
            G = 8'b0;
            B = 8'b0;
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
        .new_z_imaginary(computed_z_imaginary)
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
    // assign is_mandelbrot = ~(computed_z_real >= 2 | computed_z_imaginary >= 2);
    assign is_mandelbrot = ~(computed_z_real * computed_z_real + computed_z_imaginary * computed_z_imaginary >= 4);
    // assign is_mandelbrot = ~(computed_z_real[FIXED_POINT_WIDTH - 2] ^ computed_z_real[FIXED_POINT_WIDTH - 1] 
                                // | computed_z_imaginary[FIXED_POINT_WIDTH - 2] ^ computed_z_imaginary[FIXED_POINT_WIDTH - 1]);

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

endmodule

// This module may totally not work!
// Inputs: One sign, two integral, the rest are fractional (e.g. SII.FFFF...)
module ref_new_z #(
    parameter FIXED_POINT_WIDTH = 16 
) (
    input wire signed [FIXED_POINT_WIDTH-1:0] z_real, z_imaginary, c_real, c_imaginary,
    output wire signed [FIXED_POINT_WIDTH-1:0] new_z_real, new_z_imaginary
);
    wire signed [2*FIXED_POINT_WIDTH-1:0] z_real_squared, z_imaginary_squared;
    // wire signed [FIXED_POINT_WIDTH-1:0] z_real_squared, z_imaginary_squared;
    wire signed [2*FIXED_POINT_WIDTH-1:0] intermediate_real, intermediate_imaginary;
    
    assign z_real_squared = ((z_real * z_real) << 3) >> FIXED_POINT_WIDTH;
    // assign z_real_squared = ((z_real * z_real) << 3) >> FIXED_POINT_WIDTH;
    assign z_imaginary_squared = ((z_imaginary * z_imaginary) << 3) >> FIXED_POINT_WIDTH;

    assign intermediate_real = (z_real_squared - z_imaginary_squared);
    assign intermediate_imaginary = ((2 * z_real * z_imaginary) << 3) >> (FIXED_POINT_WIDTH + 1);

    assign new_z_real = intermediate_real + c_real;
    assign new_z_imaginary = intermediate_imaginary + c_imaginary;
endmodule

module ref_spi #(
    parameter DATA_WIDTH = 2,
    parameter DATA_DEPTH = 16
) (
    input wire clk, nrst, spi_clk, spi_en, 
    input wire spi_data, 
    output wire valid_data, // Output of edge detector, valid for 1 clock cylce
    output reg [DATA_WIDTH * DATA_DEPTH - 1:0] data_out // Valid when valid_data is high
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
    ref_syncronizer #(.DEPTH(3)) spi_en_syncronizer (
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
    ref_syncronizer #(.DEPTH(3)) 
    spi_data_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_data),
        .sync_out(spi_data_sync)
    );

    ////////////////////////////////
    // SHIFT REGISTER SHENANIGANS //
    ////////////////////////////////

    wire [DATA_WIDTH * DATA_DEPTH - 1:0] next_data_out;

    always @(posedge clk, negedge nrst) begin
        if (~nrst)
            data_out <= 0;
        else
            data_out <= next_data_out; 
    end

    ref_shift_reg #(.DEPTH(DATA_DEPTH * DATA_WIDTH)) spi_shift_reg (
        .clk(clk), .nrst(nrst),
        .en(spi_clk_edge),
        .q(spi_data_sync),
        .p_out(next_data_out)
    );

    /////////////////////////////////////////
    // CRAZY COUNTER CARNIVAL (I AM SANE!) //
    /////////////////////////////////////////

    wire all_data_received;

    ref_counter #(.N($clog2(DATA_DEPTH*DATA_WIDTH+1))) spi_data_counter (
        .clk(clk), .nrst(nrst),
        .clear(spi_en_edge), 
        .en(spi_clk_edge),
        .wrap(1'b0),
        .max(DATA_DEPTH*DATA_WIDTH),
        .count(),
        .at_max(all_data_received)
    );

    ref_posedge_detector data_valid_pulser (
        .clk(clk), .nrst(nrst),
        .signal(all_data_received),
        .posedge_detected(valid_data)
    );
    
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

*/