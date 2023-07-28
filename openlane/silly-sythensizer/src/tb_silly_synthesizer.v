`timescale 1ns/100ps
module tb_silly_synthesizer ();
    // VARIABLES
    localparam time CLK_PERIOD = 100;
    integer TESTS_FAILED = 0;
    integer TESTS_PASSED = 0;
    integer TEST_NUMBER = 0;

    // SIGNALS
    reg tb_clk, tb_nrst, tb_cs;
    reg [16:0] tb_gpio;
    wire tb_pwm;

    // TASKS
    task RESET;
        begin
            @(negedge tb_clk);
            tb_nrst = 0;

            @(negedge tb_clk);
            tb_nrst = 1;
        end
    endtask

    task SET_CS;
        begin
            tb_cs = 0;
        end
    endtask
    
    task RESET_CS;
        begin
            tb_cs = 1;
        end
    endtask

    task WAIT (
        input integer cycles
    );
    	integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge tb_clk);
            end
        end
    endtask

    task FEED_INPUTS (
        input [16:0] gpio
    );
        begin
            @(negedge tb_clk);
            tb_gpio = gpio;
        end
    endtask

    task ASSERT_OUTPUTS (
        input pwm
    );
        begin
            TEST_NUMBER = TEST_NUMBER + 1;
            @(negedge tb_clk);
            if (tb_pwm != pwm) begin
                $error("Test %d Failed", TEST_NUMBER);
                $error("Expected: %b", pwm);
                $error("Actual: %b", tb_pwm);
                TESTS_FAILED = TESTS_FAILED + 1;
            end else begin
                $info("Test %d Passed", TEST_NUMBER);
                TESTS_PASSED = TESTS_PASSED + 1;
            end
        end
    endtask

    // DUTs
    `ifdef USE_POWER_PINS
    silly_synthesizer dut_top
    (
        .VPWR(1),
        .VGND(0),
        .clk(tb_clk),
	.nrst(tb_nrst),
	.cs(tb_cs),
	.gpio(tb_gpio),
	.pwm(tb_pwm)
    );
    `else
    silly_synthesizer dut_top (tb_clk, tb_nrst, tb_cs, tb_gpio, tb_pwm);
    `endif

    // CLOCKING
    always begin
        tb_clk = 1;
        #(CLK_PERIOD/2);
        tb_clk = 0;
        #(CLK_PERIOD/2);
    end

    // SDF
    `ifdef ENABLE_SDF
    initial begin
        $sdf_annotate("mapped/synth.sdf", dut_top,,);
    end
    `endif

    // VCD
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
    end

    // TESTS
    initial begin

        // SETUP
        tb_nrst = 1;
        tb_cs = 1;
        tb_gpio = 17'bz;
        #1;

        // TEST 1: Power-On Reset
        tb_nrst = 0;
        tb_cs = 0;
        #10;
        
        tb_nrst = 1;

        ASSERT_OUTPUTS(1'b0);
        // END TEST 1

        FEED_INPUTS(17'b0);
        WAIT(10);
        FEED_INPUTS(17'b00010000000000000);
        WAIT(10);
        FEED_INPUTS(17'b0);
        WAIT(10);
        FEED_INPUTS(17'b00000000000000001);
        WAIT(10);
        FEED_INPUTS(17'b0);
        WAIT(10);

        $finish();
    
    end

endmodule
