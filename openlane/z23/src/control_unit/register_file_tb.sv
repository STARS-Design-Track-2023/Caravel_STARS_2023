`include "designs/z23/src/control_unit/cu_pkg.sv"

`timescale 1ns/10ps

module register_file_tb ();

  // 10MHz Clock Rate
  localparam CLK_PERIOD = 100;
  
  // 10MHz D-FF Timing Constraints
  localparam PROPAGATION_DELAY = 1.1; // Allow for 1.1ns for FF propogation delay

  // Inactive Inputs and Reset Output Values
  localparam  INACTIVE_INPUT = 0;
  localparam  RESET_OUTPUT_VALUE = 0;
  localparam  RESET_ADDR = 16'hff00;

  // Declare Test Case Signals
  integer tb_test_total;
  integer tb_test_correct;
  string  tb_test_case_name;
  logic   tb_mismatch;
  logic   tb_check;
  integer tb_done;

  // Declare DUT Connection Signals
  // Inputs
  logic                         tb_clk;
  logic                         tb_nrst;
  logic                         tb_write_en;
  cu_pkg::decoded_instruction   tb_instruction;
  cu_pkg::id_state              tb_id_state;
  cu_pkg::register_select       tb_reg_write_sel;
  cu_pkg::register_select       tb_r1_sel;
  cu_pkg::register_select       tb_r2_sel;
  cu_pkg::register_select       tb_reg_mem_addr_read_sel;
  cu_pkg::register_select       tb_reg_mem_addr_write_sel;
  logic [15:0]                  tb_reg_update;
  cu_pkg::f_register            tb_next_f;
  logic                         tb_mem_ack;
  logic [15:0]                  tb_mem_data;
  logic [15:0]                  tb_pc_i;
  // Outputs
  logic [15:0]                  tb_r1;
  logic [15:0]                  tb_r2;
  logic [15:0]                  tb_reg_mem_addr_read;
  logic [15:0]                  tb_reg_mem_addr_write;
  cu_pkg::f_register            tb_reg_f;
  logic [15:0]                  tb_pc_o;


  // Declare the Test Bench Signals for Expected Results
  logic [15:0]                  tb_expected_r1;
  logic [15:0]                  tb_expected_r2;
  logic [15:0]                  tb_expected_reg_mem_addr_read;
  logic [15:0]                  tb_expected_reg_mem_addr_write;
  cu_pkg::f_register            tb_expected_reg_f;
  logic [15:0]                  tb_expected_pc_o;

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

  // Set input signals to zero (or NULL) before starting with new testcases
  task deactivate_signals;
  begin
    tb_write_en = INACTIVE_INPUT;
    tb_mem_ack = INACTIVE_INPUT;
    tb_instruction = cu_pkg::nop_op;
    tb_id_state = cu_pkg::fetch_state;
    tb_reg_write_sel = cu_pkg::a_register_select;
    tb_r1_sel = cu_pkg::a_register_select;
    tb_r2_sel = cu_pkg::a_register_select;
    tb_reg_mem_addr_read_sel = cu_pkg::a_register_select;
    tb_reg_mem_addr_write_sel = cu_pkg::a_register_select;
    tb_reg_update = INACTIVE_INPUT;
    tb_next_f = INACTIVE_INPUT;
    tb_mem_data = INACTIVE_INPUT;
    tb_pc_i = INACTIVE_INPUT;
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

    // Check r1
    if(tb_expected_r1 == tb_r1) begin // Check passed
      $display("Correct r1 %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect r1 %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_r1, tb_r1);
      tb_test_total = tb_test_total + 1;
    end

    // Check r2
    if(tb_expected_r2 == tb_r2) begin // Check passed
      $display("Correct r2 %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect r2 %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_r2, tb_r2);
      tb_test_total = tb_test_total + 1;
    end

    // Check reg_mem_addr_read
    if(tb_expected_reg_mem_addr_read == tb_reg_mem_addr_read) begin // Check passed
      $display("Correct reg_mem_addr_read %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect reg_mem_addr_read %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_reg_mem_addr_read, tb_reg_mem_addr_read);
      tb_test_total = tb_test_total + 1;
    end

    // Check reg_mem_addr_write
    if(tb_expected_reg_mem_addr_write == tb_reg_mem_addr_write) begin // Check passed
      $display("Correct reg_mem_addr_write %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect reg_mem_addr_write %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_reg_mem_addr_write, tb_reg_mem_addr_write);
      tb_test_total = tb_test_total + 1;
    end

    // Check reg_f
    if(tb_expected_reg_f == tb_reg_f) begin // Check passed
      $display("Correct reg_f %s during %s test case.", check_tag, tb_test_case_name);
      tb_test_total = tb_test_total + 1;
      tb_test_correct = tb_test_correct + 1;
    end
    else begin // Check failed
      tb_mismatch = 1'b1;
      $error("Incorrect reg_f %s during %s test case. Expected %h, got %h.", check_tag, tb_test_case_name, tb_expected_reg_f, tb_reg_f);
      tb_test_total = tb_test_total + 1;
    end

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

    // Wait some small amount of time so check pulse timing is visible on waves
    #(0.1);
    tb_check = 1'b0;
    tb_mismatch = 1'b0;
  end
  endtask

  // DUT Portmap
  register_file #(.RESET_ADDR(RESET_ADDR)) DUT(
    .clk(tb_clk),
    .nrst(tb_nrst),
    .write_en(tb_write_en),
    .instruction(tb_instruction),
    .id_state(tb_id_state),

    .r1_sel(tb_r1_sel),
    .r2_sel(tb_r2_sel),
    .reg_write_sel(tb_reg_write_sel),
    .reg_mem_addr_read_sel(tb_reg_mem_addr_read_sel),
    .reg_mem_addr_write_sel(tb_reg_mem_addr_write_sel),

    .reg_update(tb_reg_update),
    .next_f(tb_next_f),
    .mem_ack(tb_mem_ack),
    .mem_data(tb_mem_data),
    .pc_i(tb_pc_i),
    .r1(tb_r1),
    .r2(tb_r2),
    .reg_mem_addr_read(tb_reg_mem_addr_read),
    .reg_mem_addr_write(tb_reg_mem_addr_write),
    .reg_f(tb_reg_f),
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
    tb_expected_r1 = RESET_OUTPUT_VALUE;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after reset applied");

    // Check that the reset value is maintained during a clock cycle
    #(CLK_PERIOD);
    tb_expected_r1 = RESET_OUTPUT_VALUE;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after clock cycle while in reset");
    
    // Release the reset away from a clock edge
    @(negedge tb_clk);
    tb_nrst = 1'b1;   // Deactivate the chip reset

    // Check that internal state was correctly keep after reset release
    #(PROPAGATION_DELAY);
    tb_expected_r1 = RESET_OUTPUT_VALUE;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after reset was released");

    // ************************************************************************
    // Test Case 2: Test General Operation
    // ************************************************************************
    // Start Testcase, Task finishes at Negedge
    start_testcase("Test General Operation");

    // Wait a little before starting testing
    #(0.5)

    // After setting reg_update and mem_data inputs
    tb_reg_update = 16'h4367;
    tb_mem_data = 16'h6453;
    tb_r2_sel = cu_pkg::b_register_select;
    #(CLK_PERIOD);
    tb_expected_r1 = RESET_OUTPUT_VALUE;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after setting reg_update and mem_data inputs");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After writing to reg_b from from reg_update
    tb_write_en = 1'b1;
    tb_reg_write_sel = cu_pkg::b_register_select;
    tb_reg_mem_addr_write_sel = cu_pkg::b_register_select;
    tb_r2_sel = cu_pkg::b_register_select;
    tb_reg_update = 16'h2456;
    #(CLK_PERIOD);
    tb_expected_r1 = RESET_OUTPUT_VALUE;
    tb_expected_r2 = 16'h0056;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = 16'h0056;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after writing to reg_b from reg_update");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After writing to reg_f from input
    tb_id_state = cu_pkg::writeback_state;
    tb_next_f = 8'h67;
    tb_r1_sel = cu_pkg::f_register_select;
    tb_r2_sel = cu_pkg::de_register_select;
    #(CLK_PERIOD);
    tb_expected_r1 = 16'h0067;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = 8'h67;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after writing to reg_f from input");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After writing to stack pointer
    tb_write_en = 1'b1;
    tb_reg_update = 16'hff34;
    tb_reg_write_sel = cu_pkg::sp_register_select;
    tb_r1_sel = cu_pkg::sp_register_select;
    #(CLK_PERIOD);
    tb_expected_r1 = 16'hff34;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = 8'h67;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after writing to stack pointer");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After updating stack pointer (pop)
    tb_mem_ack = 1'b1;
    tb_mem_data = 16'hff21;
    tb_id_state = cu_pkg::writeback_state;
    tb_instruction = cu_pkg::pop_op;
    tb_reg_write_sel = cu_pkg::memory_register_select;
    tb_reg_mem_addr_read_sel = cu_pkg::memory_register_select;
    tb_r1_sel = cu_pkg::sp_register_select;
    tb_r2_sel = cu_pkg::de_register_select;
    #(CLK_PERIOD);
    tb_expected_r1 = 16'hff36;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = 16'hff21;
    tb_expected_reg_mem_addr_write = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after updating stack pointer (pop)");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After updating stack pointer (push)
    tb_write_en = 1'b1;
    tb_id_state = cu_pkg::writeback_state;
    tb_mem_data = 16'h3456;
    tb_reg_write_sel = cu_pkg::af_register_select;
    tb_instruction = cu_pkg::push_op;
    tb_r1_sel = cu_pkg::sp_register_select;
    tb_r2_sel = cu_pkg::af_register_select;
    #(CLK_PERIOD);
    tb_expected_r1 = 16'hff34;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = RESET_OUTPUT_VALUE;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after updating stack pointer (push)");

    // After deactivating and waiting a clock cycle
    deactivate_signals();
    tb_r1_sel = cu_pkg::sp_register_select;
    tb_r2_sel = cu_pkg::af_register_select;
    tb_reg_mem_addr_write_sel = cu_pkg::memory_register_select;
    #(CLK_PERIOD);
    tb_expected_r1 = 16'hff34;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = 16'hff21;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    check_output("after deactivating and waiting a clock cycle");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After writing to pc
    tb_reg_write_sel = cu_pkg::pc_register_select;
    tb_reg_update = 16'hee45;
    tb_reg_mem_addr_write_sel = cu_pkg::memory_register_select;
    tb_r1_sel = cu_pkg::de_register_select;
    tb_r2_sel = cu_pkg::af_register_select;
    #(CLK_PERIOD);
    tb_expected_r1 = RESET_OUTPUT_VALUE;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = 16'hff21;
    tb_expected_pc_o = 16'hee45;
    check_output("after writing to pc");

    // Deactivate signals and wait a few clock cycles
    deactivate_signals();
    #(CLK_PERIOD * 5);

    // After reading from pc
    tb_pc_i = 16'hff87;
    tb_mem_ack = 1'b1;
    tb_mem_data = 16'hee45;
    tb_reg_mem_addr_read_sel = cu_pkg::memory_register_select;
    tb_r1_sel = cu_pkg::pc_register_select;
    tb_r2_sel = cu_pkg::de_register_select;
    #(CLK_PERIOD);
    tb_expected_r1 = 16'hff87;
    tb_expected_r2 = RESET_OUTPUT_VALUE;
    tb_expected_reg_f = RESET_OUTPUT_VALUE;
    tb_expected_pc_o = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_write = RESET_OUTPUT_VALUE;
    tb_expected_reg_mem_addr_read = 16'hee45;
    check_output("after reading from pc");

    $display("SIMULATION COMPLETE: %2d out of %2d tests passed", tb_test_correct, tb_test_total);
    tb_done = 1;
  end

endmodule
