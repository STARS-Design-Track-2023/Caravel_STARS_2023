`default_nettype none
`include "source/control_unit/cu_pkg.sv"

`define MAP_TO_REG(SEL, TO)                                     \
    case ((SEL))                                                \
        cu_pkg::a_register_select      : TO = {8'b0, reg_a};    \
        cu_pkg::b_register_select      : TO = {8'b0, reg_b};    \
        cu_pkg::c_register_select      : TO = {8'b0, reg_c};    \
        cu_pkg::d_register_select      : TO = {8'b0, reg_d};    \
        cu_pkg::e_register_select      : TO = {8'b0, reg_e};    \
        cu_pkg::f_register_select      : TO = {8'b0, reg_f};    \
        cu_pkg::h_register_select      : TO = {8'b0, reg_h};    \
        cu_pkg::l_register_select      : TO = {8'b0, reg_l};    \
        cu_pkg::af_register_select     : TO = {reg_a, reg_f};   \
        cu_pkg::bc_register_select     : TO = {reg_b, reg_c};   \
        cu_pkg::de_register_select     : TO = {reg_d, reg_e};   \
        cu_pkg::hl_register_select     : TO = {reg_h, reg_l};   \
        cu_pkg::phl_register_select    : TO = {reg_h, reg_l};   \
        cu_pkg::sp_register_select     : TO = reg_sp;           \
        cu_pkg::pc_register_select     : TO = pc_i;             \
        cu_pkg::memory_register_select : TO = reg_mem;          \
        default                        : TO = 0;                \
    endcase

module register_file #(parameter RESET_ADDR=16'hff00) (
    // Inputs
    // From top
    input logic clk, nrst,
    // From instruction decoder
    input logic write_en,
    input cu_pkg::decoded_instruction instruction,
    input cu_pkg::id_state id_state,
    input cu_pkg::register_select reg_write_sel, r1_sel, r2_sel, reg_mem_addr_read_sel, reg_mem_addr_write_sel,
    // From ALU
    input logic [15:0] reg_update,
    input cu_pkg::f_register next_f,
    // From Memory
    input logic mem_ack,
    input logic [15:0] mem_data,
    // From PC
    input logic [15:0] pc_i,
    // Outputs
    // To control logic
    output logic [15:0] r1, r2, reg_mem_addr_read, reg_mem_addr_write,
    output cu_pkg::f_register reg_f,
    // To PC
    output logic [15:0] pc_o
);
    // Register values (not including reg_f)
    logic [7:0] reg_a, reg_b, reg_c, reg_d, reg_e, reg_h, reg_l;
    logic [15:0] reg_sp, reg_mem;

    // Next write value for registers and stack pointer
    logic [15:0] next_write, next_sp;

    // Select write source logic
    assign next_write = reg_update;

    // Logic for next stack pointer
    always_comb begin
        case(instruction)
            cu_pkg::push_op: next_sp = reg_sp - 2;
            cu_pkg::call_op: next_sp = reg_sp - 2;
            cu_pkg::pop_op:  next_sp = reg_sp + 2;
            cu_pkg::ret_op:  next_sp = reg_sp + 2;
            cu_pkg::reti_op: next_sp = reg_sp + 2;
            default:         next_sp = reg_sp;
        endcase
    end

    // Register block and logic to update registers
    always_ff @ (posedge clk, negedge nrst) begin
        if (!nrst) begin
            {reg_a, reg_b, reg_c, reg_d, reg_e, reg_f,
                reg_h, reg_l, reg_mem} <= 0;
            reg_sp <= RESET_ADDR;
        end
        else begin
            if (mem_ack) reg_mem <= mem_data;
            if (id_state == cu_pkg::writeback_state) reg_f <= next_f;
            if (write_en && reg_write_sel == cu_pkg::sp_register_select) reg_sp <= next_write;
            else if (id_state == cu_pkg::writeback_state) reg_sp <= next_sp;
            case(reg_write_sel)
                cu_pkg::a_register_select: if (write_en) reg_a <= next_write[7:0];
                cu_pkg::b_register_select: if (write_en) reg_b <= next_write[7:0];
                cu_pkg::c_register_select: if (write_en) reg_c <= next_write[7:0];
                cu_pkg::d_register_select: if (write_en) reg_d <= next_write[7:0];
                cu_pkg::e_register_select: if (write_en) reg_e <= next_write[7:0];
                cu_pkg::h_register_select: if (write_en) reg_h <= next_write[7:0];
                cu_pkg::l_register_select: if (write_en) reg_l <= next_write[7:0];
                cu_pkg::af_register_select: if (write_en) {reg_a, reg_f} <= next_write;
                cu_pkg::bc_register_select: if (write_en) {reg_b, reg_c} <= next_write;
                cu_pkg::de_register_select: if (write_en) {reg_d, reg_e} <= next_write;
                cu_pkg::hl_register_select: if (write_en) {reg_h, reg_l} <= next_write;
                default: ;
            endcase
        end
    end

    // Output to PC. PC logic handles clocking so signal forwarding should be
    // combinational
    assign pc_o = (reg_write_sel == cu_pkg::pc_register_select) ? next_write : 16'b0;

    // Read from register logic
    always_comb begin
        `MAP_TO_REG(r1_sel, r1);
        `MAP_TO_REG(r2_sel, r2);
        `MAP_TO_REG(reg_mem_addr_read_sel, reg_mem_addr_read);
        `MAP_TO_REG(reg_mem_addr_write_sel, reg_mem_addr_write);
    end

endmodule
