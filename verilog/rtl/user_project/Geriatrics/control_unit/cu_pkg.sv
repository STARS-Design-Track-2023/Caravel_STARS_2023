`ifndef CONTROL_UNIT_PKG
`define CONTROL_UNIT_PKG

`include "Geriatrics/alu/alu_pkg.sv"

`default_nettype none
package cu_pkg;
    typedef enum logic [1:0] {
        not_zero,
        zero,
        not_carry,
        carry
    } condition;

    typedef enum logic [2:0] {
        fetch_state,
        decode_state,
        cb_decode_state,
        wait_for_byte_state,
        wait_for_double_byte_state,
        memory_read_state,
        memory_write_state,
        writeback_state
    } id_state;

    function condition condition_from_opcode_y(logic [1:0] opcode_y);
        case (opcode_y)
            2'b00 : condition_from_opcode_y = not_zero;
            2'b01 : condition_from_opcode_y = zero;
            2'b10 : condition_from_opcode_y = not_carry;
            2'b11 : condition_from_opcode_y = carry;
        endcase
    endfunction

    typedef enum logic [4:0] {
        a_register_select,
        f_register_select,
        b_register_select,
        c_register_select,
        d_register_select,
        e_register_select,
        h_register_select,
        l_register_select,
        af_register_select,
        bc_register_select,
        de_register_select,
        hl_register_select,
        phl_register_select,
        sp_register_select,
        pc_register_select,
        memory_register_select
    } register_select;

    typedef struct packed {
        logic s, z, _unused2, _usused1, _unsused1, v, n, c;
    } f_register;

    typedef enum logic [4:0] {
        nop_op, ld_op, jr_op, jp_op, add_op, adc_op,
        sub_op, sbc_op, and_op, xor_op, or_op, cp_op,
        ret_op, push_op, pop_op, inc_op, dec_op,
        rlca_op, rla_op, scf_op, rrca_op, rra_op, cpl_op,
        ccf_op, halt_op, call_op, cb_op, djnz_op, ei_op,
        di_op, reti_op
    } decoded_instruction;

    typedef enum logic [3:0] {
        rlc_op, rrc_op, rl_op, rr_op, sla_op, sra_op, sll_op, srl_op,
        bit_op, res_op, set_op
    } cb_decoded_instruction;

    function cb_decoded_instruction rotate_from_cb_y(logic [2:0] opcode_y);
        case (opcode_y)
            3'b000 : rotate_from_cb_y = rlc_op;
            3'b001 : rotate_from_cb_y = rrc_op;
            3'b010 : rotate_from_cb_y = rl_op;
            3'b011 : rotate_from_cb_y = rr_op;
            3'b100 : rotate_from_cb_y = sla_op;
            3'b101 : rotate_from_cb_y = sra_op;
            3'b110 : rotate_from_cb_y = sll_op;
            3'b111 : rotate_from_cb_y = srl_op;
        endcase
    endfunction

    function alu_pkg::alu_op alu_op_from_cb_opcode(cb_decoded_instruction cb_op_instr);
        case (cb_op_instr)
            rlc_op  : alu_op_from_cb_opcode = alu_pkg::RLC;
            rrc_op  : alu_op_from_cb_opcode = alu_pkg::RRC;
            rl_op   : alu_op_from_cb_opcode = alu_pkg::RL;
            rr_op   : alu_op_from_cb_opcode = alu_pkg::RR;
            sla_op  : alu_op_from_cb_opcode = alu_pkg::SLA;
            sra_op  : alu_op_from_cb_opcode = alu_pkg::SRA;
            sll_op  : alu_op_from_cb_opcode = alu_pkg::SLL;
            srl_op  : alu_op_from_cb_opcode = alu_pkg::SRL;
            bit_op  : alu_op_from_cb_opcode = alu_pkg::BIT;
            res_op  : alu_op_from_cb_opcode = alu_pkg::RES;
            set_op  : alu_op_from_cb_opcode = alu_pkg::SET;
            default : alu_op_from_cb_opcode = alu_pkg::SET;
        endcase
    endfunction

    typedef enum logic [1:0] {
        value_from_pc,
        value_from_reg_file,
        value_from_imm
    } mem_req_source_sel;
endpackage

`endif
