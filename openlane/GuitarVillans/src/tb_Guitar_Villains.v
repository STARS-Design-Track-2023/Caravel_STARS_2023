`timescale 1ns/1ns

module tb_Guitar_Villains();


localparam CLK_PERIOD = 100; // 10 MHz clock

/****** DUT Input Signals ******/ 
reg tb_clk, tb_n_rst; 
reg [3:0] tb_button; 
reg tb_chip_select; 

/****** DUT Output Signals ******/ 
wire [6:0] tb_top_row, tb_bottom_row; 
wire tb_red_disp, tb_green_disp; 
wire [6:0] tb_ss0, tb_ss1; 



// for loop var
integer i, j; 

// Generate the Clock
always begin
    tb_clk = 1'b0;
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0);
end




/* --- Port Map (One for gl sim and the other for RTL sim) --- */
`ifdef USE_POWER_PINS
Guitar_Villains DUT
(
    .VPWR(1),
    .VGND(0),

    .clk(tb_clk),
    .n_rst(tb_n_rst),
    .button(tb_button),
    .chip_select(tb_chip_select),

    .top_row(tb_top_row),
    .bottom_row(tb_bottom_row),
    .red_disp(tb_red_disp),
    .green_disp(tb_green_disp),
    .ss0(tb_ss0),
    .ss1(tb_ss1)
);
`else
Guitar_Villains DUT
(
   
    .clk(tb_clk),
    .n_rst(tb_n_rst),
    .button(tb_button),
    .chip_select(tb_chip_select),

    .top_row(tb_top_row),
    .bottom_row(tb_bottom_row),
    .red_disp(tb_red_disp),
    .green_disp(tb_green_disp),
    .ss0(tb_ss0),
    .ss1(tb_ss1)
);
`endif
/* -------------------------- END ---------------------------- */

// Create a file for Signal Dump
initial begin
    $dumpfile ("dump.vcd");
    $dumpvars;
end

/* --------- SDF annotation to simulate time for the verilog model -------- */
`ifdef ENABLE_SDF
initial begin
    $sdf_annotate("mapped/synth.sdf", DUT,,);
end
`endif
/* ------ Please do not modify this code should be there in every tb ------ */




// store the simulation data
initial begin
    $dumpfile("dump.vcd");
    $dumpvars; 
end


initial begin
    // initialize values
    tb_n_rst = 1'b0; // active
    tb_button = 4'h0;
    //tb_button[3] = 1'b1;  
    tb_chip_select = 1'b0; // active


    // de-assert the reset
    @(negedge tb_clk);
    tb_n_rst = 1'b1; 
    @(negedge tb_clk); 


    // TEST CASE 1: go from IDLE to Finish
    for(i = 0; i < 3 ; i = i + 1) begin
        @(negedge tb_clk); 
        tb_button[2] = 1'b1; 
        @(negedge tb_clk);
        tb_button[2] = 1'b0; 

        #(CLK_PERIOD * 5);

        if(i == 2) begin
            // create a bunch of misses 
            for(j = 0; j < 3; j = j + 1) begin
                @(negedge tb_clk); 
                tb_button[1:0] = 2'b11; 
                @(negedge tb_clk); 
                tb_button[1:0] = 2'b00; 

                #(CLK_PERIOD * 10); 
            end

            #(CLK_PERIOD * 50);
        end
    end

    // go to finish
    tb_button[3] = 1'b1; 
    @(negedge tb_clk); 
    #(CLK_PERIOD);
    tb_button[3] = 1'b0; 

    #(CLK_PERIOD * 5); 

    // toggle between scores
    for(j = 0; j < 10; j = j + 1) begin

        @(negedge tb_clk); 
        tb_button[0] = 1'b1; 
        @(negedge tb_clk); 
        tb_button[0] = 1'b0; 

        #(CLK_PERIOD * 5); 
    end

    // start a new game
    for(j = 0; j < 3; j = j + 1) begin

        @(negedge tb_clk); 
        tb_button[2] = 1'b1; 
        @(negedge tb_clk); 
        tb_button[2] = 1'b0; 

        #(CLK_PERIOD * 5); 
    end

    // toggle between 

    // tb_button[3] = 1'b1; 
    // @(negedge tb_clk);
    // tb_button[3] = 1'b0; 

    // for(i = 0; i < 3 ; i = i + 1) begin
    //     @(negedge tb_clk); 
    //     tb_button[2] = 1'b1; 
    //     @(negedge tb_clk);
    //     tb_button[2] = 1'b0; 
    // end



    // #(CLK_PERIOD * 15);



    
    $finish;
end









endmodule 