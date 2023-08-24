`timescale 1ns/10ps
module tb_top_asic();

    parameter CLK_PERIOD = 100;
    reg tb_nrst, tb_clk;
    wire tb_sig_out;
    wire [1:0] tb_mode_out;
    reg [14:0] tb_pb;

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


    /* --- Port Map (One for gl sim and the other for RTL sim) --- */
    `ifdef USE_POWER_PINS
    top_asic DUT
    (
        .VPWR(1),
        .VGND(0),
        .clk(tb_clk),
        .nrst(tb_nrst),
        .sigout(tb_sig_out),
        .mode_out(tb_mode_out),
        .pb(tb_pb)
    );
    `else
    top_asic DUT
    (
        .clk(tb_clk),
        .nrst(tb_nrst),
        .sigout(tb_sig_out),
        .mode_out(tb_mode_out),
        .pb(tb_pb)
    );
    `endif
    /* -------------------------- END ---------------------------- */


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


    initial begin
        tb_nrst = 1;
        tb_pb = 0;

        reset_dut;
        @(negedge tb_clk);
        tb_pb[0] = 1;
        tb_pb[12] = 1;
        tb_pb[13] = 1;
        tb_pb[14] = 1;
        repeat(1000000) @(posedge tb_clk);
        @(negedge tb_clk);
        tb_pb[2] = 1;
        tb_pb[3] = 1;
        repeat(1000000) @(posedge tb_clk);
        $finish;

        
    end

endmodule
