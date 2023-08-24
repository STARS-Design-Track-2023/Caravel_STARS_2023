module tb_counter();

    parameter CLK_PERIOD = 100;
    //Clock and Reset signal
    logic tb_clk;
    logic tb_n_rst;
    
    //Test Bench Related Signal
    int tb_test_num;
    string tb_test_name;
    logic tb_enable, tb_clear, tb_clk_div;
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

//module counter (input logic clk, input logic nrst, input logic enable, input logic clear, input logic clock_div, output logic [11:0] time_out);
    counter DUT (.clk(tb_clk), 
    .nrst(tb_n_rst),
    .enable(tb_enable),
    .clear(tb_clear),
    .clock_div(tb_clk_div),
    .time_out(tb_time_out));

    
    initial begin 
        $dumpfile ("dump.vcd");
        $dumpvars;
    end


    initial begin
        tb_n_rst = 1;
        tb_clear = 0;
        tb_clk_div = 1;
        tb_enable = 0;
        reset_dut;

        @(negedge tb_clk);
        tb_enable = 1;
        repeat(65) @(posedge tb_clk);
        @(negedge tb_clk);
        tb_enable = 1;
        tb_clear = 1;
        $finish;

    end


endmodule