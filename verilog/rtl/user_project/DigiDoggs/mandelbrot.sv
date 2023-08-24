`default_nettype none

// `include "new_z.sv"
// `include "counter.sv"
// `include "gradient"

`define SCALING_FACTOR (2.0 ** 28.0)

module mandelbrotetron #(
    parameter FIXED_POINT_WIDTH = 16,
    parameter MAX_ITER = 256
) (
    input logic clk, nrst, start, 
    input logic signed [FIXED_POINT_WIDTH-1:0] c_real_in, c_imaginary_in,
    output logic valid,
    output logic is_mandelbrot,
    output logic [$clog2(MAX_ITER)-1:0] iterations 
);

logic signed [FIXED_POINT_WIDTH-1:0] c_real, c_imaginary, z_real, z_imaginary;
logic signed [FIXED_POINT_WIDTH-1:0] next_c_real, next_c_imaginary, next_z_real, next_z_imaginary;
logic signed [FIXED_POINT_WIDTH-1:0] computed_z_real, computed_z_imaginary;
logic max_iter_reached;
logic next_valid;
logic stop;

assign stop = max_iter_reached | ~is_mandelbrot;

//////////////////////////////
// MANDELBROT-IFICATION!!!! //
//////////////////////////////

always_ff @(posedge clk, negedge nrst) begin
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

always_comb begin
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

///////////////////////
///// NEW Z VALUE /////
///////////////////////

new_z #(.FIXED_POINT_WIDTH(FIXED_POINT_WIDTH)) z_function (
    .z_real(z_real), 
    .z_imaginary(z_imaginary), 
    .c_real(c_real), 
    .c_imaginary(c_imaginary), 
    .new_z_real(computed_z_real), 
    .new_z_imaginary(computed_z_imaginary),
    .is_mandelbrot(is_mandelbrot)
);

// always @(posedge start) begin
//     $display("Recieved: %f %f", $itor(c_real_in) / `SCALING_FACTOR / 2, $itor(c_imaginary_in) / `SCALING_FACTOR / 2);
//     $display("Recieved: %b %b", c_real_in, c_imaginary_in);
// end

///////////////////////
// ITERATION COUNTER //
///////////////////////


counter #(.N($clog2(MAX_ITER))) iteration_counter (.clk(clk), .nrst(nrst), .clear(start), .wrap(1'b0), .en(~stop), .max(MAX_ITER[$clog2(MAX_ITER)-1:0]), .count(iterations), .at_max(max_iter_reached));

/////////////////////////
// MANDELBROT DETECTOR //
/////////////////////////

// Sees wether the 2^1 bit on either input is high (edit: two's compliment)
/* assign is_mandelbrot = ~(computed_z_real[FIXED_POINT_WIDTH - 2] ^ computed_z_real[FIXED_POINT_WIDTH - 1] 
                            | computed_z_imaginary[FIXED_POINT_WIDTH - 2] ^ computed_z_imaginary[FIXED_POINT_WIDTH - 1]); */

/////////////////////////////////////
// Start and valid signal handling //
/////////////////////////////////////

always_ff @(posedge clk, negedge nrst) begin
    if (~nrst)
        valid <= 0;
    else 
        valid <= next_valid;
end

assign next_valid = stop && ~start;

endmodule

