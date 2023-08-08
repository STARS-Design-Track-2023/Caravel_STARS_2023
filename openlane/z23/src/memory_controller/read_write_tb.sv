`timescale 1ns / 10ps

module read_write_tb();
      // Define parameters
  parameter CLK_PERIOD        = 100;

  //DUT input

  logic tb_ack, tb_clk, tb_mem_write_en, tb_mem_read_en, tb_dbl_byte_en, tb_cmp, tb_nrst;
  logic [15:0] tb_data_in, tb_input_handler, tb_address;

  //DUT output
  logic tb_enable, tb_cmp_o, tb_wr;
  logic [3:0] tb_max;
  logic [7:0] tb_data_to_mem;
  logic [15:0] tb_address_to_mem;

  // Test bench debug signals
  // Overall test case number for reference
  integer tb_test_num;
  string  tb_test_case;
  integer tb_done;

  //test case expected output
  logic tb_check, expected_tb_enable, expected_tb_cmp_o, expected_tb_wr;
  logic [3:0] expected_tb_max;
  logic [7:0] expected_tb_data_to_mem;
  logic [15:0] expected_tb_address_to_mem;

  //DUT protmap
  read_write DUT(
    .ack(tb_ack),
    .clk(tb_clk),
    .nrst (tb_nrst),
    .mem_write_en(tb_mem_write_en),
    .mem_read_en(tb_mem_read_en),
    .dbl_byte_en(tb_dbl_byte_en),
    .cmp(tb_cmp),
    .data_in(tb_data_in),
    //.input_handler(tb_input_handler),
    .address(tb_address),
    .enable(tb_enable),
    .cmp_o(tb_cmp_o),
    .wr(tb_wr),
    .max(tb_max),
    .data_to_mem(tb_data_to_mem),
    .address_to_mem(tb_address_to_mem)
  );

  task deactivate_signals;
  begin
    expected_tb_enable = 1'b0;
    expected_tb_cmp_o = 1'b0;
    expected_tb_wr = 1'b0;
    expected_tb_address_to_mem = 16'hzzzz;
    tb_mem_write_en = 0;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 0;
    tb_cmp = 0;
    tb_nrst = 0;
    tb_data_in = 16'b0;
    //tb_input_handler = 8'b0;
    tb_address = 16'b0;
    tb_ack = 0;
  end
  endtask

  task start_testcase;
  begin

    deactivate_signals();
    reset_dut();
    $display("\n===============RW: Starting test case %0d===============\n", tb_test_num);
  end
  endtask

  task reset_dut;
    begin
    // Activate the design's reset (does not need to be synchronize with clock)
    tb_nrst = 1'b0;

    // Wait for a couple clock cycles
    @(posedge tb_clk);
    @(posedge tb_clk);

    // Release the reset
    @(negedge tb_clk);
    tb_nrst = 1;

    // Wait for a while before activating the design
    @(posedge tb_clk);
    @(posedge tb_clk);
  end
  endtask

  task check_output;
      input string test_name;
  begin
    //@(negedge tb_clk);
    tb_check = 1;

    assert (tb_enable == expected_tb_enable)
      $info ("Test case %0d: enable correct", tb_test_num);
    else begin
      $error ("Test case %0d: enable incorrect", tb_test_num);
      #(CLK_PERIOD);
      $fatal;
    end

    assert (tb_cmp_o == expected_tb_cmp_o)
      $info ("Test case %0d: cmp_o correct", tb_test_num);
    else begin
      $error ("Test case %0d: cmp_o incorrect", tb_test_num);
      #(CLK_PERIOD);
      $fatal;
    end

    assert (tb_wr == expected_tb_wr)
      $info ("Test case %0d: wr correct", tb_test_num);
    else begin
      $error ("Test case %0d: wr incorrect", tb_test_num);
      #(CLK_PERIOD);
      $fatal;
    end

    assert (tb_max == expected_tb_max)
      $info ("Test case %0d: max correct", tb_test_num);
    else begin
      $error ("Test case %0d: max incorrect", tb_test_num);
      #(CLK_PERIOD);
      $fatal;
    end

    assert (tb_data_to_mem == expected_tb_data_to_mem)
      $info ("Test case %0d: data_to_mem correct", tb_test_num);
    else begin
      $error ("Test case %0d: data_to_mem incorrect", tb_test_num);
      #(CLK_PERIOD);
      $fatal;
    end

    assert (tb_address_to_mem === expected_tb_address_to_mem)
      $info ("Test case %0d: address_to_mem correct", tb_test_num);
    else begin
      $error ("Test case %0d: address_to_mem incorrect", tb_test_num);
      #(CLK_PERIOD);
      $fatal;
    end

    #(0.1)
    tb_check = 0;
  end
  endtask

  always begin
    tb_clk <= 1'b0;
    #(CLK_PERIOD / 2);
    tb_clk <= 1'b1;
    #(CLK_PERIOD / 2);
  end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
end

  initial begin
    tb_done                   = 0;
    tb_test_num               = -1;
    tb_test_case              = "TB Init";

    //input signal initial
    tb_mem_write_en = 0;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 0;
    tb_cmp = 0;
    tb_nrst = 1;
    tb_ack = 0;

    tb_data_in = '0;
    //tb_input_handler = '0;
    tb_address = '0;

    //expected output initial;
    expected_tb_enable = 0;
    expected_tb_cmp_o = 0;
    expected_tb_wr = 0;
    expected_tb_max = 2;
    expected_tb_data_to_mem = 0;
    expected_tb_address_to_mem = 0;

    // Get away from Time = 0
    #0.1;


    //****************************************
    // Test case 0: Basic Power on Reset

    tb_test_num  = 0;
    tb_test_case = "Power-on-Reset";
    start_testcase();

    //make no difference value here
    tb_mem_write_en = 0;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 0;
    tb_cmp = 0;
    tb_nrst = 1;

    tb_data_in = 16'h1234;
    //tb_input_handler = '0;
    tb_address = '0;

    #(CLK_PERIOD);
    reset_dut;

    check_output("Power-on-Reset");
    #(CLK_PERIOD);

    //****************************************
    // Test case 1: read 8 bits

    tb_test_num  = 1;
    tb_test_case = "Read-8-Bits-Before";
    start_testcase();

    tb_mem_write_en = 0;
    tb_mem_read_en = 1;
    tb_dbl_byte_en = 0;
    tb_cmp = 0;
    tb_nrst = 1;
    tb_data_in = 16'b0;
    tb_address = 16'h1234;

    #(CLK_PERIOD*2);

    expected_tb_enable = 1;
    expected_tb_cmp_o = 0;
    expected_tb_wr = 0;
    expected_tb_max = 4'b10;
    expected_tb_data_to_mem = 8'b0; 
    expected_tb_address_to_mem = 16'h1234;
  
    #(CLK_PERIOD);
    check_output("Read 8 bits BEFORE");
    #(CLK_PERIOD);

    //**** TEST 2
    tb_test_num  = 2;
    tb_test_case = "Read-8-Bits-After";
    
    tb_cmp = 1;
    #(CLK_PERIOD*2);
    tb_mem_read_en = 0;

    expected_tb_enable = 1;
    expected_tb_cmp_o = 1;
    expected_tb_wr = 0;
    expected_tb_max = 4'b10;
    expected_tb_data_to_mem = 8'b0; 
    expected_tb_address_to_mem = 16'h1234;

    check_output("Read 8 bits AFTER");

    //****************************************
    // Test case 3: read 16 bits

    tb_test_num  = 3;
    tb_test_case = "Read-16-Bits";
    start_testcase();

    #(CLK_PERIOD);

    tb_mem_write_en = 0;
    tb_mem_read_en = 1;
    tb_dbl_byte_en = 1;
    tb_cmp = 0;
    tb_nrst = 1;
    tb_data_in = 16'b0;
    tb_address = 16'h100;

    #(CLK_PERIOD*2);

    expected_tb_enable = 1;
    expected_tb_cmp_o = 0;
    expected_tb_wr = 0;
    expected_tb_max = 4'b10;
    expected_tb_data_to_mem = 8'b0; 
    expected_tb_address_to_mem = 16'h100;

    #(CLK_PERIOD);

    check_output("Read 16 bits BEFORE");
    #(CLK_PERIOD);

    //**** TEST 4
    tb_test_num  = 4;
    tb_test_case = "Read-16-Bits-After-CMP";
    
    tb_cmp = 1;

    #(CLK_PERIOD*2);

    expected_tb_enable = 1;
    expected_tb_cmp_o = 1;
    expected_tb_wr = 0;
    expected_tb_max = 4'b10;
    expected_tb_data_to_mem = 8'b0; 
    expected_tb_address_to_mem = 16'h101;

    check_output("Read 16 bits AFTER");
    #(CLK_PERIOD*2);

    reset_dut;

    //****************************************
    // Test case 5: write 8 bits

    tb_test_num  = 5;
    tb_test_case = "Write-8-Bits-Before";
    start_testcase();

    tb_mem_write_en = 1;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 0;
    tb_cmp = 0;
    tb_nrst = 1;
    tb_data_in = 16'h4321;
    tb_address = 16'h89AB;

    #(CLK_PERIOD*2);

    expected_tb_enable = 1;
    expected_tb_cmp_o = 0;
    expected_tb_wr = 1;
    expected_tb_max = 4'b10;
    expected_tb_data_to_mem = 8'h21;
    expected_tb_address_to_mem = 16'h89AB;

    #(CLK_PERIOD);
    check_output("Write 8 bits BEFORE");
    #(CLK_PERIOD);

    //**** TEST 6
    tb_test_num  = 6;
    tb_test_case = "Write-8-Bits-After";
    
    tb_cmp = 1;
    #(CLK_PERIOD*2);
    tb_mem_read_en = 0;

    expected_tb_enable = 1;
    expected_tb_cmp_o = 1;
    expected_tb_wr = 1;
    expected_tb_max = 4'b10;
    expected_tb_data_to_mem = 8'h21; 
    expected_tb_address_to_mem = 16'h89AB;

    check_output("Read 8 bits AFTER");

    //****************************************
    // Test case 7: write 16 bits

    tb_test_num  = 7;
    tb_test_case = "Write-16-Bits-Before";
    start_testcase();

    tb_mem_write_en = 1;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 1;
    tb_cmp = 0;
    tb_nrst = 1;
    tb_data_in = 16'h4569;
    tb_address = 16'h9988;

    #(CLK_PERIOD*2);

    expected_tb_enable = 1;
    expected_tb_cmp_o = 0;
    expected_tb_wr = 1;
    expected_tb_max = 4'b10;
    expected_tb_data_to_mem = 8'h69;
    expected_tb_address_to_mem = 16'h9986;

    #(CLK_PERIOD);
    check_output("Write 8 bits BEFORE");
    #(CLK_PERIOD);

    //**** TEST 8
    tb_test_num  = 8;
    tb_test_case = "Write-8-Bits-After-1-CMP";
    
    tb_cmp = 1;
    #(CLK_PERIOD);
    tb_cmp = 0;
    #(CLK_PERIOD);

    expected_tb_enable = 1;
    expected_tb_cmp_o = 0;
    expected_tb_wr = 1;
    expected_tb_max = 4'b10;
    expected_tb_data_to_mem = 8'h45;
    expected_tb_address_to_mem = 16'h9987;

    #(CLK_PERIOD*2);
    check_output("Write 16 bits AFTER 1 CMP");
    #(CLK_PERIOD);

    reset_dut;

    tb_done = 1;
  end
endmodule
