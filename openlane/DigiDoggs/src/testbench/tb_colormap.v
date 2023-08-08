`timescale 1ns/100ps
`define CLOCK_PERIOD 100
// `include "source/color_converter.sv"

/*

typedef struct {             // Total: 54 bytes
  uint16_t  type;             // Magic identifier: 0x4d42
  uint32_t  size;             // File size in bytes
  uint16_t  reserved1;        // Not used
  uint16_t  reserved2;        // Not used
  uint32_t  offset;           // Offset to image data in bytes from beginning of file (54 bytes)
  uint32_t  dib_header_size;  // DIB Header size in bytes (40 bytes)
  int32_t   width_px;         // Width of the image
  int32_t   height_px;        // Height of image
  uint16_t  num_planes;       // Number of color planes
  uint16_t  bits_per_pixel;   // Bits per pixel
  uint32_t  compression;      // Compression type
  uint32_t  image_size_bytes; // Image size in bytes
  int32_t   x_resolution_ppm; // Pixels per meter
  int32_t   y_resolution_ppm; // Pixels per meter
  uint32_t  num_colors;       // Number of colors  
  uint32_t  important_colors; // Important colors 
} BMPHeader;

A header is valid if 
① its magic number is 0x4d42, 
② image data begins immediately after the header data (header -> offset == BMP HEADER SIZE), 
③ the DIB header is the correct size (DIB_HEADER_SIZE), 
④ there is only one image plane, 
⑤ there is no compression (header->compression == 0), 
⑥ num_colors and important_colors are both 0, 
⑦ the image has either 16 or 24 bits per pixel, 
⑧ the size and imagesize fields are correct in relation to the bits, width, and height fields or the file size.

*/

module tb_colormap ();

    integer tb_passes;
    integer tb_iterations;
    integer f;
    integer i;

    // BMP Header

    // integer header_bytes = 54;
    // reg [15:0] type = 16'h4d42;             // Magic identifier: 0x4d42
    // reg [31:0] size = 54 + 256 * 16 * 3;             // File size in bytes
    // reg [15:0] reserved1 = 0;        // Not used
    // reg [15:0] reserved2 = 0;        // Not used
    // reg [31:0] offset = header_bytes;           
    // ^ Offset to image data in bytes from beginning of file (54 bytes)
    // reg [31:0] dib_header_size = 40;  // DIB Header size in bytes (40 bytes)
    // reg [31:0] width_px = 256;         // Width of the image
    // reg [31:0] height_px = 16;        // Height of image
    // reg [15:0] num_planes = 1;       // Number of color planes
    // reg [15:0] bits_per_pixel = 24;   // Bits per pixel
    // reg [31:0] compression = 0;      // Compression type
    // reg [31:0] image_size_bytes = 256 * 16 * 3; // Image size in bytes
    // reg [31:0] x_resolution_ppm = 0; // Pixels per meter
    // reg [31:0] y_resolution_ppm = 0; // Pixels per meter
    // reg [31:0] num_colors = 0;       // Number of colors  
    // reg [31:0] important_colors = 0; // Important colors 

    // reg [(header_bytes)*8-1:0] bmp_header = 432'h0000_0000_0000_0000_;

    // reg [431:0] bmp_header = {432'h424d_3630_0000_0000_0000_3600_0000_2800_0000_0001_0000_1000_0000_0100_1800_0000_0000_0030_0000_0000_0000_0000_0000_0000_0000_0000_0000};

    // TB Signals
    reg tb_clk;
    reg tb_is_mandelbrot;
    wire [23:0] tb_RGB;
    wire [7:0] tb_R, tb_G, tb_B;
    assign {tb_R, tb_G, tb_B} = tb_RGB;

    // DUT
    color_converterBNW dut (
        .iteration(tb_iterations[7:0]),
        .ismandelbrot(tb_is_mandelbrot),
        .RGB(tb_RGB)
    );

    always begin
        tb_clk = 1'b0;
        #(`CLOCK_PERIOD / 2);
        tb_clk = 1'b1;
        #(`CLOCK_PERIOD / 2);
    end

    initial begin
        $display("Opening .bmp file...");
        f = $fopen("img/colormap.bmp","w");

        // I am sorry...
        $display("Writing .bmp file header...");
        $fwrite(f, "%c", 8'h42);
        $fwrite(f, "%c", 8'h4d);
        $fwrite(f, "%c", 8'h36);
        $fwrite(f, "%c", 8'h30);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h36);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h28);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h01);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h10);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h01);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h18);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h30);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        
        $display("Writing colormap...");
        for (tb_passes = 0; tb_passes < 16; tb_passes = tb_passes + 1) begin
            for (tb_iterations = 0; tb_iterations < 256; tb_iterations = tb_iterations + 1) begin
                @(posedge tb_clk);
                $fwrite(f, "%c%c%c", tb_B, tb_G, tb_R);
                @(negedge tb_clk);
            end
        end

        $display("Closing .bmp file...");
        $fclose(f);

        $finish;
    end
endmodule
