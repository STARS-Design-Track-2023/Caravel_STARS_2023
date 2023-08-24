/********************************************
 Top Level testbench

 Testbench: tb_Eighty_Twos.sv
 Source: Eighty_Twos.sv

 Inputs:  clk
          n_rst
          cs
          gpi[33:0]
 Outputs:  gpo[33:0]
 
 Author: Xinyu Yang
*********************************************/


`timescale 1ns/10ps

module tb_Eighty_Twos ();

  /***************************************************************************************
   Signals Declaration
  ***************************************************************************************/

  // Declare Timing Parameters
  localparam CLK_PERIOD        = 100;
  localparam PROPAGATION_DELAY = 1.1; // FF propogation delay

  // Declare Test Case Signals
  integer tb_test_num;
  string  tb_test_case;
  string  tb_check_tag;
  logic   tb_checking;
  logic   tb_mismatch;

  // Declare DUT Connection Signals
  // input
  logic           tb_clk;
  logic           tb_n_rst;
  logic           tb_cs;
  // input/output
  logic [33:0]    tb_gpi;
  logic [33:0]    tb_gpo;

  // Declare TestBench Signals
  logic [7:0]     tb_expected_data;


  /***************************************************************************************
   Clock generation block
  ***************************************************************************************/

  always begin
    tb_clk = 1'b0;
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    #(CLK_PERIOD/2.0);
  end


  /***************************************************************************************
   Task Declaration
  ***************************************************************************************/

  // Task for standard DUT reset
  task reset_dut;
  begin
    // Enable reset
    tb_n_rst = 1'b0;
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    // Disable reset
    tb_n_rst = 1'b1;
    //@(negedge tb_clk);
    //@(negedge tb_clk);
  end
  endtask

  // Task to inactivate input signals before starting a new testcase
  task inactivate_inputs;
  begin
    @(negedge tb_clk);
    tb_n_rst     = 1'b1;
    tb_cs        = 1'b0;
    tb_gpi       = '0;
    @(posedge tb_clk);
    @(negedge tb_clk);
  end
  endtask

  // Task to check DUT output values
  task check_output;
    input string check_tag;
  begin
    tb_mismatch = 1'b0;
    tb_checking    = 1'b1;

    // Check output 'data'
    if(tb_expected_data == tb_gpo[7:0]) begin
      $display("Correct 'tb_data' output %s during %s test case", check_tag, tb_test_case);
    end
    else begin
      tb_mismatch = 1'b1;
      $error("Incorrect 'tb_data' output %s during %s test case", check_tag, tb_test_case);
    end

    #(0.1);
    tb_checking = 1'b0;
    tb_mismatch = 1'b0;
  end
  endtask


  /***************************************************************************************
   DUT Portmap
  ***************************************************************************************/

  Eighty_Twos DUT 
  (
    .clk(tb_clk), 
    .nrst(tb_n_rst), 
    .cs(tb_cs), 
    .gpi(tb_gpi),
    .gpo(tb_gpo)
  );


  /***************************************************************************************
   Signal Dump
  ***************************************************************************************/

  initial begin
    $dumpfile ("dump.vcd");
    $dumpvars;
  end
  

  /***************************************************************************************
   Test Cases
  ***************************************************************************************/
  initial begin
    // Initialize all of the test signals
    inactivate_inputs();
    tb_test_num   = 0;
    tb_test_case  = "Test bench initializaton";
    tb_check_tag  = "N/A";
    tb_checking   = 1'b0;
    tb_mismatch   = 1'b0;

    // Wait some time before starting first test case
    #(0.1);
    

    // ************************************************************************
    // Test Case 1: Increment Accumulator
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Increment Accumulator";

    // Start out with inactive value and reset the DUT to isolate from prior tests
    inactivate_inputs();
    reset_dut();
   // @(negedge tb_clk);

    tb_cs = 1;

    // Test
    //Instruction 1 MVI A 
    //tb_gpi[23] = 0;
    //@(posedge tb_clk);
    //@(negedge tb_clk);
    tb_gpi[23] = 0;
    tb_gpi[7:0] = 8'h3E;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd68;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    
    //Instruction 2 INR A
    tb_gpi[7:0] = 8'h3C;
    @(posedge tb_clk);
    @(negedge tb_clk);    
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 3 STAX D
    tb_gpi[7:0] = 8'h12;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[23] = 1;
    @(posedge tb_clk);
    @(negedge tb_clk); 

    //Expected Output
    tb_expected_data = 8'd69;
    #(0.1);
    check_output("Increment Accumulator");

    // ************************************************************************
    // Test Case 2: Add Register to Accumulator
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Add Register to Accumulator";

    // Start out with inactive value and reset the DUT to isolate from prior tests
    inactivate_inputs();
    reset_dut();
   // @(negedge tb_clk);

    tb_cs = 1;

    // Test
    //Instruction 1 MVI D 
    tb_gpi[23] = 0;
    tb_gpi[7:0] = 8'h16;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd21;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 2 MVI A 
    tb_gpi[7:0] = 8'h3E;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd80;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    
    //Instruction 3 ADD D
    tb_gpi[7:0] = 8'h82;
    @(posedge tb_clk);
    @(negedge tb_clk);    
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 4 STAX B
    tb_gpi[7:0] = 8'h02;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[23] = 1;
    @(posedge tb_clk);
    @(negedge tb_clk); 

    //Expected Output
    tb_expected_data = 8'd101;
    #(0.1);
    check_output("Add Register to Accumulator");

    // ************************************************************************
    // Test Case 3: Load Immediate and Or Result
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Load Immediate and Or Result";

    // Start out with inactive value and reset the DUT to isolate from prior tests
    inactivate_inputs();
    reset_dut();
   // @(negedge tb_clk);

    tb_cs = 1;

    // Test
    //Instruction 1 LXI H 
    tb_gpi[23] = 0;
    tb_gpi[7:0] = 8'h21;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'b10101010;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'b11110000;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 2 MOV A,L 
    tb_gpi[7:0] = 8'h7D;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);
    
    //Instruction 3 ORA H
    tb_gpi[7:0] = 8'hB4;
    @(posedge tb_clk);
    @(negedge tb_clk);    
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 4 STAX B
    tb_gpi[7:0] = 8'h02;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[23] = 1;
    @(posedge tb_clk);
    @(negedge tb_clk); 

    //Expected Output
    tb_expected_data = 8'b11111010;
    #(0.1);
    check_output("Load Immediate and Or Result");

/*
    // ************************************************************************
    // Test Case 4: Multiply Instructions
    // ************************************************************************
    tb_test_num  = tb_test_num + 1;
    tb_test_case = "Multiply Instructions";

    // Start out with inactive value and reset the DUT to isolate from prior tests
    inactivate_inputs();
    reset_dut();
   // @(negedge tb_clk);

    tb_cs = 1;
    tb_gpi[23] = 0;

    // Test
    //Instruction 1 MVI C,80 
    tb_gpi[7:0] = 8'h0E;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd80;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 2 MVI D,88 
    tb_gpi[7:0] = 8'h16;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd88;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 3 MVI B,0 
    tb_gpi[7:0] = 8'h06;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd0;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 4 MVI E,9 
    tb_gpi[7:0] = 8'h1E;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd9;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 5 MOV A,C
    tb_gpi[7:0] = 8'h7A;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 6 RAR
    tb_gpi[7:0] = 8'h1F;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 7 MOV C,A
    tb_gpi[7:0] = 8'h4F;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 8 DCR E
    tb_gpi[7:0] = 8'h1D;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 9 JZ DONE
    tb_gpi[7:0] = 8'hCA;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd26; //Could be wrong
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd0; 
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 10 MOV A,B
    tb_gpi[7:0] = 8'h78;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 11 JNC MULT1
    tb_gpi[7:0] = 8'hD2;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd21; //Could be wrong
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd0; 
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 12 ADD D
    tb_gpi[7:0] = 8'h82;
    @(posedge tb_clk);
    @(negedge tb_clk);    
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 13 RAR
    tb_gpi[7:0] = 8'h1F;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 14 MOV B,A
    tb_gpi[7:0] = 8'h47;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 15 JMP MULT0
    tb_gpi[7:0] = 8'hC3;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd9; //Could be wrong
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'd0; 
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);    

    //Instruction 16 MOV A,B
    tb_gpi[7:0] = 8'h78;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 17 MVI D
    tb_gpi[7:0] = 8'h16;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'h00;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 18 MVI E
    tb_gpi[7:0] = 8'h1E;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'h00;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 19 STAX D
    tb_gpi[7:0] = 8'h12;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[23] = 1;
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Expected Output
    tb_expected_data = 8'h1B;
    #(0.1);
    check_output("Multiply Instructions");

    //Instruction 20 MOV A,C
    tb_gpi[23] = 0;
    tb_gpi[7:0] = 8'h79;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 17 MVI D
    tb_gpi[7:0] = 8'h16;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'h00;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Instruction 18 MVI E
    tb_gpi[7:0] = 8'h1E;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[7:0] = 8'h00;
    @(posedge tb_clk);
    @(negedge tb_clk);
    @(posedge tb_clk);
    @(negedge tb_clk);


    //Instruction 23 STAX D
    tb_gpi[7:0] = 8'h12;
    @(posedge tb_clk);
    @(negedge tb_clk);
    tb_gpi[23] = 1;
    @(posedge tb_clk);
    @(negedge tb_clk);

    //Expected Output
    tb_expected_data = 8'h80;
    #(0.1);
    check_output("Multiply Instructions");
*/

    $display("Simulation complete");
    $stop;
  end

endmodule