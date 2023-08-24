`include "source/alu/alu_pkg.sv"
`include "source/control_unit/cu_pkg.sv"

`timescale 1ns/10ps

module alu_tb ();

  // 10MHz Clock Rate
  localparam CLK_PERIOD = 100;

  // Inactive Inputs and Reset Output Values
  localparam INACTIVE_INPUT = 0;
  localparam CLEAR_ASSERTED = 1'b0;

  // Declare Test Case Signals
  integer tb_test_total;
  integer tb_test_correct;
  string  tb_test_case_name;
  logic   tb_mismatch;
  logic   tb_check;
  integer tb_done;

  // Declare DUT Connection Signals
  logic tb_Cin;
  alu_pkg::alu_op tb_alu_op;
  cu_pkg::f_register tb_flag;
  logic [15:0] tb_X, tb_Y, tb_result;

  // Declare the Test Bench Signals for Expected Results
  cu_pkg::f_register tb_expected_flag;
  logic [15:0] tb_expected_result;

  task start_dut;
  begin
    // Init Test Case Meta Variables
    tb_test_total = 0;
    tb_test_correct = 0;
    tb_test_case_name = "Test Bench Initializaton";
    tb_mismatch = 1'b0;
    tb_check = 1'b0;
  end
  endtask

  // Set input signals to zero before starting with new testcases
  task deactivate_signals;
  begin
    tb_Cin = INACTIVE_INPUT;
    tb_X = INACTIVE_INPUT;
    tb_Y = INACTIVE_INPUT;
    tb_alu_op = alu_pkg::ADD8;
  end
  endtask

  // Set input signals to zero before starting with new testcases
  task start_testcase;
    input string test_case_name;
  begin
    // Space test case out from previous test case
    #(300);

    // Set name and number
    tb_test_case_name = test_case_name;

    // Deactivate DUT
    deactivate_signals();
  end
  endtask

  // Task to cleanly and consistently check DUT output values
  task check_output;
    input string check_tag;
  begin
    tb_mismatch = 1'b0;
    tb_check = 1'b1;

    // Check result
    if(tb_expected_result == tb_result) begin // Check passed
      $display("Correct result for %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect result for %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_result, tb_result);
      tb_test_total = tb_test_total + 1;
    end

    // Check flag
    if(tb_expected_flag == tb_flag) begin // Check passed
      $display("Correct flag for %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect flag for %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_flag, tb_flag);
      tb_test_total = tb_test_total + 1;
    end

    // Wait some small amount of time so check pulse timing is visible on waves
    #(1);
    tb_check = 1'b0;
  end
  endtask

  // DUT Portmap
  alu DUT
  (
    .Cin(tb_Cin),
    .alu_op(tb_alu_op),
    .X(tb_X),
    .Y(tb_Y),
    .flag(tb_flag),
    .result(tb_result)
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

    // Wait some time before starting first test case
    #(0.1);

    // ************************************************************************
    // Test Case 1: Addition Operations
    // ************************************************************************
    start_testcase("Addition Operations");

    // Add positive numbers
    tb_X = 16'h25;
    tb_Y = 16'h57;
    tb_Cin = 1'b1;
    tb_alu_op = alu_pkg::ADD8;
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'h7c};
    tb_expected_flag = {6'b0, 1'b1, 1'b0};
    check_output("Add positive numbers");

    // Add with carry in
    tb_alu_op = alu_pkg::ADC;
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'h7d};
    tb_expected_flag = {6'b0, 1'b1, 1'b0};
    check_output("Add with carry in");

    // Add positive and negative
    tb_X = {8'b0, 8'h99};
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'hf1};
    tb_expected_flag = {1'b1, 5'b0, 1'b1, 1'b0};
    check_output("Add positive and negative numbers");

    // Add with overflow
    tb_Cin = 1'b0;
    tb_X = {8'b0, 8'h45};
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'h9c};
    tb_expected_flag = {1'b1, 4'b0, 1'b1, 1'b1, 1'b0};
    check_output("Add with overflow");

    // Add with expected carry out
    tb_Cin = 1'b0;
    tb_alu_op = alu_pkg::ADD8;
    tb_Y = {8'b0, 8'he5};
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'h2a};
    tb_expected_flag = {6'b0, 1'b1, 1'b1};
    check_output("Add with expeted carry out");

    // Add 16-bit numbers
    tb_alu_op = alu_pkg::ADD16;
    tb_X = 16'h5678;
    tb_Y = 16'h1245;
    #(CLK_PERIOD);
    tb_expected_result = 16'h68bd;
    tb_expected_flag = {6'b0, 1'b1, 1'b0};
    check_output("Add 16-bit numbers");

    // ************************************************************************
    // Test Case 2: Subtraction Operations
    // ************************************************************************
    // Start Testcase
    start_testcase("Subtraction Operations");

    // Subtract simple
    tb_X = {8'b0, 8'h57};
    tb_Y = {8'b0, 8'h25};
    tb_Cin = 1'b1;
    tb_alu_op = alu_pkg::SUB8;
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'h32};
    tb_expected_flag = 8'b0;
    check_output("Subtract simple");

    // Subtract with borrow
    tb_alu_op = alu_pkg::SBC;
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'h31};
    tb_expected_flag = 8'b0;
    check_output("Subtract with borrow");

    // Subtract with carry out
    tb_Y = {8'b0, 8'h72};
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'he4};
    tb_expected_flag = {1'b1, 4'b0, 2'b0, 1'b1};
    check_output("Subtract with carry out");

    // Subtract with overflow
    tb_Y = {8'b0, 8'h85};
    tb_alu_op = alu_pkg::SUB8;
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'hd2};
    tb_expected_flag = {1'b1, 4'b0, 1'b1, 1'b0, 1'b1};
    check_output("Subtract with overflow");

    // Subtract 16-bit numbers
    tb_alu_op = alu_pkg::SUB16;
    tb_X = 16'h5678;
    tb_Y = 16'h1245;
    #(CLK_PERIOD);
    tb_expected_result = 16'h4433;
    tb_expected_flag = 8'b0;
    check_output("Subtract 16-bit numbers");

    // ************************************************************************
    // Test Case 3: Logical and Shifting Operations
    // ************************************************************************
    start_testcase("Logical and Shifting Operations");

    // AND
    tb_alu_op = alu_pkg::AND;
    tb_X = 16'h3457;
    tb_Y = 16'h3276;
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'h56};
    tb_expected_flag = {5'b0, 1'b1, 2'b0};
    check_output("AND");

    // OR
    tb_alu_op = alu_pkg::OR;
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'h77};
    tb_expected_flag = {5'b0, 1'b1, 2'b0};
    check_output("OR");

    // XOR
    tb_alu_op = alu_pkg::XOR;
    #(CLK_PERIOD);
    tb_expected_result = {8'b0, 8'h21};
    tb_expected_flag = {5'b0, 1'b1, 2'b0};
    check_output("XOR");

    // NOT
    tb_alu_op = alu_pkg::NOT;
    tb_X = 16'h23ff;
    #(CLK_PERIOD);
    tb_expected_result = 16'b0;
    tb_expected_flag = {1'b0, 1'b1, 6'b0};
    check_output("NOT");

    // RR
    tb_alu_op = alu_pkg::RR;
    tb_X = 16'h01;
    #(CLK_PERIOD);
    tb_expected_result = 16'b0;
    tb_expected_flag = {1'b0, 1'b1, 5'b0, 1'b1};
    check_output("RR");

    // RL
    tb_alu_op = alu_pkg::RL;
    tb_X = 16'h2280;
    tb_Cin = 1'b1;
    #(CLK_PERIOD);
    tb_expected_result = 16'h1;
    tb_expected_flag = {7'b0, 1'b1};
    check_output("RL");

    // RRC
    tb_alu_op = alu_pkg::RRC;
    tb_X = 16'h23e1;
    #(CLK_PERIOD);
    tb_expected_result = 16'hf0;
    tb_expected_flag = {1'b1, 6'b0, 1'b1};
    check_output("RRc");

    // RLC
    tb_alu_op = alu_pkg::RLC;
    tb_X = 16'h23e1;
    #(CLK_PERIOD);
    tb_expected_result = 16'hc3;
    tb_expected_flag = {1'b1, 6'b0, 1'b1};
    check_output("RLC");

    $display("SIMULATION COMPLETE: %2d out of %2d tests passed", tb_test_correct, tb_test_total);
    tb_done = 1;
  end

endmodule
