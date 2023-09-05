`default_nettype none
`include "control_unit/cu_pkg.sv"
`include "alu/alu_pkg.sv"
`include "interrupt_handler/ih_pkg.sv"

module control_unit(
    // From top
    input logic clk, nrst,
    // From memory controller
    input logic [15:0] mem_data_in,
    input logic mem_ack,
    // From ALU
    input logic [15:0] alu_result,
    input cu_pkg::f_register alu_f_in,
    // From interrupt controller
    input logic interrupt_requested,
    input ih_pkg::interrupt_source interrupt_source,
    // To memory controller
    output logic [15:0] mem_data_out,
    output logic [15:0] mem_addr,
    output logic dbl_byte_en,
    output logic mem_write_en,
    output logic mem_read_en,
    // To ALU
    output cu_pkg::f_register alu_f,
    output logic [15:0] op1, op2,
    output alu_pkg::alu_op alu_op_o,
    // To interrupt controller
    output logic interrupts_enabled, interrupt_ack
);
    // Internal signals
    logic id_r1_is_imm, id_r2_is_imm, id_reg_file_write_en;
    logic [15:0] id_r1_imm, id_r2_imm;
    logic [15:0] reg_file_r1, reg_file_r2;
    logic [15:0] pc_pc_o, reg_file_pc_o, reg_file_reg_mem_addr_read, reg_file_reg_mem_addr_write, id_mem_addr_imm;
    cu_pkg::mem_req_source_sel id_mem_addr_read_source_sel, id_mem_addr_write_source_sel;
    cu_pkg::decoded_instruction id_instr_to_reg_file;
    cu_pkg::id_state id_state;
    cu_pkg::register_select id_r1_sel, id_r2_sel, id_reg_write_sel, id_reg_mem_addr_read_sel, id_reg_mem_addr_write_sel;
    cu_pkg::f_register id_f_out;
    logic [7:0] ir_opcode_o, reg_file_reg_f, id_pc_offset;
    logic [15:0] ir_immediate;
    logic id_hold, id_clear;
    logic id_next_instr_req, id_cond_true, id_call_or_jump, id_jump_is_relative;

    // Assign alu_f
    assign alu_f = reg_file_reg_f;

    // Forward signals to ALU
    always_comb begin
        // Forward op1
        if (id_r1_is_imm) op1 = id_r1_imm;
        else op1 = reg_file_r1;

        // Forward op2
        if (id_r2_is_imm) op2 = id_r2_imm;
        else op2 = reg_file_r2;
    end

    // Mux out mem_addr
    always_comb begin
        if (mem_write_en) begin
            case (id_mem_addr_write_source_sel)
                cu_pkg::value_from_pc       : mem_addr = pc_pc_o;
                cu_pkg::value_from_reg_file : mem_addr = reg_file_reg_mem_addr_write;
                cu_pkg::value_from_imm      : mem_addr = id_mem_addr_imm;
                default                     : mem_addr = 16'b0;
            endcase
        end else if (mem_read_en) begin
            case (id_mem_addr_read_source_sel)
                cu_pkg::value_from_pc       : mem_addr = pc_pc_o;
                cu_pkg::value_from_reg_file : mem_addr = reg_file_reg_mem_addr_read;
                cu_pkg::value_from_imm      : mem_addr = id_mem_addr_imm;
                default                     : mem_addr = pc_pc_o;
            endcase
        end
        else
            mem_addr = pc_pc_o;
    end

    // Forward signals to memory controller
    always_comb begin
        mem_data_out = alu_result;
    end

    register_file reg_file(
        .clk(clk),
        .nrst(nrst),
        .write_en(id_reg_file_write_en),
        .instruction(id_instr_to_reg_file),
        .id_state(id_state),

        .r1_sel(id_r1_sel),
        .r2_sel(id_r2_sel),
        .reg_write_sel(id_reg_write_sel),
        .reg_mem_addr_read_sel(id_reg_mem_addr_read_sel),
        .reg_mem_addr_write_sel(id_reg_mem_addr_write_sel),

        .reg_update(alu_result),
        .next_f(id_f_out),
        .mem_ack(mem_ack),
        .mem_data(mem_data_in),
        .pc_i(pc_pc_o),
        .r1(reg_file_r1),
        .r2(reg_file_r2),
        .reg_mem_addr_read(reg_file_reg_mem_addr_read),
        .reg_mem_addr_write(reg_file_reg_mem_addr_write),
        .reg_f(reg_file_reg_f),
        .pc_o(reg_file_pc_o)
    );
    instruction_decoder id(
        .clk(clk),
        .nrst(nrst),

        .opcode(ir_opcode_o),
        .imm_i(ir_immediate),

        .alu_f_in(alu_f_in),

        .memory_acknowledge(mem_ack),

        .interrupt_requested(interrupt_requested),
        .interrupt_source(interrupt_source),

        .clear(id_clear),
        .hold(id_hold),

        .next_instr_req(id_next_instr_req),
        .cond_true(id_cond_true),
        .jump_is_relative(id_jump_is_relative),
        .call_or_jump(id_call_or_jump),
        .pc_offset(id_pc_offset),

        .f_out(id_f_out),

        .r1_sel(id_r1_sel),
        .r2_sel(id_r2_sel),
        .reg_write_sel(id_reg_write_sel),
        .reg_mem_addr_read_sel(id_reg_mem_addr_read_sel),
        .reg_mem_addr_write_sel(id_reg_mem_addr_write_sel),
        .reg_file_write_en(id_reg_file_write_en),
        .f_in(reg_file_reg_f),
        .instr_to_reg_file(id_instr_to_reg_file),

        .alu_op(alu_op_o),

        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .dbl_byte_en(dbl_byte_en),

        .mem_addr_read_source_sel(id_mem_addr_read_source_sel),
        .mem_addr_write_source_sel(id_mem_addr_write_source_sel),
        .r1_imm(id_r1_imm),
        .r2_imm(id_r2_imm),
        .r1_is_imm(id_r1_is_imm),
        .r2_is_imm(id_r2_is_imm),
        .mem_addr_imm(id_mem_addr_imm),
        .state(id_state),

        .interrupts_enabled(interrupts_enabled),
        .interrupt_ack(interrupt_ack)
    );
    instruction_register ir(
        .clk(clk),
        .nrst(nrst),
        .data(mem_data_in[7:0]),
        .mem_ack(mem_ack),
        .hold(id_hold),
        .clear(id_clear),
        .opcode_o(ir_opcode_o),
        .immediate(ir_immediate)
    );
    program_counter pc(
        .clk(clk),
        .nrst(nrst),
        .next_instruction_request(id_next_instr_req),
        .condition_is_true(id_cond_true),
        .jump_is_relative(id_jump_is_relative),
        .call_or_jump(id_call_or_jump),
        .offset(id_pc_offset),
        .absolute(reg_file_pc_o),
        .pc_o(pc_pc_o)
    );
endmodule
