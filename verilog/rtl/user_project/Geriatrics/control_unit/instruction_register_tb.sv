`timescale 1ns/10ps

module instruction_register_tb ();

  // 10MHz Clock Rate
  localparam CLK_PERIOD        = 100;
  
  // 10MHz D-FF Timing Constraints
  localparam PROPAGATION_DELAY = 1.1; // Allow for 1.1ns for FF propogation delay

  // TB-Specific Localparams
  localparam  VALUE = 8'b0;

  // Inactive Inputs and Reset Output Values
  localparam  INACTIVE_INPUT = 0;
  localparam  CLEAR_ASSERTED = 1'b0;
  localparam  RESET_OUTPUT_VALUE = 0;

  // Declare Test Case Signals
  integer tb_test_total;
  integer tb_test_correct;
  string  tb_test_case_name;
  logic   tb_mismatch;
  logic   tb_check;
  integer tb_done;

  // Declare DUT Connection Signals
  logic   tb_clk;
  logic   tb_nrst;
  logic   tb_hold, tb_mem_ack, tb_clear;
  logic   [7:0] tb_data;
  logic   [7:0] tb_opcode_o;
  logic   [15:0] tb_immediate;


  // Declare the Test Bench Signals for Expected Results
  logic [1:0] tb_expected_idx;
  logic [7:0] tb_expected_opcode_o;
  logic [15:0] tb_expected_immediate;

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
    tb_data = INACTIVE_INPUT;
    tb_hold = INACTIVE_INPUT;
    tb_mem_ack = INACTIVE_INPUT;
    tb_clear = INACTIVE_INPUT;
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

    // Check DUT.idx
    if(tb_expected_idx == DUT.idx) begin // Check passed
      $display("Correct idx %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect idx %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_idx, DUT.idx);
      tb_test_total = tb_test_total + 1;
    end

    // Check opcode_o
    if(tb_expected_opcode_o == tb_opcode_o) begin // Check passed
      $display("Correct opcode_o %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect opcode_o %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_opcode_o, tb_opcode_o);
      tb_test_total = tb_test_total + 1;
    end

    // Check opcode_o
    if(tb_expected_immediate == tb_immediate) begin // Check passed
      $display("Correct opcode_o %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect opcode_o %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_immediate, tb_immediate);
      tb_test_total = tb_test_total + 1;
    end

    // Wait some small amount of time so check pulse timing is visible on waves
    #(0.1);
    tb_check = 1'b0;
  end
  endtask

  // DUT Portmap
  instruction_register DUT 
  (
    .clk(tb_clk), 
    .nrst(tb_nrst),
    .data(tb_data),
    .hold(tb_hold),
    .mem_ack(tb_mem_ack),
    .clear(tb_clear),
    .opcode_o(tb_opcode_o),
    .immediate(tb_immediate)
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
    tb_expected_idx = RESET_OUTPUT_VALUE;
    tb_expected_opcode_o = RESET_OUTPUT_VALUE;
    tb_expected_immediate = RESET_OUTPUT_VALUE;
    check_output("after reset applied");

    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    tb_expected_idx = RESET_OUTPUT_VALUE;
    tb_expected_opcode_o = RESET_OUTPUT_VALUE;
    tb_expected_immediate = RESET_OUTPUT_VALUE;
    check_output("after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(negedge tb_clk);
    tb_nrst = 1'b1;   // Deactivate the chip reset

    // Check that internal state was correctly keep after reset release
    #(PROPAGATION_DELAY);
    tb_expected_idx = RESET_OUTPUT_VALUE;
    tb_expected_opcode_o = RESET_OUTPUT_VALUE;
    tb_expected_immediate = RESET_OUTPUT_VALUE;
    check_output("after reset was released");

    // ************************************************************************
    // Test Case 2: Test Whole Operation
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("Test Whole Operation");

    #(0.5)
    tb_data = 8'h32;
    tb_mem_ack = 1'b1;

    // After loading to opcode_o
    #(CLK_PERIOD);
    tb_expected_idx = 2'b01;
    tb_expected_opcode_o = tb_data;
    tb_expected_immediate = 16'b0;
    check_output("after loading to opcode_o");

    // Deativate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After loading to immediate low
    tb_data = 8'h21;
    tb_mem_ack = 1'b1;
    #(CLK_PERIOD);
    tb_expected_idx = 2'b10;
    tb_expected_opcode_o = 8'h32;
    tb_expected_immediate = {8'b0, tb_data};
    check_output("after loading to immediate low");

    // Deativate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After loading to immediate high
    tb_data = 8'h15;
    tb_mem_ack = 1'b1;
    #(CLK_PERIOD);
    tb_expected_idx = 2'b11;
    tb_expected_opcode_o = 8'h32;
    tb_expected_immediate = {tb_data, 8'h21};
    check_output("after loading to immediate high");

    // Deativate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);
    tb_expected_idx = 2'b11;
    tb_expected_opcode_o = 8'h32;
    tb_expected_immediate = {8'h15, 8'h21};
    check_output("after deactivating signals and waiting a few clock cycles");

    // While activating hold
    tb_mem_ack = 1'b1;
    tb_hold = 1'b1;
    tb_data = 8'h24;
    #(CLK_PERIOD);
    tb_expected_idx = 2'b11;
    tb_expected_opcode_o = 8'h32;
    tb_expected_immediate = {8'h15, 8'h21};
    check_output("while activating hold");

    $display("SIMULATION COMPLETE: %2d out of %2d tests passed", tb_test_correct ,tb_test_total);
    tb_done = 1;
  end

endmodule
