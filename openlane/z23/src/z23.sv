`default_nettype none
`include "control_unit/cu_pkg.sv"
`include "interrupt_handler/ih_pkg.sv"
`include "alu/alu_pkg.sv"

module z23(
    input logic clk, nrst,
    input logic [7:0] memory_data_in,
    input logic [7:0] programmable_gpio_in,
    input logic interrupt_gpio_in,
    input logic [15:0] keypad_input,
    output logic [15:0] memory_address_out,
    output logic [7:0] memory_data_out,
    output logic [7:0] programmable_gpio_out,
    output logic memory_wr,
    output logic [7:0] programmable_gpio_wr,
    output logic [7:0] ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0
);
    logic [15:0] ih_in_sync;
    logic [15:0] cu_mem_data_out, cu_mem_addr, cu_op1, cu_op2;
    logic cu_dbl_byte_en, cu_mem_write_en, cu_mem_read_en;
    logic mc_ack;
    logic [15:0] mc_data_output;
    cu_pkg::f_register alu_flag;
    /* verilator lint_off UNUSEDSIGNAL */
    cu_pkg::f_register cu_alu_f;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [15:0] alu_result;
    alu_pkg::alu_op cu_alu_op_o;
    logic [31:0] timer_duration;
    logic cu_interrupts_enabled;
    logic timer_enable;
    logic ih_interrupt_requested, cu_interrupt_ack;
    ih_pkg::interrupt_source ih_interrupt_source;
    logic [7:0] gpio_interrupt_pins, gpio_interrupt_mask;
    logic mc_input_handler_enable;

    interrupt_handler ih(
        .clk(clk),
        .nrst(nrst),
        .gpio_interrupt_pins(gpio_interrupt_pins),
        .gpio_interrupt_mask(gpio_interrupt_mask),
        .timer_enable(timer_enable),
        .timer_duration(timer_duration),
        .interrupt_pin(interrupt_gpio_in),
        .input_handler_enable(mc_input_handler_enable),
        .input_handler_source(keypad_input),
        .interrupts_enabled(cu_interrupts_enabled),
        .interrupt_ack(cu_interrupt_ack),
        .input_handler_output(ih_in_sync),
        .interrupt_requested(ih_interrupt_requested),
        .interrupt_source(ih_interrupt_source)
    );

    control_unit cu (
        .clk(clk),
        .nrst(nrst),
        .mem_data_in(mc_data_output),
        .mem_ack(mc_ack),
        .alu_result(alu_result),
        .alu_f_in(alu_flag),
        .interrupt_requested(ih_interrupt_requested),
        .interrupt_source(ih_interrupt_source),
        .mem_data_out(cu_mem_data_out),
        .mem_addr(cu_mem_addr),
        .dbl_byte_en(cu_dbl_byte_en),
        .mem_write_en(cu_mem_write_en),
        .mem_read_en(cu_mem_read_en),
        .alu_f(cu_alu_f),
        .op1(cu_op1),
        .op2(cu_op2),
        .alu_op_o(cu_alu_op_o),
        .interrupts_enabled(cu_interrupts_enabled),
        .interrupt_ack(cu_interrupt_ack)
    );

    memory_controller mc (
        .hwclk(clk),
        .nrst(nrst),
        .mem_write_en(cu_mem_write_en),
        .mem_read_en(cu_mem_read_en),
        .dbl_byte_en(cu_dbl_byte_en),
        .data_in(cu_mem_data_out),
        .input_handler(ih_in_sync),
        .address(cu_mem_addr),
        .data_from_mem(memory_data_in),
        .programmable_gpio_in(programmable_gpio_in),

        .wr(memory_wr),
        .ack(mc_ack),
        .data_to_mem(memory_data_out),
        .address_to_mem(memory_address_out),
        .data_output(mc_data_output),
        .programmable_gpio_wr(programmable_gpio_wr),
        .programmable_gpio_out(programmable_gpio_out),
        .ss7(ss7),
        .ss6(ss6),
        .ss5(ss5),
        .ss4(ss4),
        .ss3(ss3),
        .ss2(ss2),
        .ss1(ss1),
        .ss0(ss0),
        .gpio_interrupt_pins(gpio_interrupt_pins),
        .gpio_interrupt_mask(gpio_interrupt_mask),
        .timer_enable(timer_enable),
        .timer_duration(timer_duration),
        .input_handler_enable(mc_input_handler_enable)
    );

    alu alu (
        .Cin(cu_alu_f.c),
        .alu_op(cu_alu_op_o),
        .X(cu_op1),
        .Y(cu_op2),
        .flag(alu_flag),
        .result(alu_result)
    );
endmodule
