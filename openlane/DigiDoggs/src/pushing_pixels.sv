`default_nettype none
`define SPI_MESSAGE_WIDTH 2
`define SPI_MESSAGE_DEPTH 32
`define MANDELBROT_MAX_ITERATIONS 255

// `include "sync.sv"
// `include "edge_detector.sv"
// `include "color_converter.sv"


module pushing_pixels (
    input logic cs, // Chip Select (Active Low)
    input logic clk, nrst, spi_clk, spi_en,
    input logic spi_data,
    output logic valid_out,
    output logic is_mandelbrot,
    output logic [23:0] color 
);

logic spi_valid_data, mandelbrot_valid_output, next_valid_output;
logic [7:0] iterations;
logic [`SPI_MESSAGE_WIDTH * `SPI_MESSAGE_DEPTH - 1:0] spi_data_out;

spi_in #(.DATA_WIDTH(`SPI_MESSAGE_WIDTH), .DATA_DEPTH(`SPI_MESSAGE_DEPTH)) input_spi (.clk(clk), .nrst(nrst), .spi_clk(spi_clk), .spi_en(spi_en), .spi_data(spi_data), .valid_data(spi_valid_data), .data_out(spi_data_out));
mandelbrotetron #(.FIXED_POINT_WIDTH(`SPI_MESSAGE_DEPTH), .MAX_ITER(`MANDELBROT_MAX_ITERATIONS)) mandelbrot (.clk(clk), .nrst(nrst), .start(spi_valid_data),  .c_real_in(spi_data_out[2*`SPI_MESSAGE_DEPTH-1:`SPI_MESSAGE_DEPTH]),  .c_imaginary_in(spi_data_out[`SPI_MESSAGE_DEPTH-1:0]), .valid(mandelbrot_valid_output), .is_mandelbrot(is_mandelbrot), .iterations(iterations));
color_converter color_converter (.iteration(iterations), .ismandelbrot(is_mandelbrot), .RGB(color));

always @(posedge clk, negedge nrst) begin
    if (~nrst)
        valid_out <= 0;
    else
        valid_out <= next_valid_output;
end

assign next_valid_output = mandelbrot_valid_output && ~spi_valid_data;

endmodule

