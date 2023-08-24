`timescale 1ns/10ps

module tb_timer ();
    parameter CLK_PERIOD = 100;
    //Clock and Reset signal
    logic tb_clk;
    logic tb_n_rst;
    
    //Test Bench Related Signal
    int tb_test_num;
    string tb_test_name;

    //DUT signals
    logic tb_clear, tb_enable_dec, tb_enable_in, tb_lap, tb_clk_div, tb_time_up;
    logic [11:0] tb_time_out;

    //CLK Gen
    always begin
        tb_clk = 0;
        #(CLK_PERIOD / 2);

        tb_clk = 1;
        #(CLK_PERIOD / 2);
    end

    task reset_dut;
    begin
    
        tb_n_rst = 0;
        @(posedge tb_clk);
        @(posedge tb_clk);
    
        @(negedge tb_clk);
        tb_n_rst = 1;

        @(posedge tb_clk);
        @(posedge tb_clk);


    end
    endtask



    timer DUT (.clk(tb_clk), 
    .nrst(tb_n_rst),
    .enable_dec(tb_enable_dec),
    .enable_in(tb_enable_in),
    .clk_div(tb_clk_div),
    .lap(tb_lap),
    .clear(tb_clear),
    .time_up(tb_time_up),
    .timer_out(tb_time_out)
    );

    initial begin 
        $dumpfile ("dump.vcd");
        $dumpvars;
    end

    initial begin
        tb_clear = 0;
        tb_n_rst = 1;
        tb_enable_dec = 0; 
        tb_enable_in = 0;
        tb_lap = 0;
        tb_clk_div = 0;
        reset_dut;

        @(negedge tb_clk);
        tb_enable_in = 1;
        tb_lap = 1;
        repeat(3) @(posedge tb_clk);
        @(negedge tb_clk);
        tb_lap = 0;
        @(negedge tb_clk);
        tb_enable_in = 0;
        tb_clear = 0;

        @(negedge tb_clk);
        tb_enable_dec = 1;
        tb_clk_div = 1;
        repeat(10) @(posedge tb_clk);
        
        @(negedge tb_clk);
        tb_clear = 1;
        tb_enable_dec = 0;

        repeat(10) @(posedge tb_clk);
        @(negedge tb_clk);
        tb_clear = 0
        tb_enable_dec = 1;

        $finish;
    end 

endmodule