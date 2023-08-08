`timescale 1ns/100ps
`define CLOCK_PERIOD 100
`define SPI_MASTER_CLOCK_PERIOD 250
`define RESET_INACTIVE 1
`define RESET_ACTIVE 0

`define SPI_MESSAGE_WIDTH 2
`define SPI_MESSAGE_DEPTH 32
`define MANDELBROT_MAX_ITERATIONS 255

`define SCALING_FACTOR (2.0 ** 28.0)

`define IMG_WIDTH_PIXELS 1024
`define IMG_HEIGHT_PIXELS 1024


module tb_top ();

    integer i;
    integer f;
    integer pixel_x;
    integer pixel_y;

    real top_left_corner_x = -2; // -0.830541756;
    real top_left_corner_y = -1; // -0.207202618;
    real bottom_right_corner_x = 1; // -0.830486446;
    real bottom_right_corner_y = 1; //-0.20716154;
    real fraction_x;
    real fraction_y;
    real coord_x;
    real coord_y;
    
    reg tb_clk, tb_nrst;
    reg tb_spi_data, tb_imaginary_in, tb_spi_clk, tb_spi_en;
    wire tb_is_mandelbrot, tb_valid_out;
    wire [23:0] tb_RGB;
    
    wire [7:0] tb_R, tb_G, tb_B;
    assign {tb_R, tb_G, tb_B} = tb_RGB;

    reg tb_spi_clk_active;
    reg [`SPI_MESSAGE_DEPTH:0] tb_spi_packet;

    function [`SPI_MESSAGE_DEPTH-1:0] pixel_to_packet(input real pixel);
        pixel_to_packet = $rtoi(pixel * `SCALING_FACTOR);
    endfunction

    task inputs_to_zero;
        begin
            tb_spi_data = 0;
            tb_imaginary_in = 0; 
            tb_spi_clk_active = 0;
            tb_spi_en = 0; 
        end
    endtask

    task send_packet(
        input [`SPI_MESSAGE_DEPTH-1:0] a, b
    );
        begin
            @(negedge tb_clk);

            tb_spi_clk = 0;
            tb_spi_en = 1;
            #(`SPI_MASTER_CLOCK_PERIOD);
            
            tb_spi_packet = a;
            for (i = 0; i < `SPI_MESSAGE_DEPTH; i = i + 1) begin
                tb_spi_clk = 0;
                tb_spi_data = tb_spi_packet[`SPI_MESSAGE_DEPTH - 1];
                tb_spi_packet = tb_spi_packet << 1;
                #(`SPI_MASTER_CLOCK_PERIOD / 2);
                tb_spi_clk = 1;
                #(`SPI_MASTER_CLOCK_PERIOD / 2);
            end
            tb_spi_packet = b;
            for (i = 0; i < `SPI_MESSAGE_DEPTH; i = i + 1) begin
                tb_spi_clk = 0;
                tb_spi_data = tb_spi_packet[`SPI_MESSAGE_DEPTH - 1];
                tb_spi_packet = tb_spi_packet << 1;
                #(`SPI_MASTER_CLOCK_PERIOD / 2);
                tb_spi_clk = 1;
                #(`SPI_MASTER_CLOCK_PERIOD / 2);
            end

            tb_spi_en = 0;
            tb_spi_clk = 0;
        end
    endtask


    // initial begin
    //     $dumpfile ("dump.vcd");
    //     $dumpvars;
    // end

    
    always begin
        tb_clk = 1'b0;
        #(`CLOCK_PERIOD / 2);
        tb_clk = 1'b1;
        #(`CLOCK_PERIOD / 2);
    end

    // always begin
    //     @(posedge tb_RGB, negedge tb_RGB);
    //     $display("%b", tb_RGB);
    // end

    // always begin
    //     @(posedge tb_spi_clk);
    //     $display("SPI DATA SEND: %b", tb_spi_data);
    // end

    /////////
    // DUT //
    /////////

    pushing_pixels DUT (
        .clk(tb_clk), .nrst(tb_nrst),
        .spi_clk(tb_spi_clk),
        .spi_en(tb_spi_en),
        .spi_data(tb_spi_data),
        .is_mandelbrot(tb_is_mandelbrot),
        .valid_out(tb_valid_out),
        .color(tb_RGB)
    );

    //////////////
    // CLOCKING //
    //////////////

    initial begin
        tb_nrst = `RESET_ACTIVE;
        #(`CLOCK_PERIOD * 1);
        inputs_to_zero();
        #(`CLOCK_PERIOD * 2);
        tb_nrst = `RESET_INACTIVE;
        #(`CLOCK_PERIOD * 10);

        $display("%b", pixel_to_packet(-1.172938172391));

        // -0 + 0i
        $display("Test packet 1...");
        send_packet(pixel_to_packet(-0.0), pixel_to_packet(0));

        @(posedge tb_valid_out);
        #(`CLOCK_PERIOD * 5);

        // -1 + 0.5i
        $display("Test packet 2...");
        send_packet(pixel_to_packet(-1.0), pixel_to_packet(0.5));

        @(posedge tb_valid_out);
        #(`CLOCK_PERIOD * 10);

        $display("Opening .bmp file...");
        f = $fopen("img/mandel_1.bmp","w");

        // I am sorry...
        $display("Writing .bmp file header...");
        $fwrite(f, "%c", 8'h42);
        $fwrite(f, "%c", 8'h4d);
        $fwrite(f, "%c", 8'h36);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h03);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00); // 1/2
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h36);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h28);
        $fwrite(f, "%c", 8'h00); // 1
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h04);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h04); // 3/2
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h01);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h18);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00); // 2
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h30);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00);
        $fwrite(f, "%c", 8'h00); // 5/2
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
        for (pixel_y = 0; pixel_y < `IMG_HEIGHT_PIXELS; pixel_y = pixel_y + 1) begin
            if (pixel_y % 16 == 0) begin
                $display("Computing Row %d...", pixel_y + 1);     
            end
            for (pixel_x = 0; pixel_x < `IMG_WIDTH_PIXELS; pixel_x = pixel_x + 1) begin
                fraction_x = $itor(`IMG_WIDTH_PIXELS - pixel_x) / $itor(`IMG_WIDTH_PIXELS);
                fraction_y = $itor(`IMG_HEIGHT_PIXELS - pixel_y) / $itor(`IMG_HEIGHT_PIXELS);

                coord_x = fraction_x * (top_left_corner_x - bottom_right_corner_x) + bottom_right_corner_x;
                coord_y = fraction_y * (top_left_corner_y - bottom_right_corner_y) + bottom_right_corner_y; 
                
                // if (pixel_y % 16 == 0 && pixel_x % 16 == 0) begin
                //     $display("%f, %f", (coord_x), (coord_y));   
                //     $display("%b, %b", pixel_to_packet(coord_x), pixel_to_packet(coord_y));     
                // end

                // $display("Sending %f + %fi...", coord_x, coord_y);
                // $display("Packets %b %b", pixel_to_packet(coord_x), pixel_to_packet(coord_y));
                send_packet(pixel_to_packet(coord_x), pixel_to_packet(coord_y));

                @(posedge tb_valid_out);
                // $fwrite(f, "%c%c%c", tb_B, tb_G, {8{tb_is_mandelbrot}});
                $fwrite(f, "%c%c%c", tb_B, tb_G, tb_R);
                #(`CLOCK_PERIOD * 3);
                @(negedge tb_clk);
            end
        end

        $display("Closing .bmp file...");
        $fclose(f);

        $finish;
    end

endmodule

