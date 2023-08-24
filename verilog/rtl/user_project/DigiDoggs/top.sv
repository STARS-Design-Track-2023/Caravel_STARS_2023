`default_nettype none

//`include "pushing_pixels"

module top 
(
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  pushing_pixels FPGA_call(
    .cs(0), 
    .clk(hwclk), 
    .nrst(~pb[1]), 
    .spi_clk(pb[5]), 
    .spi_en(pb[4]), 
    .spi_data(pb[6]), 
    .valid_out(blue), 
    .is_mandelbrot(green), 
    .color({ss0[7:0], ss1[7:0], ss2[7:0]})
  );

endmodule

