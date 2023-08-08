`timescale 1ns / 10ps

module memory_controller_tb();
      // Define parameters
  parameter CLK_PERIOD        = 100;
  parameter NORM_DATA_PERIOD  = (10 * CLK_PERIOD);
  
  localparam OUTPUT_CHECK_DELAY = (CLK_PERIOD - 0.2);

  //DUT input
  logic tb_clk, tb_nrst, tb_mem_write_en, tb_mem_read_en, tb_dbl_byte_en;
  logic [7:0] tb_data_from_mem;
  logic [15:0] tb_data_in, tb_input_handler, tb_address;
  logic [7:0] tb_programmable_gpio_in;

  //DUT output
  logic tb_wr, tb_ack;
  logic [7:0] tb_data_to_mem;
  logic [15:0] tb_address_to_mem, tb_data_output;

  // Test bench debug signals
  // Overall test case number for reference
  integer tb_test_num;
  string  tb_test_case;
  logic   tb_mismatch;
  integer tb_done;

  //DUT output expected
  logic expected_tb_wr, expected_tb_ack, tb_check;
  logic [7:0] expected_tb_data_to_mem;
  logic [15:0] expected_tb_address_to_mem, expected_tb_data_output;

  memory_controller DUT(
    .hwclk(tb_clk),
    .nrst(tb_nrst),
    .mem_write_en(tb_mem_write_en),
    .mem_read_en(tb_mem_read_en),
    .dbl_byte_en(tb_dbl_byte_en),
    .data_from_mem(tb_data_from_mem),
    .data_in(tb_data_in),
    .input_handler(tb_input_handler),
    .address(tb_address),
    .programmable_gpio_in(tb_programmable_gpio_in),
    .wr(tb_wr),
    .ack(tb_ack),
    .data_to_mem(tb_data_to_mem),
    .address_to_mem(tb_address_to_mem),
    .data_output(tb_data_output),
    .programmable_gpio_wr(),
    .programmable_gpio_out(),
    .ss7(),
    .ss6(),
    .ss5(),
    .ss4(),
    .ss3(),
    .ss2(),
    .ss1(),
    .ss0()
  );

  task deactivate_signals;
  begin
    expected_tb_wr = 1'b0;
    expected_tb_ack = 1'b0;
    expected_tb_data_to_mem = 8'b0;
    expected_tb_address_to_mem = 16'hzzzz;
    expected_tb_data_output = 16'b0;
    tb_mem_write_en = 0;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 0;
    tb_data_in = 16'b0;
    tb_input_handler = 16'b0;
    tb_address = 16'b0;
  end
  endtask

  initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
  end

  task start_testcase;
  begin
  #(CLK_PERIOD * 3);

  deactivate_signals();
  reset_dut();
  $display("\n===============MC: Starting test case %0d===============\n", tb_test_num);
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

    @(posedge tb_clk);
    @(posedge tb_clk);
  end
  endtask

    task check_output;
        input string test_name;
    begin
        @(negedge tb_clk);
        tb_mismatch = 1'b0;
        tb_check = 1;
        assert (tb_wr == expected_tb_wr)
            $info ("Test case %0d: wr correct", tb_test_num);
        else begin
            $error ("Test case %0d: wr incorrect", tb_test_num);
            #(CLK_PERIOD);
            $fatal;
        end

        assert (tb_ack == expected_tb_ack)
            $info ("Test case %0d: ack correct", tb_test_num);
        else begin
            $error ("Test case %0d: ack incorrect", tb_test_num);
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

        assert (tb_data_output == expected_tb_data_output)
            $info ("Test case %0d: data_output correct", tb_test_num);
        else begin
            $error ("Test case %0d: data_output incorrect", tb_test_num);
            #(CLK_PERIOD);
            $fatal;
        end
        #(0.1);
        tb_check = 0;
    end
    endtask

  always
  begin : CLK_GEN
    tb_clk <= 1'b0;
    #(CLK_PERIOD / 2);
    tb_clk <= 1'b1;
    #(CLK_PERIOD / 2);
  end

  always_comb begin
    case(tb_address_to_mem)
    16'h7774: tb_data_from_mem = 8'h11;
    16'h7775: tb_data_from_mem = 8'h22;
    16'h7776: tb_data_from_mem = 8'h33;
    16'h7777: tb_data_from_mem = 8'h44;
    16'h9985: tb_data_from_mem = 8'h10;
    16'h9986: tb_data_from_mem = 8'h32;
    16'h9987: tb_data_from_mem = 8'h54;
    16'h9988: tb_data_from_mem = 8'h76;
    16'h9989: tb_data_from_mem = 8'h98;
    16'h9990: tb_data_from_mem = 8'hBA;
    16'h9991: tb_data_from_mem = 8'hDC;
    16'h9992: tb_data_from_mem = 8'hD1;
    16'h9993: tb_data_from_mem = 8'h83;
    16'h9994: tb_data_from_mem = 8'h1C;
    16'h9995: tb_data_from_mem = 8'h7E;
    16'h9996: tb_data_from_mem = 8'h42;
    16'h9997: tb_data_from_mem = 8'h90;
    16'h9998: tb_data_from_mem = 8'h6F;
    default: tb_data_from_mem = 8'hFF;
    endcase
  end

  initial begin
    tb_done                   = 0;
    tb_test_num               = -1;
    tb_test_case              = "TB Init";

    //input signal initial
    tb_mem_write_en = 0;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 0;

    tb_data_in = '0;
    tb_input_handler = '0;
    tb_address = '0;

    //expected output initial;
    expected_tb_wr = 0;
    expected_tb_ack = 0;
    expected_tb_data_to_mem = 0;
    expected_tb_address_to_mem = 16'hzzzz;
    expected_tb_data_output = 0;

    // Get away from Time = 0
    #0.1; 

    //****************************************
    // Test case 0: Basic Power on Reset
    tb_test_num  = 0;
    tb_test_case = "Power-on-Reset";
    start_testcase();
    
    //input signals
    tb_mem_write_en = 1;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 0;

    tb_data_in = 16'h3456;
    tb_input_handler = 16'b0;
    tb_address = 16'h2828;

    //expected output
    reset_dut;

    check_output("reset");

    //****************************************
    // Test case 1: read 8 bits, do not reset

    tb_test_num  = 1;
    tb_test_case = "Read-8-Bits";
    start_testcase();

    tb_mem_write_en = 0;
    tb_mem_read_en = 1;
    tb_dbl_byte_en = 0;
    tb_data_in = 16'b0;
    tb_input_handler = 16'b0;
    tb_address = 16'h9997;
  
    // TODO: too long
    #(CLK_PERIOD*5);
    expected_tb_wr = 0;
    expected_tb_ack = 1;
    expected_tb_data_to_mem = 8'b0; 
    expected_tb_address_to_mem = 16'h9997;
    expected_tb_data_output = 16'h0090;
    check_output("Read 8 bits");
    #(CLK_PERIOD);
    tb_mem_read_en = 0;
    #(CLK_PERIOD);

    //****************************************
    // Test case 2: read 16 bits, do not reset

    tb_test_num  = 2;
    tb_test_case = "Read-16-Bits";
    start_testcase();

    tb_mem_write_en = 0;
    tb_mem_read_en = 1;
    tb_dbl_byte_en = 1;
    tb_data_in = 16'b0;
    tb_input_handler = 16'b0;
    tb_address = 16'h9985;

    // TODO: too long
    #(CLK_PERIOD*8);
    expected_tb_wr = 0;
    expected_tb_ack = 1'b1;
    expected_tb_data_to_mem = 8'b0; 
    expected_tb_address_to_mem = 16'h9986;
    expected_tb_data_output = 16'h3210;
    check_output("Read 16 bits");
    #(CLK_PERIOD);
    tb_mem_read_en = 0;
    #(CLK_PERIOD*4);

    //****************************************
    // Test case 3: write 8 bits, do not reset

    tb_test_num  = 3;
    tb_test_case = "Write-8-Bits";
    start_testcase();

    tb_mem_write_en = 1;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 0;
    tb_data_in = 16'h3333;
    tb_input_handler = 16'b0;
    tb_address = 16'h9997;

    // TODO: too long
    #(CLK_PERIOD*5);
    expected_tb_wr = 1;
    expected_tb_ack = 1;
    expected_tb_data_to_mem = 8'h33; 
    expected_tb_address_to_mem = 16'h9997;
    expected_tb_data_output = 16'h0;
    check_output("Write 8 bits");
    #(CLK_PERIOD);
    tb_mem_write_en = 0;
    #(CLK_PERIOD*4);

    //****************************************
    // Test case 4: write 16 bits, do not reset

    tb_test_num  = 4;
    tb_test_case = "Write-16-Bits";
    start_testcase();

    tb_mem_write_en = 1;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 1;
    tb_data_in = 16'h7654;
    tb_input_handler = 16'b0;
    tb_address = 16'h9992;

    // TODO: too long
    #(CLK_PERIOD*8);
    expected_tb_wr = 1;
    expected_tb_ack = 1;
    expected_tb_data_to_mem = 8'h76;
    expected_tb_address_to_mem = 16'h9991;
    expected_tb_data_output = 16'h0;
    check_output("Write 8 bits");
    #(CLK_PERIOD);
    tb_mem_write_en = 0;
    #(CLK_PERIOD*4);

    //****************************************
    // Test case 5: write 8 bits, (to ROM)

    tb_test_num  = 5;
    tb_test_case = "Write-8-Bits";
    start_testcase();

    tb_mem_write_en = 1;
    tb_mem_read_en = 0;
    tb_dbl_byte_en = 0;
    tb_data_in = 16'b0;
    tb_input_handler = 16'b0;
    tb_address = 16'h7775;

    // TODO: too long
    #(CLK_PERIOD*5);
    expected_tb_wr = 0;
    expected_tb_ack = 0;
    expected_tb_data_to_mem = 8'b0; 
    expected_tb_address_to_mem = 16'hzzzz;
    expected_tb_data_output = 16'h0;
    check_output("Write 8 bits");
    #(CLK_PERIOD);
    tb_mem_read_en = 0;
    #(CLK_PERIOD*4);

    //****************************************
    // Test case 6: read 8 bits, (with input handler)

    tb_test_num  = 6;
    tb_test_case = "Read-8-Bits";
    start_testcase();

    tb_mem_write_en = 0;
    tb_mem_read_en = 1;
    tb_dbl_byte_en = 0;
    tb_data_in = 16'h0;
    tb_input_handler = 16'h0629;
    tb_address = 16'hFFB0;

    #(CLK_PERIOD);
    expected_tb_wr = 0;
    expected_tb_ack = 1;
    expected_tb_data_to_mem = 8'b0; 
    expected_tb_address_to_mem = 16'hzzzz;
    expected_tb_data_output = 16'h29;
    check_output("Read 8 bits");
    tb_mem_read_en = 0;

    //****************************************
    // Test case 7: read 16 bits, (with input handler)

    tb_test_num  = 7;
    tb_test_case = "Read-16-Bits";
    start_testcase();

    tb_mem_write_en = 0;
    tb_mem_read_en = 1;
    tb_dbl_byte_en = 1;
    tb_data_in = 16'h0;
    tb_input_handler = 16'h0629;
    tb_address = 16'hFFB0;

    expected_tb_wr = 0;
    expected_tb_ack = 1;
    expected_tb_data_to_mem = 8'b0; 
    expected_tb_address_to_mem = 16'hzzzz;
    expected_tb_data_output = 16'h0629;
  
    check_output("Read 8 bits");
    tb_mem_read_en = 0;
    #(CLK_PERIOD*4);

    //****************************************
    // Test case 5: read 16 bits, then test a period
    // that does not read nor write but with input signals
    // test if the output is being known invalid
    tb_done = 1;
  end


endmodule
