`timescale 1ns/10ps
module tb_stopwatch ();
    
    parameter CLK_PERIOD = 100;
    reg tb_nrst, tb_clk;
    reg tb_pb0, tb_pb1;
    wire [6:0] tb_out0, tb_out1, tb_out2, tb_out3;
    wire tb_time_done;

    // Task for standard DUT reset procedure
    task reset_dut;
    begin
        // Activate the reset
        tb_nrst = 1'b0;

        // Maintain the reset for more than one cycle
        @(posedge tb_clk);
        @(posedge tb_clk);

        // Wait until safely away from the rising edge of the clock before releasing
        @(negedge tb_clk);
        tb_nrst = 1'b1;

        // Leave out of reset for a couple cycles before allowing other stimulus
        @(negedge tb_clk);
        @(negedge tb_clk);
    end
    endtask


    // 10 MHz Clock
    always begin
        // Start with clock low to avoid false rising edge events at t=0
        tb_clk = 1'b0;
        // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
        #(CLK_PERIOD/2.0);
        tb_clk = 1'b1;
        // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
        #(CLK_PERIOD/2.0);
    end

    /* --------- SDF annotation to simulate time for the verilog model -------- */
    `ifdef ENABLE_SDF
    initial begin
        $sdf_annotate("mapped/synth.sdf", DUT,,);
    end
    `endif
    /* ------ Please do not modify this code should be there in every tb ------ */
    
    initial begin
        $dumpfile ("dump.vcd");
        $dumpvars;
    end

    /* --- Port Map (One for gl sim and the other for RTL sim) --- */
    `ifdef USE_POWER_PINS
    stopwatch DUT
    (
        .VPWR(1),
        .VGND(0),
        .clk(tb_clk),
        .nrst(tb_nrst),
        .pb_0(tb_pb0),
        .pb_1(tb_pb1),
        .time_done(tb_time_done),
        .out_0(tb_out0),
        .out_1(tb_out1),
        .out_2(tb_out2),
        .out_3(tb_out3)
    );
    `else
    stopwatch DUT
    (
        .clk(tb_clk),
        .nrst(tb_nrst),
        .pb_0(tb_pb0),
        .pb_1(tb_pb1),
        .time_done(tb_time_done),
        .out_0(tb_out0),
        .out_1(tb_out1),
        .out_2(tb_out2),
        .out_3(tb_out3)
    );
    `endif
    /* -------------------------- END ---------------------------- */


    initial begin
        tb_nrst = 1;
        tb_pb1 = 0;
        tb_pb0 = 0;

        reset_dut;
        repeat(10) @(posedge tb_clk);
        @(negedge tb_clk);
        tb_pb0 = 1;
        @(negedge tb_clk);
        @(negedge tb_clk);
        @(negedge tb_clk);
        @(negedge tb_clk);
        tb_pb0 = 0;
        repeat(700000000)@(posedge tb_clk);
        $finish;
    end


endmodule