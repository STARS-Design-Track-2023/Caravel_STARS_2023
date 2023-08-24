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

module instruction_decoder_tb();
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
  logic [7:0]                       tb_opcode;
  logic [15:0]                      tb_imm_i;
  cu_pkg::f_register                tb_f_in;
  cu_pkg::f_register                tb_alu_f_in;
  logic                             tb_memory_acknowledge;
  // Outputs
  logic                             tb_clear;
  logic                             tb_hold;
  logic                             tb_next_instr_req;
  logic                             tb_cond_true;
  logic                             tb_jump_is_relative;
  logic                             tb_call_or_jump;
  logic [7:0]                       tb_pc_offset;
  cu_pkg::f_register                tb_f_out;
  cu_pkg::register_select           tb_r1_sel;
  cu_pkg::register_select           tb_r2_sel;
  cu_pkg::register_select           tb_reg_write_sel;
  cu_pkg::register_select           tb_reg_mem_addr_read_sel;
  cu_pkg::register_select           tb_reg_mem_addr_write_sel;
  logic                             tb_reg_file_write_en;
  cu_pkg::decoded_instruction       tb_instr_to_reg_file;
  alu_pkg::alu_op                   tb_alu_op;
  logic                             tb_mem_read_en;
  logic                             tb_mem_write_en;
  logic                             tb_dbl_byte_en;
  cu_pkg::mem_req_source_sel        tb_mem_addr_read_source_sel;
  cu_pkg::mem_req_source_sel        tb_mem_addr_write_source_sel;
  logic [15:0]                      tb_r1_imm;
  logic [15:0]                      tb_r2_imm;
  logic                             tb_r1_is_imm;
  logic                             tb_r2_is_imm;
  logic [15:0]                      tb_mem_addr_imm;

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

    // Leave out of reset for a couple cycles before allowing other stimulus
    // Wait for negative clock edges,
    // since inputs to DUT should normally be applied away from rising clock edges
    @(negedge tb_clk);
    @(negedge tb_clk);
  end
  endtask

  // Set input signals to zero before starting with new testcases
  task deactivate_signals;
  begin
    tb_opcode = 8'b0;
    tb_imm_i = 16'b0;
    tb_f_in = 8'b0;
    tb_alu_f_in = 8'b0;
    tb_memory_acknowledge = 1'b0;
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
      tb_opcode = opcode;
      tb_memory_acknowledge = 1'b1;
      #(CLK_PERIOD);
      tb_memory_acknowledge = 1'b0;
  end
  endtask

  // Send in an immediate byte
  task send_imm_byte;
      input logic [7:0] imm_byte;
  begin
      tb_imm_i[7:0] = imm_byte;
      tb_memory_acknowledge = 1'b1;
      #(CLK_PERIOD);
      tb_memory_acknowledge = 1'b0;
  end
  endtask

  task send_double_byte;
      input logic [15:0] imm_double_byte;
  begin
      send_imm_byte(imm_double_byte[15:8]);
      tb_imm_i[15:8] = tb_imm_i[7:0];
      send_imm_byte(imm_double_byte[7:0]);
  end
  endtask

  // DUT Portmap
  instruction_decoder DUT(
    .clk(tb_clk),
    .nrst(tb_nrst),
    .opcode(tb_opcode),
    .imm_i(tb_imm_i),
    .alu_f_in(tb_alu_f_in),
    .memory_acknowledge(tb_memory_acknowledge),
    .clear(tb_clear),
    .hold(tb_hold),

    .next_instr_req(tb_next_instr_req),
    .cond_true(tb_cond_true),
    .jump_is_relative(tb_jump_is_relative),
    .call_or_jump(tb_call_or_jump),
    .pc_offset(tb_pc_offset),

    .f_out(tb_f_out),

    .r1_sel(tb_r1_sel),
    .r2_sel(tb_r2_sel),
    .reg_write_sel(tb_reg_write_sel),
    .reg_mem_addr_read_sel(tb_reg_mem_addr_read_sel),
    .reg_mem_addr_write_sel(tb_reg_mem_addr_write_sel),
    .reg_file_write_en(tb_reg_file_write_en),
    .f_in(tb_f_in),
    .instr_to_reg_file(tb_instr_to_reg_file),

    .alu_op(tb_alu_op),

    .mem_read_en(tb_mem_read_en),
    .mem_write_en(tb_mem_write_en),
    .dbl_byte_en(tb_dbl_byte_en),

    .mem_addr_read_source_sel(tb_mem_addr_read_source_sel),
    .mem_addr_write_source_sel(tb_mem_addr_write_source_sel),
    .r1_imm(tb_r1_imm),
    .r2_imm(tb_r2_imm),
    .r1_is_imm(tb_r1_is_imm),
    .r2_is_imm(tb_r2_is_imm),
    .mem_addr_imm(tb_mem_addr_imm)
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
    start_testcase("ld a, 0x11");
    send_opcode(8'h3E);
    `CHECK(DUT.state, cu_pkg::decode_state)
    #(CLK_PERIOD);
    `CHECK(DUT.state, cu_pkg::wait_for_byte_state)
    send_imm_byte(8'h11);
    `CHECK(DUT.imm_i, 16'h0011)
    `CHECK(DUT.r1_is_imm, 1'b1);
    `CHECK(DUT.r1_imm, 16'h0011);
    `CHECK(DUT.r2_is_imm, 1'b1);
    `CHECK(DUT.r2_imm, 16'h0000);
    `CHECK(DUT.reg_write_sel, cu_pkg::a_register_select);
    `CHECK(DUT.alu_op, alu_pkg::ADD8);
    // Wait to enter writeback state
    `CHECK(DUT.state, cu_pkg::writeback_state);
    `CHECK(DUT.reg_file_write_en, 1'b1);

    // ************************************************************************
    // Test Case 2: jr 0x11
    // ************************************************************************
    start_testcase("jr 0x11");
    send_opcode(8'h18);
    `CHECK(DUT.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.state, cu_pkg::wait_for_byte_state)
    send_imm_byte(8'h11);
    `CHECK(DUT.pc_offset, 8'h11);
    `CHECK(DUT.state, cu_pkg::writeback_state);

    // ************************************************************************
    // Test Case 3: jp 0x1234
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("jp 0x1234");
    send_opcode(8'hC3);
    `CHECK(DUT.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.state, cu_pkg::wait_for_double_byte_state)
    send_double_byte(16'h1234);
    `CHECK(DUT.imm_i, 16'h1234)
    `CHECK(DUT.r1_is_imm, 1'b1);
    `CHECK(DUT.r1_imm, 16'h1234);
    `CHECK(DUT.r2_is_imm, 1'b1);
    `CHECK(DUT.r2_imm, 16'h0000);
    `CHECK(DUT.alu_op, alu_pkg::ADD16);
    `CHECK(DUT.state, cu_pkg::writeback_state);
    `CHECK(DUT.reg_file_write_en, 1'b0);

    // ************************************************************************
    // Test Case 3: jp nc, 0x1234 with true condition
    // ************************************************************************
    start_testcase("jp nc, 0x1234, true");
    tb_f_in.c = 1'b0;
    send_opcode(8'hD2);
    `CHECK(DUT.state, cu_pkg::decode_state);
    #(CLK_PERIOD);
    `CHECK(DUT.state, cu_pkg::wait_for_double_byte_state)
    send_double_byte(16'h1234);
    `CHECK(DUT.imm_i, 16'h1234)
    `CHECK(DUT.r1_is_imm, 1'b1);
    `CHECK(DUT.r1_imm, 16'h1234);
    `CHECK(DUT.r2_is_imm, 1'b1);
    `CHECK(DUT.r2_imm, 16'h0000);
    `CHECK(DUT.alu_op, alu_pkg::ADD16);
    `CHECK(DUT.cond_true, 1'b1);
    `CHECK(DUT.state, cu_pkg::writeback_state);
    `CHECK(DUT.reg_file_write_en, 1'b0);

    // ************************************************************************
    // Test Case 4: jp nc, 0x1234 with false condition
    // ************************************************************************
    start_testcase("jp nc, 0x1234, false");
    tb_f_in.c = 1'b1;
    send_opcode(8'hD2);
    `CHECK(DUT.state, cu_pkg::decode_state)
    #(CLK_PERIOD);
    `CHECK(DUT.state, cu_pkg::wait_for_double_byte_state)
    send_double_byte(16'h1234);
    `CHECK(DUT.imm_i, 16'h1234)
    `CHECK(DUT.r1_is_imm, 1'b1);
    `CHECK(DUT.r1_imm, 16'h1234);
    `CHECK(DUT.r2_is_imm, 1'b1);
    `CHECK(DUT.r2_imm, 16'h0000);
    `CHECK(DUT.alu_op, alu_pkg::ADD16);
    `CHECK(DUT.cond_true, 1'b0);
    `CHECK(DUT.state, cu_pkg::writeback_state);
    `CHECK(DUT.reg_file_write_en, 1'b0);

    // ************************************************************************
    // Test Case 5: call 0x1234
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("call 0x1234");
    send_opcode(8'hCD);
    `CHECK(DUT.state, cu_pkg::decode_state);
    #(CLK_PERIOD)
    `CHECK(DUT.state, cu_pkg::wait_for_double_byte_state)
    send_double_byte(16'h1234);
    `CHECK(DUT.alu_op, alu_pkg::ADD16);
    `CHECK(DUT.r1_imm, 16'h1234);
    `CHECK(DUT.r1_is_imm, 1'b0);
    `CHECK(DUT.reg_mem_addr_write_sel, cu_pkg::sp_register_select);
    `CHECK(DUT.r2_imm, 16'b0);
    `CHECK(DUT.r2_is_imm, 1'b1);
    `CHECK(DUT.reg_write_sel, cu_pkg::pc_register_select);
    `CHECK(DUT.state, cu_pkg::memory_write_state);
    `CHECK(DUT.r1_imm, 16'h1234);
    `CHECK(DUT.r1_is_imm, 1'b0);
    tb_memory_acknowledge = 1'b1;
    #(CLK_PERIOD);
    tb_memory_acknowledge = 1'b0;
    `CHECK(DUT.state, cu_pkg::writeback_state);
    `CHECK(DUT.r1_is_imm, 1'b1);
    tb_memory_acknowledge = 1'b0;

    // ************************************************************************
    // Test Case 6: ld de, 0x2234
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("ld de, 0x2234");
    send_opcode(8'h11);
    `CHECK(DUT.state, cu_pkg::decode_state)
    #(CLK_PERIOD)
    `CHECK(DUT.state, cu_pkg::wait_for_double_byte_state)
    send_double_byte(16'h2234);
    `CHECK(DUT.imm_i, 16'h2234)
    `CHECK(DUT.r1_is_imm, 1'b1);
    `CHECK(DUT.r1_imm, 16'h2234);
    `CHECK(DUT.r2_is_imm, 1'b1);
    `CHECK(DUT.r2_imm, 16'h0000);
    `CHECK(DUT.reg_write_sel, cu_pkg::de_register_select);
    `CHECK(DUT.alu_op, alu_pkg::ADD16);
    `CHECK(DUT.state, cu_pkg::writeback_state);
    `CHECK(DUT.reg_file_write_en, 1'b1);

    // ************************************************************************
    // Test Case 7: ld (de), a
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("ld (de), a");
    send_opcode(8'h12);
    `CHECK(DUT.state, cu_pkg::decode_state)
    #(CLK_PERIOD);
    `CHECK(DUT.imm_i, 16'b0);
    `CHECK(DUT.r1_is_imm, 1'b0);
    `CHECK(DUT.r1_imm, 16'b0);
    `CHECK(DUT.r2_is_imm, 1'b1);
    `CHECK(DUT.r2_imm, 16'h0000);
    `CHECK(DUT.r1_sel, cu_pkg::a_register_select);
    `CHECK(DUT.reg_mem_addr_write_sel, cu_pkg::de_register_select);
    `CHECK(DUT.alu_op, alu_pkg::ADD8);
    `CHECK(DUT.opcode_requires_mem_write, 1'b1);
    #(CLK_PERIOD);
    `CHECK(DUT.state, cu_pkg::memory_write_state)
    // Wait to enter writeback state
    tb_memory_acknowledge = 1'b1;
    #(CLK_PERIOD);
    `CHECK(DUT.state, cu_pkg::writeback_state);

    // ************************************************************************
    // Test Case 8: ld a, (bc)
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("ld a, (bc)");
    send_opcode(8'h0A);
    `CHECK(DUT.state, cu_pkg::decode_state)
    #(CLK_PERIOD);
    `CHECK(DUT.state, cu_pkg::memory_read_state)
    `CHECK(DUT.imm_i, 16'b0);
    `CHECK(DUT.r1_is_imm, 1'b0);
    `CHECK(DUT.r1_imm, 16'b0);
    `CHECK(DUT.r2_is_imm, 1'b1);
    `CHECK(DUT.r2_imm, 16'h0000);
    `CHECK(DUT.reg_mem_addr_read_sel, cu_pkg::bc_register_select);
    `CHECK(DUT.reg_write_sel, cu_pkg::a_register_select);
    `CHECK(DUT.alu_op, alu_pkg::ADD8);
    `CHECK(DUT.opcode_requires_mem_read, 1'b1);
    #(CLK_PERIOD);
    `CHECK(DUT.state, cu_pkg::memory_read_state)

    // ************************************************************************
    // Test Case 9: halt
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("halt");
    send_opcode(8'h76);
    `CHECK(DUT.state, cu_pkg::decode_state)
    // Should not change over a long time
    #(CLK_PERIOD * 10);
    `CHECK(DUT.state, cu_pkg::decode_state)
    #(CLK_PERIOD * 10);
    `CHECK(DUT.state, cu_pkg::decode_state)


    $display("Simulation complete");
    tb_done = 1;
  end
endmodule
