`include "source/control_unit/cu_pkg.sv"
`include "source/alu/alu_pkg.sv"
`timescale 1ns/10ps

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

module control_unit_tb();
  // 10MHz Clock Rate
  localparam CLK_PERIOD        = 100;

  // 10MHz D-FF Timing Constraints
  localparam PROPAGATION_DELAY = 1.1; // Allow for 1.1ns for FF propogation delay

  // TB-Specific Localparams
  // Inactive Inputs and Reset Output Values
  localparam  INACTIVE_D_VALUE = 1'b0;
  localparam  RESET_OUTPUT_VALUE = 8'b0;
  // Declare Test Case Signals
  integer tb_test_case_num;
  string  tb_test_case_name;
  logic   tb_mismatch;
  logic   tb_check;
  integer tb_done;
  // Declare DUT Connection Signals
  // Inputs
  logic                             tb_clk;
  logic                             tb_nrst;
  logic [15:0]                      tb_mem_data_in;
  logic                             tb_mem_ack;
  logic [15:0]                      tb_alu_result;
  cu_pkg::f_register                tb_alu_f_in;
  // Outputs
  logic [15:0]                      tb_mem_data_out;
  logic [15:0]                      tb_mem_addr;
  logic                             tb_dbl_byte_en;
  logic                             tb_mem_write_en;
  logic                             tb_mem_read_en;
  cu_pkg::f_register                tb_next_f;
  cu_pkg::f_register                tb_alu_f;
  logic [15:0]                      tb_op1;
  logic [15:0]                      tb_op2;
  alu_pkg::alu_op                   tb_alu_op_o;

  // Clock generation block
  always begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk <= 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk <= 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
  end

  task start_dut;
  begin
    // Init Test Case Meta Variables
    tb_test_case_num         = 0;
    tb_test_case_name        = "Test Bench Initializaton";
    tb_mismatch              = 1'b0;
    tb_check                 = 1'b0;
  end
  endtask

  // Task for standard DUT reset procedure
  task reset_dut;
  begin
    // Activate the reset
    tb_nrst = 1'b0;

    // Maintain the reset for more than one cycle
    @(posedge tb_clk);
    @(posedge tb_clk);

    // Wait until safely away from rising edge of the clock before releasing
    @(negedge tb_clk);
    tb_nrst = 1'b1;
  end
  endtask

  // Set input signals to zero before starting with new testcases
  task deactivate_signals;
  begin
    tb_mem_data_in = 16'b0;
    tb_mem_ack = 1'b0;
  end
  endtask

  // Set input signals to zero before starting with new testcases
  task start_testcase;
    input string test_case_name;
  begin
    // Space test case out from previous test case
    #(CLK_PERIOD * 3);

    // Set name and number
    tb_test_case_num  = tb_test_case_num + 1;
    tb_test_case_name = test_case_name;

    // Reset and deactivate DUT
    deactivate_signals();
    reset_dut();
    $display("=========Starting test case %s========= ", test_case_name);
  end
  endtask

  // Send in the opcode
  task send_opcode;
      input logic [7:0] opcode;
  begin
      tb_mem_data_in = {8'b0, opcode};
      tb_mem_ack = 1'b1;
      #(CLK_PERIOD);
      tb_mem_ack = 1'b0;
  end
  endtask

  // Send in an immediate byte
  task send_imm_byte;
      input logic [7:0] imm_byte;
  begin
      tb_mem_data_in = {8'b0, imm_byte};
      tb_mem_ack = 1'b1;
      #(CLK_PERIOD);
      tb_mem_ack = 1'b0;
  end
  endtask

  task send_double_byte;
      input logic [15:0] imm_double_byte;
  begin
      send_imm_byte(imm_double_byte[7:0]);
      tb_mem_data_in[15:8] = tb_mem_data_in[7:0];
      send_imm_byte(imm_double_byte[15:8]);
  end
  endtask

  // DUT Portmap
  control_unit DUT (
    .clk(tb_clk),
    .nrst(tb_nrst),
    .mem_data_in(tb_mem_data_in),
    .mem_ack(tb_mem_ack),
    .alu_result(tb_alu_result),
    .alu_f_in(tb_alu_f_in),
    .mem_data_out(tb_mem_data_out),
    .mem_addr(tb_mem_addr),
    .dbl_byte_en(tb_dbl_byte_en),
    .mem_write_en(tb_mem_write_en),
    .mem_read_en(tb_mem_read_en),
    .alu_f(tb_alu_f),
    .op1(tb_op1),
    .op2(tb_op2),
    .alu_op_o(tb_alu_op_o)
  );

  alu DUT_ALU(
    .Cin(tb_alu_f.c),
    .alu_op(tb_alu_op_o),
    .X(tb_op1),
    .Y(tb_op2),
    .flag(tb_alu_f_in),
    .result(tb_alu_result)
  );

  // Signal Dump
  initial begin
    $dumpfile ("dump.vcd");
    $dumpvars;
  end

  // Test Cases
  initial begin
    // Initialize all of the test inputs and test environment
    tb_done = 0;
    deactivate_signals();
    start_dut();

    // Initialize module-task-specific test cases
    // tb_stream_check_tag = "N/A";
    // tb_bit_num          = -1;   // Initialize to invalid number

    // Wait some time before starting first test case
    #(0.1);

    // ************************************************************************
    // Test Case 1: ld a, 0x11
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("CU: ld a, 0x11");
    send_opcode(8'h3E);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::wait_for_byte_state);
    send_imm_byte(8'h11);
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.reg_file.reg_a, 8'h11);

    // ************************************************************************
    // Test Case 2: call 0x1234
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("CU: call 0x1234");
    // Check pc and sp are reset
    `CHECK(DUT.pc.pc_o, 16'h1000);
    `CHECK(DUT.reg_file.reg_sp, 16'hff00);
    send_opcode(8'hCD);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    `CHECK(DUT.pc.pc_o, 16'h1001);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::wait_for_double_byte_state);
    send_double_byte(16'h1234);
    `CHECK(DUT.pc.pc_o, 16'h1003);
    `CHECK(DUT.id.reg_write_sel, cu_pkg::pc_register_select);
    `CHECK(DUT.id.state, cu_pkg::memory_write_state);
    `CHECK(DUT.mem_data_out, 16'h1003);
    // Set mem_ack to enter writeback state
    tb_mem_ack = 1'b1;
    #(CLK_PERIOD);
    tb_mem_ack = 1'b0;
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.pc.pc_o, 16'h1234);
    `CHECK(DUT.reg_file.reg_sp, 16'hfefe);

    // ************************************************************************
    // Test Case 3: jp 0x1234
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("CU: jp 0x1234");
    // Check pc is reset
    `CHECK(DUT.pc.pc_o, 16'h1000);
    send_opcode(8'hC3);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::wait_for_double_byte_state);
    send_double_byte(16'h1234);
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.pc.pc_o, 16'h1234);

    // ************************************************************************
    // Test Case 4: ret
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("CU: ret");
    // Check pc and sp are reset
    `CHECK(DUT.pc.pc_o, 16'h1000);
    `CHECK(DUT.reg_file.reg_sp, 16'hff00);
    // Set mem_data_in
    send_opcode(8'hC9);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::memory_read_state);
    // Set mem_ack to enter execute state
    tb_mem_data_in = 16'h4322;
    tb_mem_ack = 1'b1;
    #(CLK_PERIOD);
    tb_mem_ack = 1'b0;
    `CHECK(DUT.reg_file.reg_mem, 16'h4322);
    `CHECK(DUT_ALU.result, 16'h4322);
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.pc.pc_o, 16'h4322);
    `CHECK(DUT.reg_file.reg_sp, 16'hff02);

    // ************************************************************************
    // Test Case 5: ld bc, 0x1234 and push bc
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("CU: ld bc, 0x1234 and push bc");
    // Check sp is reset
    `CHECK(DUT.reg_file.reg_sp, 16'hff00);
    // load bc from immediate
    `CHECK(DUT.pc.pc_o, 16'h1000);
    send_opcode(8'h01);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.pc.pc_o, 16'h1001);
    `CHECK(DUT.id.state, cu_pkg::wait_for_double_byte_state);
    send_double_byte(16'h1234);
    `CHECK(DUT.pc.pc_o, 16'h1003);
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.reg_file.reg_b, 8'h12);
    `CHECK(DUT.reg_file.reg_c, 8'h34);
    `CHECK(DUT.pc.pc_o, 16'h1003);
    // push bc
    send_opcode(8'hC5);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::memory_write_state);
    `CHECK(tb_mem_data_out, 16'h1234);
    // Set mem_ack to enter writeback state
    tb_mem_ack = 1'b1;
    #(CLK_PERIOD);
    tb_mem_ack = 1'b0;
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.reg_file.reg_sp, 16'hfefe);

    // ************************************************************************
    // Test Case 6: pop bc
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("CU: pop bc");
    // Check sp and bc are reset
    `CHECK(DUT.reg_file.reg_sp, 16'hff00);
    `CHECK(DUT.reg_file.reg_b, RESET_OUTPUT_VALUE);
    `CHECK(DUT.reg_file.reg_c, RESET_OUTPUT_VALUE);
    // pop bc
    send_opcode(8'hC1);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD)
    `CHECK(DUT.id.state, cu_pkg::memory_read_state);
    // Set mem_data_in
    // Set mem_ack to enter execute state
    tb_mem_data_in = 16'h4322;
    tb_mem_ack = 1'b1;
    #(CLK_PERIOD);
    tb_mem_ack = 1'b0;
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.reg_file.reg_b, 8'h43);
    `CHECK(DUT.reg_file.reg_c, 8'h22);
    `CHECK(DUT.reg_file.reg_sp, 16'hff02);

    // ************************************************************************
    // Test Case 7: bit 7, b
    // ************************************************************************
    start_testcase("CU: bit 7, b");
    DUT.reg_file.reg_b = 8'h7F;
    DUT.reg_file.reg_f = 8'h00;
    send_opcode(8'hCB);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::wait_for_byte_state);
    send_imm_byte(8'h78);
    `CHECK(DUT.id.state, cu_pkg::cb_decode_state);
    #(CLK_PERIOD)
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.reg_file.reg_f.z, 1'b1);

    // ************************************************************************
    // Test Case 8: set 7, b
    // ************************************************************************
    start_testcase("CU: set 7, b");
    DUT.reg_file.reg_b = 8'h7F;
    send_opcode(8'hCB);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::wait_for_byte_state);
    send_imm_byte(8'hf8);
    `CHECK(DUT.id.state, cu_pkg::cb_decode_state);
    #(CLK_PERIOD)
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.reg_file.reg_b, 8'hff);

    // ************************************************************************
    // Test Case 9: res 7, b
    // ************************************************************************
    start_testcase("CU: res 7, b");
    DUT.reg_file.reg_b = 8'hFF;
    send_opcode(8'hCB);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::wait_for_byte_state);
    send_imm_byte(8'hb8);
    `CHECK(DUT.id.state, cu_pkg::cb_decode_state);
    #(CLK_PERIOD)
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.reg_file.reg_b, 8'h7f);

    // ************************************************************************
    // Test Case 10: djnz 0xff (updates pc)
    // ************************************************************************
    start_testcase("CU: djnz 0xff (updates pc)");
    DUT.reg_file.reg_b = 8'hF3;
    `CHECK(DUT.pc.pc_o, 16'h1000);
    send_opcode(8'h10);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::wait_for_byte_state);
    `CHECK(DUT.pc.pc_o, 16'h1001);
    send_imm_byte(8'hfe);
    `CHECK(DUT.pc.pc_o, 16'h1002);
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.reg_file.reg_b, 8'hf2);
    `CHECK(DUT.pc.pc_o, 16'h1000);

    // ************************************************************************
    // Test Case 10: djnz 0x32 (does not update pc)
    // ************************************************************************
    start_testcase("CU: djnz 0x32 (does not update pc)");
    DUT.reg_file.reg_b = 8'h01;
    `CHECK(DUT.pc.pc_o, 16'h1000);
    send_opcode(8'h10);
    `CHECK(DUT.id.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::wait_for_byte_state);
    `CHECK(DUT.pc.pc_o, 16'h1001);
    send_imm_byte(8'h32);
    `CHECK(DUT.pc.pc_o, 16'h1002);
    `CHECK(DUT.id.state, cu_pkg::writeback_state);
    #(CLK_PERIOD);
    `CHECK(DUT.id.state, cu_pkg::fetch_state);
    `CHECK(DUT.reg_file.reg_b, 8'h0);
    `CHECK(DUT.pc.pc_o, 16'h1002);

    $display("Simulation complete");
    tb_done = 1;
  end
endmodule
