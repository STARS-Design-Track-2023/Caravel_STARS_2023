`default_nettype none

module new_z #(
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

    reg signed [FIXED_POINT_WIDTH-1:0] trash;
    
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

        {trash, new_z_real} = {{FIXED_POINT_WIDTH{1'b0}}, intermediate_real[FIXED_POINT_WIDTH-1:0]} + c_a;
        {trash, new_z_imaginary} = {{FIXED_POINT_WIDTH{1'b0}},intermediate_imag[FIXED_POINT_WIDTH-1:0]} + c_b;

        {trash, square_sum} = z_real_squared + z_imag_squared;
        // $display("Square sum: %f", $itor(square_sum) / `SCALING_FACTOR);
        is_mandelbrot = square_sum >>> (FIXED_POINT_WIDTH - 4) < 4 && !z_real_squared[FIXED_POINT_WIDTH-1] && !z_imag_squared[FIXED_POINT_WIDTH-1];
    end

endmodule

// module new_z #(
//     parameter FIXED_POINT_WIDTH = 16 
// ) (
//     input logic signed [FIXED_POINT_WIDTH-1:0] z_real, z_imaginary, c_real, c_imaginary,
//     output logic signed [FIXED_POINT_WIDTH-1:0] new_z_real, new_z_imaginary
// );

// logic signed [2*FIXED_POINT_WIDTH-1:0] z_real_squared, z_imaginary_squared;
// logic signed [2*FIXED_POINT_WIDTH-1:0] intermediate_real, intermediate_imaginary;

// assign z_real_squared = ((z_real * z_real) << 3) >> FIXED_POINT_WIDTH;
// assign z_imaginary_squared = ((z_imaginary * z_imaginary) << 3) >> FIXED_POINT_WIDTH;

// assign intermediate_real = (z_real_squared - z_imaginary_squared);
// assign intermediate_imaginary = ((2 * z_real * z_imaginary) << 3) >> (FIXED_POINT_WIDTH + 1);

// assign new_z_real = intermediate_real[FIXED_POINT_WIDTH-1:0] + c_real;
// assign new_z_imaginary = intermediate_imaginary[FIXED_POINT_WIDTH-1:0] + c_imaginary;

// endmodule
