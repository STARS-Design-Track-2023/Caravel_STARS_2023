`default_nettype none
`timescale 1ns / 10ps

`define CHECK(VAR, EXPECTED)                                                                                \
    tb_mismatch = 1'b0;                                                                                     \
    tb_check = 1'b1;                                                                                        \
    if ((VAR) == (EXPECTED)) begin                                                                          \
        $display("Correct output for %s ", (`"VAR`"));                                                      \
    end else begin                                                                                          \
        tb_mismatch = 1'b1;                                                                                 \
        $error("Incorrect output for %s, expected: 0x%h, found: 0x%h ", (`"VAR`"), (EXPECTED), (VAR));      \
        #(CLK_PERIOD);                                                                                      \
        $fatal;                                                                                             \
    end                                                                                                     \
    #(0.1)                                                                                                  \
    tb_check = 1'b0;

module z23_tb();
    // Define parameters
    parameter CLK_PERIOD        = 100;
    int tb_fd;

    integer tb_done;
    integer tb_check;
    integer tb_mismatch;
    integer tb_asm_test_sel;

    //DUT input
    logic           tb_clk;
    logic           tb_nrst;
    logic [7:0]     tb_memory_data_in;
    logic [7:0]     tb_programmable_gpio_in;
    logic           tb_interrupt_gpio_in;
    logic [15:0]    tb_keypad_input;
    //DUT output
    logic [15:0]    tb_memory_address_out;
    logic [7:0]     tb_memory_data_out;
    logic [7:0]     tb_programmable_gpio_out;
    logic           tb_memory_wr;
    logic [7:0]     tb_programmable_gpio_wr;
    logic [7:0]     tb_ss7;
    logic [7:0]     tb_ss6;
    logic [7:0]     tb_ss5;
    logic [7:0]     tb_ss4;
    logic [7:0]     tb_ss3;
    logic [7:0]     tb_ss2;
    logic [7:0]     tb_ss1;
    logic [7:0]     tb_ss0;

    logic [7:0]     tb_asm_test_0_data_out;
    memory_tb #(
        .FILE_NAME("sim_build/a_should_be_0x70.bin"),
        .TOP_OF_STACK(16'hff00)
    )asm_test_0_dut(
        .clk(tb_clk),
        .nrst(tb_nrst),
        .wr(tb_memory_wr),
        .address(tb_memory_address_out),
        .data_in(tb_memory_data_out),
        .data_out(tb_asm_test_0_data_out)
    );

    logic [7:0]     tb_asm_test_1_data_out;
    memory_tb #(
        .FILE_NAME("sim_build/multiply_example.bin"),
        .TOP_OF_STACK(16'hff00)
    )asm_test_1_dut(
        .clk(tb_clk),
        .nrst(tb_nrst),
        .wr(tb_memory_wr),
        .address(tb_memory_address_out),
        .data_in(tb_memory_data_out),
        .data_out(tb_asm_test_1_data_out)
    );

    logic [7:0]     tb_asm_test_2_data_out;
    memory_tb #(
        .FILE_NAME("sim_build/msg.bin"),
        .TOP_OF_STACK(16'hff00)
    )asm_test_2_dut(
        .clk(tb_clk),
        .nrst(tb_nrst),
        .wr(tb_memory_wr),
        .address(tb_memory_address_out),
        .data_in(tb_memory_data_out),
        .data_out(tb_asm_test_2_data_out)
    );

    logic [7:0]     tb_asm_test_3_data_out;
    memory_tb #(
        .FILE_NAME("sim_build/msg_int.bin"),
        .TOP_OF_STACK(16'hff00)
    )asm_test_3_dut(
        .clk(tb_clk),
        .nrst(tb_nrst),
        .wr(tb_memory_wr),
        .address(tb_memory_address_out),
        .data_in(tb_memory_data_out),
        .data_out(tb_asm_test_3_data_out)
    );

    //DUT protmap
    z23 DUT(
        .clk(tb_clk),
        .nrst(tb_nrst),
        .memory_data_in(tb_memory_data_in),
        .programmable_gpio_in(tb_programmable_gpio_in),
        .interrupt_gpio_in(tb_interrupt_gpio_in),
        .keypad_input(tb_keypad_input),
        .memory_address_out(tb_memory_address_out),
        .memory_data_out(tb_memory_data_out),
        .programmable_gpio_out(tb_programmable_gpio_out),
        .memory_wr(tb_memory_wr),
        .programmable_gpio_wr(tb_programmable_gpio_wr),
        .ss7(tb_ss7),
        .ss6(tb_ss6),
        .ss5(tb_ss5),
        .ss4(tb_ss4),
        .ss3(tb_ss3),
        .ss2(tb_ss2),
        .ss1(tb_ss1),
        .ss0(tb_ss0)
    );

    //reset_task
    task reset_dut;
        begin
        // Activate the design's reset (does not need to be synchronize with clock)
        tb_nrst = 1'b0;

        // Wait for a couple clock cycles
        @(posedge tb_clk);
        @(posedge tb_clk);
        tb_programmable_gpio_in = 8'b0;
        tb_interrupt_gpio_in = 1'b0;
        tb_keypad_input = 16'b0;

        // Release the reset
        @(negedge tb_clk);
        tb_nrst = 1;
    end
    endtask

    initial begin
      $dumpfile ("dump.vcd");
      $dumpvars;
    end

    always begin: CLK_GEN
        tb_clk = 1'b0;
        #(CLK_PERIOD / 2);
        tb_clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    always begin
        case (tb_asm_test_sel)
            0       : tb_memory_data_in = tb_asm_test_0_data_out;
            1       : tb_memory_data_in = tb_asm_test_1_data_out;
            2       : tb_memory_data_in = tb_asm_test_2_data_out;
            3       : tb_memory_data_in = tb_asm_test_3_data_out;
        endcase
        #(0.1);
    end

    initial begin
        tb_done = 0;

        reset_dut();

        tb_asm_test_sel = 0;
        wait(DUT.cu.id.is_halted);
        `CHECK(DUT.cu.reg_file.reg_a, 8'h70);
        $display("done with 0");

        reset_dut();

        tb_asm_test_sel = 1;
        wait(DUT.cu.id.is_halted);
        `CHECK(asm_test_1_dut.ram[16'h2000-1], 8'h21);
        `CHECK(asm_test_1_dut.ram[16'h2000-2], 8'h56);
        $display("done with 1");

        reset_dut();

        tb_asm_test_sel = 2;
        wait(DUT.cu.id.is_halted);
        $display("done with 2");

        reset_dut();

        tb_asm_test_sel = 3;
        wait(DUT.cu.id.is_halted);
        $display("done with 3");
        #(CLK_PERIOD * 10000);
        $display("press");
        @(negedge tb_clk);
        tb_keypad_input = 16'b1;
        #(CLK_PERIOD * 100);
        @(posedge tb_clk);
        $display("release");
        tb_keypad_input = 16'b0;
        wait(DUT.cu.id.is_halted);
        #(CLK_PERIOD * 10);

        tb_done = 1;
    end
endmodule
