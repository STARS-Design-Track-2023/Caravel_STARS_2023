`include "source/control_unit/cu_pkg.sv"

`timescale 1ns/10ps

module program_counter_tb ();

  // 10MHz Clock Rate
  localparam CLK_PERIOD = 100;

  // 10MHz D-FF Timing Constraints
  localparam PROPAGATION_DELAY = 1.1; // Allow for 1.1ns for FF propogation delay

  // Inactive Inputs and Reset Output Values
  localparam  INACTIVE_INPUT = 0;
  localparam  RESET_ADDR = 16'h1000;

  // Declare Test Case Signals
  integer tb_test_total;
  integer tb_test_correct;
  string  tb_test_case_name;
  logic   tb_mismatch;
  logic   tb_check;
  integer tb_done;

  // Declare DUT Connection Signals
  logic tb_clk;
  logic tb_nrst;
  logic tb_next_instruction_request;
  logic tb_condition_is_true;
  logic tb_jump_is_relative;
  logic tb_call_or_jump;
  logic [7:0] tb_offset;
  logic [15:0] tb_absolute;
  logic [15:0] tb_pc_o;

  // Declare the Test Bench Signals for Expected Results
  logic [15:0] tb_expected_pc_o;

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
    tb_test_total = 0;
    tb_test_correct = 0;
    tb_test_case_name = "Test Bench Initializaton";
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

  // Set input signals to zero (or NULL) before starting with new testcases
  task deactivate_signals;
  begin
    tb_next_instruction_request = INACTIVE_INPUT;
    tb_condition_is_true = INACTIVE_INPUT;
    tb_jump_is_relative = INACTIVE_INPUT;
    tb_call_or_jump = INACTIVE_INPUT;
    tb_offset = INACTIVE_INPUT;
    tb_absolute = INACTIVE_INPUT;
  end
  endtask

  // Set input signals to zero before starting with new testcases
  task start_testcase;
    input string test_case_name;
  begin
    // Space test case out from previous test case
    #(CLK_PERIOD * 3);

    // Set name and number
    tb_test_case_name = test_case_name;

    // Reset and deactivate DUT
    deactivate_signals();
    reset_dut();
  end
  endtask

  // Task to cleanly and consistently check DUT output values
  task check_output;
    input string check_tag;
  begin
    tb_mismatch = 1'b0;
    tb_check    = 1'b1;

    // Check pc_o
    if(tb_expected_pc_o == tb_pc_o) begin // Check passed
      $display("Correct pc_o %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect pc_o %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_pc_o, tb_pc_o);
      tb_test_total = tb_test_total + 1;
    end

    // Wait some small amount of time so check and mismatch pulse timing is visible on waves
    #(0.1);
    tb_check = 1'b0;
    tb_mismatch = 1'b0;
  end
  endtask

  // DUT Portmap
  program_counter DUT
  (
    .clk(tb_clk),
    .nrst(tb_nrst),
    .next_instruction_request(tb_next_instruction_request),
    .condition_is_true(tb_condition_is_true),
    .jump_is_relative(tb_jump_is_relative),
    .call_or_jump(tb_call_or_jump),
    .offset(tb_offset),
    .absolute(tb_absolute),
    .pc_o(tb_pc_o)
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
    // Test Case 1: Power-on Reset of the DUT
    // ************************************************************************
    tb_test_case_name = "Power on Reset";
    // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
    // Wait some time before applying test case stimulus
    #(0.1);
    // Apply test case initial stimulus
    deactivate_signals();
    tb_nrst = 1'b0; // Manually enable chip reset

    // Wait for a bit before checking for correct functionality
    #(CLK_PERIOD * 0.5);

    // Check that internal state was correctly reset
    tb_expected_pc_o = RESET_ADDR;
    check_output("after reset applied");

    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    tb_expected_pc_o = RESET_ADDR;
    check_output("after clock cycle while in reset");

    // Release the reset away from a clock edge
    @(negedge tb_clk);
    tb_nrst = 1'b1;   // Deactivate the chip reset

    // Check that internal state was correctly keep after reset release
    #(PROPAGATION_DELAY);
    tb_expected_pc_o = RESET_ADDR;
    check_output("after reset was released");

    // ************************************************************************
    // Test Case 2: Test General Operation
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("Test General Operation");

    // Wait a little before starting testing
    #(0.5)

    // While leaving the next_intruction_request inactive
    tb_jump_is_relative = 1'b1;
    tb_offset = 8'h1f;
    #(CLK_PERIOD);
    tb_expected_pc_o = RESET_ADDR;
    check_output("while leaving the next_intruction_request inactive");

    // After waiting and activating next_instruction_request
    #(CLK_PERIOD * 3);
    tb_next_instruction_request = 1'b1;
    #(CLK_PERIOD);
    tb_expected_pc_o = 16'h1001;
    check_output("after waiting and activating next_instruction_request");

    // After waiting and activating condition_is_true
    #(CLK_PERIOD * 3);
    tb_condition_is_true = 1'b1;
    #(CLK_PERIOD);
    tb_expected_pc_o = 16'h1023;
    check_output("after waiting and activating condition_is_true");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After making another relative jump
    tb_next_instruction_request = 1'b1;
    tb_condition_is_true = 1'b1;
    tb_jump_is_relative = 1'b1;
    tb_offset = 8'h98;
    #(CLK_PERIOD);
    tb_expected_pc_o = 16'h0fbb;
    check_output("after making another relative jump");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After incrementing pc
    tb_next_instruction_request = 1'b1;
    tb_condition_is_true = 1'b1;
    tb_offset = 8'h32;
    tb_absolute = 16'h4543;
    #(CLK_PERIOD);
    tb_expected_pc_o = 16'h0fbc;
    check_output("after incrementing pc");

    // After waiting 3 clock cycles
    #(CLK_PERIOD * 3);
    tb_expected_pc_o = 16'h0fbf;
    check_output("after waiting 3 clock cycles");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After making jump
    tb_next_instruction_request = 1'b1;
    tb_condition_is_true = 1'b1;
    tb_call_or_jump = 1'b1;
    tb_absolute = 16'h7843;
    #(CLK_PERIOD);
    tb_expected_pc_o = 16'h7843;
    check_output("after making jump");

    // After incrementing for a while
    tb_call_or_jump = 1'b0;
    #(CLK_PERIOD * 3);
    tb_expected_pc_o = 16'h7846;
    check_output("after incrementing for a while");

    // After making a final relative jump
    tb_jump_is_relative = 1'b1;
    tb_offset = 8'h84;
    #(CLK_PERIOD);
    tb_expected_pc_o = 16'h77ca;
    check_output("after making a final relative jump");

    // ************************************************************************
    // Test Case 3: Test Asynchronous Reset
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("Test Asynchronous Reset");

    // Wait a little before starting testing
    #(0.5)

    // After loading pc
    tb_next_instruction_request = 1'b1;
    tb_condition_is_true = 1'b1;
    tb_call_or_jump = 1'b1;
    tb_absolute = 16'h9821;
    #(CLK_PERIOD);
    tb_expected_pc_o = 16'h9821;
    check_output("after loading pc");

    // After resetting pc
    tb_nrst = 1'b0;
    #(PROPAGATION_DELAY);  // wait for flip-flop propagation delay
    tb_expected_pc_o = RESET_ADDR;
    check_output("after resetting pc");

    // After waiting while resetting
    #(CLK_PERIOD * 3);
    tb_expected_pc_o = RESET_ADDR;
    check_output("after waiting while resetting");

    $display("SIMULATION COMPLETE: %2d out of %2d tests passed", tb_test_correct, tb_test_total);
    tb_done = 1;
  end

endmodule
