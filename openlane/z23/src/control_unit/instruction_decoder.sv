`default_nettype none
`include "/home/designer-25/CUP/openlane/z23/src/control_unit/cu_pkg.sv"
`include "/home/designer-25/CUP/openlane/z23/src/alu/alu_pkg.sv"

`define SET_VAR_FROM_COND(VAR)            \
    case (opcode_y[1:0])                  \
        2'b00    : VAR = ~f_in.z;         \
        2'b01    : VAR = f_in.z;          \
        2'b10    : VAR = ~f_in.c;         \
        2'b11    : VAR = f_in.c;          \
    endcase

module instruction_decoder(
    // Inputs
    // From top
    input logic clk, nrst,
    // From instruction register
    input logic [7:0] opcode,
    input logic [15:0] imm_i,
    // From register file
    /* verilator lint_off UNUSEDSIGNAL */
    input cu_pkg::f_register f_in,
    // From ALU
    input cu_pkg::f_register alu_f_in,
    /* verilator lint_on UNUSEDSIGNAL */
    // From memory controller
    input logic memory_acknowledge,
    // From interrupt controller
    input logic interrupt_requested,
    input ih_pkg::interrupt_source interrupt_source,
    // Outputs
    // To instruction register
    output logic clear, hold,
    // To PC
    output logic next_instr_req, cond_true, jump_is_relative, call_or_jump,
    output logic [7:0] pc_offset,
    // To register file
    output cu_pkg::id_state state,
    output cu_pkg::f_register f_out,
    output cu_pkg::register_select r1_sel, r2_sel, reg_write_sel, reg_mem_addr_read_sel, reg_mem_addr_write_sel,
    output logic reg_file_write_en,
    output cu_pkg::decoded_instruction instr_to_reg_file,
    // To ALU
    output alu_pkg::alu_op alu_op,
    // To memory controller
    output logic mem_read_en, mem_write_en, dbl_byte_en,
    // To control unit
    output cu_pkg::mem_req_source_sel mem_addr_read_source_sel, mem_addr_write_source_sel,
    output logic [15:0] r1_imm, r2_imm,
    output logic r1_is_imm, r2_is_imm,
    output logic [15:0] mem_addr_imm,
    // To interrupt controller
    output logic interrupts_enabled, interrupt_ack
);
    // State tracking
    cu_pkg::id_state next_state;
    logic is_halted;
    logic can_be_interrupted, starting_int_service, is_interrupted;

    // Opcode sections
    logic [1:0] opcode_x, opcode_p;
    logic [2:0] opcode_y, opcode_z;
    logic opcode_q;

    logic [1:0] cb_opcode_x;
    logic [2:0] cb_opcode_y, cb_opcode_z;

    // Decoding state
    cu_pkg::decoded_instruction decoded_opcode, alu_opcode;
    logic opcode_requires_byte, opcode_requires_double_byte;
    cu_pkg::register_select opcode_rp, opcode_rp2, opcode_r_y, opcode_r_z;
    alu_pkg::alu_op decoded_opcode_from_alu;
    cu_pkg::cb_decoded_instruction cb_decoded_opcode;
    cu_pkg::register_select cb_opcode_r_z;

    // Condition tracking
    logic opcode_uses_cond, cond_unconditional;

    // Memory access tracking
    logic opcode_requires_mem_read, opcode_requires_mem_write;
    cu_pkg::mem_req_source_sel opcode_mem_read_source_sel;

    // Writeback control
    logic opcode_requires_writeback;

    // Opcode section updating
    always_comb begin
        opcode_x = opcode[7:6];
        opcode_y = opcode[5:3];
        opcode_z = opcode[2:0];
        opcode_p = opcode[5:4];
        opcode_q = opcode[3];
        // CB prefixed instruction sections
        cb_opcode_x = imm_i[7:6];
        cb_opcode_y = imm_i[5:3];
        cb_opcode_z = imm_i[2:0];
    end

    // Opcode register selecting
    always_comb begin
        case (opcode_p)
            2'b00 : opcode_rp = cu_pkg::bc_register_select;
            2'b01 : opcode_rp = cu_pkg::de_register_select;
            2'b10 : opcode_rp = cu_pkg::hl_register_select;
            2'b11 : opcode_rp = cu_pkg::sp_register_select;
        endcase
        case (opcode_p)
            2'b00 : opcode_rp2 = cu_pkg::bc_register_select;
            2'b01 : opcode_rp2 = cu_pkg::de_register_select;
            2'b10 : opcode_rp2 = cu_pkg::hl_register_select;
            2'b11 : opcode_rp2 = cu_pkg::af_register_select;
        endcase
        case (opcode_y)
            3'b000 : opcode_r_y = cu_pkg::b_register_select;
            3'b001 : opcode_r_y = cu_pkg::c_register_select;
            3'b010 : opcode_r_y = cu_pkg::d_register_select;
            3'b011 : opcode_r_y = cu_pkg::e_register_select;
            3'b100 : opcode_r_y = cu_pkg::h_register_select;
            3'b101 : opcode_r_y = cu_pkg::l_register_select;
            3'b110 : opcode_r_y = cu_pkg::phl_register_select;
            3'b111 : opcode_r_y = cu_pkg::a_register_select;
        endcase
        case (opcode_z)
            3'b000 : opcode_r_z = cu_pkg::b_register_select;
            3'b001 : opcode_r_z = cu_pkg::c_register_select;
            3'b010 : opcode_r_z = cu_pkg::d_register_select;
            3'b011 : opcode_r_z = cu_pkg::e_register_select;
            3'b100 : opcode_r_z = cu_pkg::h_register_select;
            3'b101 : opcode_r_z = cu_pkg::l_register_select;
            3'b110 : opcode_r_z = cu_pkg::phl_register_select;
            3'b111 : opcode_r_z = cu_pkg::a_register_select;
        endcase
        case (cb_opcode_z)
            3'b000 : cb_opcode_r_z = cu_pkg::b_register_select;
            3'b001 : cb_opcode_r_z = cu_pkg::c_register_select;
            3'b010 : cb_opcode_r_z = cu_pkg::d_register_select;
            3'b011 : cb_opcode_r_z = cu_pkg::e_register_select;
            3'b100 : cb_opcode_r_z = cu_pkg::h_register_select;
            3'b101 : cb_opcode_r_z = cu_pkg::l_register_select;
            3'b110 : cb_opcode_r_z = cu_pkg::phl_register_select;
            3'b111 : cb_opcode_r_z = cu_pkg::a_register_select;
        endcase
    end

    // ALU opcode selection
    always_comb begin
        case (opcode_y)
            3'b000 : alu_opcode = cu_pkg::add_op;
            3'b001 : alu_opcode = cu_pkg::adc_op;
            3'b010 : alu_opcode = cu_pkg::sub_op;
            3'b011 : alu_opcode = cu_pkg::sbc_op;
            3'b100 : alu_opcode = cu_pkg::and_op;
            3'b101 : alu_opcode = cu_pkg::xor_op;
            3'b110 : alu_opcode = cu_pkg::or_op;
            3'b111 : alu_opcode = cu_pkg::cp_op;
        endcase
        case (opcode_y)
            3'b000 : decoded_opcode_from_alu = alu_pkg::ADD8;
            3'b001 : decoded_opcode_from_alu = alu_pkg::ADC;
            3'b010 : decoded_opcode_from_alu = alu_pkg::SUB8;
            3'b011 : decoded_opcode_from_alu = alu_pkg::SBC;
            3'b100 : decoded_opcode_from_alu = alu_pkg::AND;
            3'b101 : decoded_opcode_from_alu = alu_pkg::XOR;
            3'b110 : decoded_opcode_from_alu = alu_pkg::OR;
            3'b111 : decoded_opcode_from_alu = alu_pkg::SUB8;
        endcase
    end

    // Opcode decoding
    always_comb begin
        {opcode_requires_byte, opcode_requires_double_byte} = 2'b00;
        opcode_uses_cond = 1'b0;
         // TODO: default values?
        reg_write_sel = cu_pkg::a_register_select;
        r1_sel = cu_pkg::a_register_select;
        r1_imm = imm_i;
        r1_is_imm = 1'b0;
        r2_sel = cu_pkg::a_register_select;
        r2_imm = imm_i;
        r2_is_imm = 1'b0;
        alu_op = alu_pkg::ADD8;
        cond_unconditional = 1'b0;
        opcode_requires_writeback = 1'b0;
        mem_addr_imm = 16'b0;
        dbl_byte_en = 1'b0;
        opcode_mem_read_source_sel = cu_pkg::value_from_pc;
        opcode_requires_mem_read = 1'b0;
        opcode_requires_mem_write = 1'b0;
        mem_addr_write_source_sel = cu_pkg::value_from_pc;
        reg_mem_addr_write_sel = cu_pkg::a_register_select;
        reg_mem_addr_read_sel = cu_pkg::a_register_select;
        cb_decoded_opcode = cu_pkg::set_op;

        if (starting_int_service) begin
            decoded_opcode = cu_pkg::call_op;
            r1_sel = cu_pkg::pc_register_select;
            reg_write_sel = cu_pkg::pc_register_select;
            reg_mem_addr_write_sel = cu_pkg::sp_register_select;
            alu_op = alu_pkg::ADD16;
            mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
            case (interrupt_source)
                ih_pkg::timer_is    : r1_imm = 16'h0000;
                ih_pkg::input_is    : r1_imm = 16'h0010;
                ih_pkg::gpio_is     : r1_imm = 16'h0020;
                ih_pkg::external_is : r1_imm = 16'h0030;
            endcase
            r1_is_imm = state == cu_pkg::writeback_state;
            r2_imm = 16'b0;
            r2_is_imm = 1'b1;
            cond_unconditional = 1'b1;
            dbl_byte_en = 1'b1;
            opcode_requires_mem_write = 1'b1;
        end else casez ({opcode_x, opcode_y, opcode_z, opcode_p, opcode_q})
            // x = 0
            // z = 0
            {2'b00, 3'b000, 3'b000, 2'b??, 1'b?} : decoded_opcode = cu_pkg::nop_op;
            {2'b00, 3'b011, 3'b000, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::jr_op;
                opcode_requires_byte = 1'b1;
                cond_unconditional = 1'b1;
            end
            {2'b00, 3'b010, 3'b000, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::djnz_op;
                opcode_requires_byte = 1'b1;
                cond_unconditional = ~alu_f_in.z;
                r1_sel = cu_pkg::b_register_select;
                reg_write_sel = cu_pkg::b_register_select;
                alu_op = alu_pkg::SUB8;
                r2_imm = 16'b1;
                r2_is_imm = 1'b1;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b1??, 3'b000, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::jr_op;
                opcode_requires_byte = 1'b1;
                opcode_uses_cond = 1'b1;
            end
            // z = 1
            {2'b00, 3'b???, 3'b001, 2'b??, 1'b0} : begin
                decoded_opcode = cu_pkg::ld_op;
                opcode_requires_double_byte = 1'b1;
                reg_write_sel = opcode_rp;
                alu_op = alu_pkg::ADD16;
                r1_imm = imm_i;
                r1_is_imm = 1'b1;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b???, 3'b001, 2'b??, 1'b1} : begin
                decoded_opcode = cu_pkg::add_op;
                alu_op = alu_pkg::ADD16;
                reg_write_sel = cu_pkg::hl_register_select;
                r1_sel = cu_pkg::hl_register_select;
                r2_sel = opcode_rp;
                opcode_requires_writeback = 1'b1;
            end
            // z = 2
            {2'b00, 3'b???, 3'b010, 2'b0?, 1'b0} : begin
                decoded_opcode = cu_pkg::ld_op;
                r1_sel = cu_pkg::a_register_select;
                if (opcode_p[0]) reg_mem_addr_write_sel = cu_pkg::de_register_select;
                else             reg_mem_addr_write_sel = cu_pkg::bc_register_select;
                alu_op = alu_pkg::ADD8;
                mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_requires_mem_write = 1'b1;
            end
            {2'b00, 3'b???, 3'b010, 2'b10, 1'b0} : begin
                decoded_opcode = cu_pkg::ld_op;
                opcode_requires_double_byte = 1'b1;
                r1_sel = cu_pkg::hl_register_select;
                alu_op = alu_pkg::ADD16;
                mem_addr_write_source_sel = cu_pkg::value_from_imm;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_requires_mem_write = 1'b1;
                mem_addr_imm = imm_i;
                dbl_byte_en = 1'b1;
            end
            {2'b00, 3'b???, 3'b010, 2'b11, 1'b0} : begin
                decoded_opcode = cu_pkg::ld_op;
                opcode_requires_double_byte = 1'b1;
                r1_sel = cu_pkg::a_register_select;
                alu_op = alu_pkg::ADD8;
                mem_addr_write_source_sel = cu_pkg::value_from_imm;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_requires_mem_write = 1'b1;
                mem_addr_imm = imm_i;
            end
            {2'b00, 3'b???, 3'b010, 2'b0?, 1'b1} : begin
                decoded_opcode = cu_pkg::ld_op;
                r1_sel = cu_pkg::memory_register_select;
                reg_write_sel = cu_pkg::a_register_select;
                if (opcode_p[0]) reg_mem_addr_read_sel = cu_pkg::de_register_select;
                else             reg_mem_addr_read_sel = cu_pkg::bc_register_select;
                alu_op = alu_pkg::ADD8;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_requires_mem_read = 1'b1;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b???, 3'b010, 2'b10, 1'b1} : begin
                decoded_opcode = cu_pkg::ld_op;
                opcode_requires_double_byte = 1'b1;
                r1_sel = cu_pkg::memory_register_select;
                reg_write_sel = cu_pkg::hl_register_select;
                alu_op = alu_pkg::ADD16;
                opcode_mem_read_source_sel = cu_pkg::value_from_imm;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                mem_addr_imm = imm_i;
                dbl_byte_en = 1'b1;
                opcode_requires_mem_read = 1'b1;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b???, 3'b010, 2'b11, 1'b1} : begin
                decoded_opcode = cu_pkg::ld_op;
                opcode_requires_double_byte = 1'b1;
                r1_sel = cu_pkg::memory_register_select;
                reg_write_sel = cu_pkg::a_register_select;
                alu_op = alu_pkg::ADD8;
                opcode_mem_read_source_sel = cu_pkg::value_from_imm;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                mem_addr_imm = imm_i;
                opcode_requires_mem_read = 1'b1;
                opcode_requires_writeback = 1'b1;
            end
            // z = 3
            {2'b00, 3'b???, 3'b011, 2'b??, 1'b0} : begin
                decoded_opcode = cu_pkg::inc_op;
                r1_sel = opcode_rp;
                reg_write_sel = opcode_rp;
                alu_op = alu_pkg::ADD16;
                r2_imm = 16'b1;
                r2_is_imm = 1'b1;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b???, 3'b011, 2'b??, 1'b1} : begin
                decoded_opcode = cu_pkg::dec_op;
                r1_sel = opcode_rp;
                reg_write_sel = opcode_rp;
                alu_op = alu_pkg::SUB16;
                r2_imm = 16'b1;
                r2_is_imm = 1'b1;
                opcode_requires_writeback = 1'b1;
            end
            // z = 4
            {2'b00, 3'b???, 3'b100, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::inc_op;
                if (opcode_r_y == cu_pkg::phl_register_select) r1_sel = cu_pkg::memory_register_select;
                else                                           r1_sel = opcode_r_y;
                reg_write_sel = opcode_r_y;
                reg_mem_addr_read_sel = cu_pkg::hl_register_select;
                reg_mem_addr_write_sel = cu_pkg::hl_register_select;
                alu_op = alu_pkg::ADD8;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b1;
                r2_is_imm = 1'b1;
                opcode_requires_mem_read = opcode_r_y == cu_pkg::phl_register_select;
                opcode_requires_mem_write = opcode_r_y == cu_pkg::phl_register_select;
                opcode_requires_writeback = opcode_r_y != cu_pkg::phl_register_select;
            end
            // z = 5
            {2'b00, 3'b???, 3'b101, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::dec_op;
                if (opcode_r_y == cu_pkg::phl_register_select) r1_sel = cu_pkg::memory_register_select;
                else                                           r1_sel = opcode_r_y;
                reg_write_sel = opcode_r_y;
                reg_mem_addr_read_sel = cu_pkg::hl_register_select;
                reg_mem_addr_write_sel = cu_pkg::hl_register_select;
                alu_op = alu_pkg::SUB8;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b1;
                r2_is_imm = 1'b1;
                opcode_requires_mem_read = opcode_r_y == cu_pkg::phl_register_select;
                opcode_requires_mem_write = opcode_r_y == cu_pkg::phl_register_select;
                opcode_requires_writeback = opcode_r_y != cu_pkg::phl_register_select;
            end
            // z = 6
            {2'b00, 3'b???, 3'b110, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::ld_op;
                opcode_requires_byte = 1'b1;
                reg_write_sel = opcode_r_y;
                reg_mem_addr_write_sel = cu_pkg::hl_register_select;
                alu_op = alu_pkg::ADD8;
                mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
                r1_imm = {8'b0, imm_i[7:0]};
                r1_is_imm = 1'b1;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_requires_mem_write = opcode_r_y == cu_pkg::phl_register_select;
                opcode_requires_writeback = opcode_r_y != cu_pkg::phl_register_select;
            end
            // z = 7
            {2'b00, 3'b000, 3'b111, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::rlca_op;
                reg_write_sel = cu_pkg::a_register_select;
                r1_sel = cu_pkg::a_register_select;
                alu_op = alu_pkg::RLC;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b001, 3'b111, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::rrca_op;
                reg_write_sel = cu_pkg::a_register_select;
                r1_sel = cu_pkg::a_register_select;
                alu_op = alu_pkg::RRC;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b010, 3'b111, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::rla_op;
                reg_write_sel = cu_pkg::a_register_select;
                r1_sel = cu_pkg::a_register_select;
                alu_op = alu_pkg::RL;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b011, 3'b111, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::rra_op;
                reg_write_sel = cu_pkg::a_register_select;
                r1_sel = cu_pkg::a_register_select;
                alu_op = alu_pkg::RR;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b101, 3'b111, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::cpl_op;
                reg_write_sel = cu_pkg::a_register_select;
                r1_sel = cu_pkg::a_register_select;
                alu_op = alu_pkg::NOT;
                opcode_requires_writeback = 1'b1;
            end
            {2'b00, 3'b110, 3'b111, 2'b??, 1'b?} : decoded_opcode = cu_pkg::scf_op;
            {2'b00, 3'b111, 3'b111, 2'b??, 1'b?} : decoded_opcode = cu_pkg::ccf_op;

            // x = 1
            {2'b01, 3'b110, 3'b110, 2'b??, 1'b?} : decoded_opcode = cu_pkg::halt_op;
            // Ignore case overlap because its intentional
            /* verilator lint_off CASEOVERLAP */
            {2'b01, 3'b???, 3'b???, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::ld_op;
                if (opcode_r_z == cu_pkg::phl_register_select) r1_sel = cu_pkg::memory_register_select;
                else                                           r1_sel = opcode_r_z;
                reg_write_sel = opcode_r_y;
                reg_mem_addr_read_sel = cu_pkg::hl_register_select;
                reg_mem_addr_write_sel = cu_pkg::hl_register_select;
                alu_op = alu_pkg::ADD8;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_requires_mem_read = opcode_r_z == cu_pkg::phl_register_select;
                opcode_requires_mem_write = opcode_r_y == cu_pkg::phl_register_select;
                opcode_requires_writeback = opcode_r_y != cu_pkg::phl_register_select;
            end
            /* verilator lint_on CASEOVERLAP */

            // x = 2
            {2'b10, 3'b???, 3'b???, 2'b??, 1'b?} : begin
                decoded_opcode = alu_opcode;
                alu_op = decoded_opcode_from_alu;
                r1_sel = cu_pkg::a_register_select;
                if (opcode_r_z == cu_pkg::phl_register_select) r2_sel = cu_pkg::memory_register_select;
                else                                           r2_sel = opcode_r_z;
                reg_write_sel = cu_pkg::a_register_select;
                reg_mem_addr_read_sel = cu_pkg::hl_register_select;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                opcode_requires_mem_read = opcode_r_z == cu_pkg::phl_register_select;
                opcode_requires_writeback = decoded_opcode != cu_pkg::cp_op;
            end

            // x = 3
            // z = 0
            {2'b11, 3'b???, 3'b000, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::ret_op;
                r1_sel = cu_pkg::memory_register_select;
                reg_write_sel = cu_pkg::pc_register_select;
                reg_mem_addr_read_sel = cu_pkg::sp_register_select;
                alu_op = alu_pkg::ADD16;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_uses_cond = 1'b1;
                dbl_byte_en = 1'b1;
                // Necessary because of weird simulation bug that causes
                // testbenches to enter infinite loop
                `SET_VAR_FROM_COND(opcode_requires_mem_read);
            end
            // z = 1
            {2'b11, 3'b???, 3'b001, 2'b??, 1'b0} : begin
                decoded_opcode = cu_pkg::pop_op;
                r1_sel = cu_pkg::memory_register_select;
                reg_write_sel = opcode_rp2;
                reg_mem_addr_read_sel = cu_pkg::sp_register_select;
                alu_op = alu_pkg::ADD16;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                dbl_byte_en = 1'b1;
                opcode_requires_mem_read = 1'b1;
                opcode_requires_writeback = 1'b1;
            end
            {2'b11, 3'b???, 3'b001, 2'b00, 1'b1} : begin
                decoded_opcode = cu_pkg::ret_op;
                r1_sel = cu_pkg::memory_register_select;
                reg_write_sel = cu_pkg::pc_register_select;
                reg_mem_addr_read_sel = cu_pkg::sp_register_select;
                alu_op = alu_pkg::ADD16;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                cond_unconditional = 1'b1;
                dbl_byte_en = 1'b1;
                opcode_requires_mem_read = 1'b1;
            end
            {2'b11, 3'b???, 3'b001, 2'b10, 1'b1} : begin
                decoded_opcode = cu_pkg::jp_op;
                r1_sel = cu_pkg::hl_register_select;
                reg_write_sel = cu_pkg::pc_register_select;
                alu_op = alu_pkg::ADD16;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                cond_unconditional = 1'b1;
            end
            {2'b11, 3'b???, 3'b001, 2'b11, 1'b1} : begin
                decoded_opcode = cu_pkg::ld_op;
                r1_sel = cu_pkg::hl_register_select;
                reg_write_sel = cu_pkg::sp_register_select;
                alu_op = alu_pkg::ADD16;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_requires_writeback = 1'b1;
            end
            // z = 2
            {2'b11, 3'b???, 3'b010, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::jp_op;
                opcode_requires_double_byte = 1'b1;
                reg_write_sel = cu_pkg::pc_register_select;
                alu_op = alu_pkg::ADD16;
                r1_imm = imm_i;
                r1_is_imm = 1'b1;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_uses_cond = 1'b1;
            end
            // z = 3
            {2'b11, 3'b000, 3'b011, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::jp_op;
                opcode_requires_double_byte = 1'b1;
                reg_write_sel = cu_pkg::pc_register_select;
                alu_op = alu_pkg::ADD16;
                r1_imm = imm_i;
                r1_is_imm = 1'b1;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                cond_unconditional = 1'b1;
            end
            {2'b11, 3'b001, 3'b011, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::cb_op;
                opcode_requires_byte = 1'b1;
                case (cb_opcode_x)
                    2'b00 : cb_decoded_opcode = cu_pkg::rotate_from_cb_y(cb_opcode_y);
                    2'b01 : cb_decoded_opcode = cu_pkg::bit_op;
                    2'b10 : cb_decoded_opcode = cu_pkg::res_op;
                    2'b11 : cb_decoded_opcode = cu_pkg::set_op;
                endcase
                if (cb_opcode_r_z == cu_pkg::phl_register_select)
                    r1_sel = cu_pkg::memory_register_select;
                else
                    r1_sel = cb_opcode_r_z;
                alu_op = cu_pkg::alu_op_from_cb_opcode(cb_decoded_opcode);
                reg_write_sel = cb_opcode_r_z;
                reg_mem_addr_read_sel = cu_pkg::hl_register_select;
                reg_mem_addr_write_sel = cu_pkg::hl_register_select;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = {{13{1'b0}}, cb_opcode_y};
                r2_is_imm = 1'b1;
                opcode_requires_mem_read = cb_opcode_r_z == cu_pkg::phl_register_select;
                opcode_requires_mem_write = (cb_opcode_r_z == cu_pkg::phl_register_select) & cb_decoded_opcode != cu_pkg::bit_op;
                opcode_requires_writeback = (cb_opcode_r_z != cu_pkg::phl_register_select) & cb_decoded_opcode != cu_pkg::bit_op;
            end
            {2'b11, 3'b110, 3'b011, 2'b??, 1'b?} : decoded_opcode = cu_pkg::di_op;
            {2'b11, 3'b111, 3'b011, 2'b??, 1'b?} : decoded_opcode = cu_pkg::ei_op;
            // z = 4
            {2'b11, 3'b000, 3'b100, 2'b??, 1'b?} : begin
                decoded_opcode = cu_pkg::call_op;
                opcode_requires_double_byte = 1'b1;
                r1_sel = cu_pkg::pc_register_select;
                reg_write_sel = cu_pkg::pc_register_select;
                reg_mem_addr_write_sel = cu_pkg::sp_register_select;
                alu_op = alu_pkg::ADD16;
                mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
                r1_imm = imm_i;
                r1_is_imm = state == cu_pkg::writeback_state;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                opcode_uses_cond = 1'b1;
                dbl_byte_en = 1'b1;
                // Necessary because of weird simulation bug that causes
                // testbenches to enter infinite loop
                `SET_VAR_FROM_COND(opcode_requires_mem_write);
            end
            // z = 5
            {2'b11, 3'b???, 3'b101, 2'b??, 1'b0} : begin
                decoded_opcode = cu_pkg::push_op;
                r1_sel = opcode_rp2;
                reg_mem_addr_write_sel = cu_pkg::sp_register_select;
                alu_op = alu_pkg::ADD16;
                mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                dbl_byte_en = 1'b1;
                opcode_requires_mem_write = 1'b1;
            end
            {2'b11, 3'b???, 3'b101, 2'b00, 1'b1} : begin
                decoded_opcode = cu_pkg::call_op;
                opcode_requires_double_byte = 1'b1;
                r1_sel = cu_pkg::pc_register_select;
                reg_write_sel = cu_pkg::pc_register_select;
                reg_mem_addr_write_sel = cu_pkg::sp_register_select;
                alu_op = alu_pkg::ADD16;
                mem_addr_write_source_sel = cu_pkg::value_from_reg_file;
                r1_imm = imm_i;
                r1_is_imm = state == cu_pkg::writeback_state;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                cond_unconditional = 1'b1;
                dbl_byte_en = 1'b1;
                opcode_requires_mem_write = 1'b1;;
            end
            {2'b11, 3'b???, 3'b101, 2'b11, 1'b1} : begin
                decoded_opcode = cu_pkg::reti_op;
                r1_sel = cu_pkg::memory_register_select;
                reg_write_sel = cu_pkg::pc_register_select;
                reg_mem_addr_read_sel = cu_pkg::sp_register_select;
                alu_op = alu_pkg::ADD16;
                opcode_mem_read_source_sel = cu_pkg::value_from_reg_file;
                r2_imm = 16'b0;
                r2_is_imm = 1'b1;
                cond_unconditional = 1'b1;
                dbl_byte_en = 1'b1;
                opcode_requires_mem_read = 1'b1;
            end

            // z = 6
            {2'b11, 3'b???, 3'b110, 2'b??, 1'b?} : begin
                decoded_opcode = alu_opcode;
                alu_op = decoded_opcode_from_alu;
                opcode_requires_byte = 1'b1;
                r1_sel = cu_pkg::a_register_select;
                reg_write_sel = cu_pkg::a_register_select;
                r2_imm = {8'b0, imm_i[7:0]};
                r2_is_imm = 1'b1;
                opcode_requires_writeback = decoded_opcode != cu_pkg::cp_op;
            end
            default: decoded_opcode = cu_pkg::nop_op;
        endcase
    end

    // PC signal forwarding
    always_comb begin
        cond_true = cond_unconditional;
        if (opcode_uses_cond) begin
            `SET_VAR_FROM_COND(cond_true);
        end
        call_or_jump = state == cu_pkg::writeback_state &
            (decoded_opcode == cu_pkg::jp_op | decoded_opcode == cu_pkg::call_op | decoded_opcode == cu_pkg::ret_op | decoded_opcode == cu_pkg::reti_op);
        jump_is_relative = state == cu_pkg::writeback_state & (decoded_opcode == cu_pkg::jr_op | decoded_opcode == cu_pkg::djnz_op);
        next_instr_req = 
            (state == cu_pkg::writeback_state & ((call_or_jump | jump_is_relative) & cond_true)) ||
            (state == cu_pkg::fetch_state & next_state != state) ||
            (state == cu_pkg::wait_for_byte_state & next_state != state) ||
            (state == cu_pkg::wait_for_double_byte_state & next_state != state);
        pc_offset = imm_i[7:0];
    end

    // Next state logic
    // Can't use ternaries because of old iverilog bug: https://github.com/steveicarus/iverilog/issues/498
    always_comb begin
        case (state)
            cu_pkg::fetch_state : if (memory_acknowledge) next_state = cu_pkg::decode_state;
                                  else next_state = state;
            cu_pkg::decode_state : if (opcode_requires_byte) next_state = cu_pkg::wait_for_byte_state;
                    else if (opcode_requires_double_byte) next_state = cu_pkg::wait_for_double_byte_state;
                    else if (opcode_requires_mem_read) next_state = cu_pkg::memory_read_state;
                    else if (opcode_requires_mem_write) next_state = cu_pkg::memory_write_state;
                    else next_state = cu_pkg::writeback_state;
            cu_pkg::wait_for_byte_state : if (memory_acknowledge)
                                                if (decoded_opcode == cu_pkg::cb_op) next_state = cu_pkg::cb_decode_state;
                                                else if (opcode_requires_mem_read)   next_state = cu_pkg::memory_read_state;
                                                else if (opcode_requires_mem_write)  next_state = cu_pkg::memory_write_state;
                                                else                                 next_state = cu_pkg::writeback_state;
                                          else next_state = state;
            cu_pkg::cb_decode_state : if (opcode_requires_mem_read) next_state = cu_pkg::memory_read_state;
                    else if (opcode_requires_mem_write) next_state = cu_pkg::memory_write_state;
                    else next_state = cu_pkg::writeback_state;
            cu_pkg::wait_for_double_byte_state : if (memory_acknowledge) next_state = cu_pkg::wait_for_byte_state;
                                                 else next_state = state;
            cu_pkg::memory_read_state : if (memory_acknowledge)
                                            if (opcode_requires_mem_write) next_state = cu_pkg::memory_write_state;
                                            else next_state = cu_pkg::writeback_state;
                                        else next_state = state;
            cu_pkg::memory_write_state : if (memory_acknowledge) next_state = cu_pkg::writeback_state;
                                         else next_state = state;
            cu_pkg::writeback_state : next_state = cu_pkg::fetch_state;
            default : next_state = cu_pkg::fetch_state;
        endcase
    end

    // Instruction register signal fowarding
    always_comb begin
        clear = state == cu_pkg::writeback_state;
        case (state)
            cu_pkg::fetch_state                : hold = 1'b0;
            cu_pkg::wait_for_byte_state        : hold = 1'b0;
            cu_pkg::wait_for_double_byte_state : hold = 1'b0;
            default                            : hold = 1'b1;
        endcase
    end

    // Register file
    always_comb begin
        instr_to_reg_file = decoded_opcode;
    end

    // Writeback signal forwarding
    always_comb begin
        reg_file_write_en = state == cu_pkg::writeback_state & opcode_requires_writeback;
    end

    // Memory controller signal forwarding
    always_comb begin
        mem_read_en = state == cu_pkg::memory_read_state ||
            state == cu_pkg::fetch_state ||
            state == cu_pkg::wait_for_byte_state ||
            state == cu_pkg::wait_for_double_byte_state;
        mem_write_en = state == cu_pkg::memory_write_state;
        if (state == cu_pkg::memory_read_state) mem_addr_read_source_sel = opcode_mem_read_source_sel;
        else                                    mem_addr_read_source_sel = cu_pkg::value_from_pc;
    end

    always_comb begin
        case (decoded_opcode)
            cu_pkg::adc_op  : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
            cu_pkg::add_op  : if (alu_op == alu_pkg::ADD8)
                              f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v, 1'b0, alu_f_in.c};
                              else
                              f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v, alu_f_in.n, alu_f_in.c};
            cu_pkg::and_op  : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0,       1'b0};
            cu_pkg::call_op : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::ccf_op  : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,    ~f_in.c};
            cu_pkg::cp_op   : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v, alu_f_in.n, alu_f_in.c};
            cu_pkg::cpl_op  : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v, alu_f_in.n,     f_in.c};
            cu_pkg::dec_op  : if (alu_op == alu_pkg::SUB8)
                              f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v, alu_f_in.n,     f_in.c};
                              else
                              f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::halt_op : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::inc_op  : if (alu_op == alu_pkg::ADD8)
                              f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v, alu_f_in.n,     f_in.c};
                              else
                              f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::jp_op   : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::jr_op   : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::ld_op   : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::nop_op  : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::or_op   : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0,       1'b0};
            cu_pkg::pop_op  : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::push_op : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::ret_op  : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::rla_op  : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,       1'b0, alu_f_in.c};
            cu_pkg::rlca_op : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
            cu_pkg::rra_op  : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,       1'b0, alu_f_in.c};
            cu_pkg::rrca_op : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,       1'b0, alu_f_in.c};
            cu_pkg::sbc_op  : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b1, alu_f_in.c};
            cu_pkg::scf_op  : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,       1'b0,       1'b1};
            cu_pkg::sub_op  : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b1, alu_f_in.c};
            cu_pkg::xor_op  : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0,       1'b0};
            cu_pkg::djnz_op : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
            cu_pkg::cb_op   : begin
                case (cb_decoded_opcode)
                    cu_pkg::rlc_op : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
                    cu_pkg::rrc_op : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
                    cu_pkg::rl_op  : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
                    cu_pkg::rr_op  : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
                    cu_pkg::sla_op : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
                    cu_pkg::sra_op : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
                    cu_pkg::sll_op : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
                    cu_pkg::srl_op : f_out = {alu_f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0, alu_f_in.v,       1'b0, alu_f_in.c};
                    cu_pkg::bit_op : f_out = {    f_in.s, alu_f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,       1'b0,     f_in.c};
                    cu_pkg::res_op : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
                    cu_pkg::set_op : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
                    default        : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
                endcase
            end
            default         : f_out = {    f_in.s,     f_in.z, 1'b0, 1'b0, 1'b0,     f_in.v,     f_in.n,     f_in.c};
        endcase
    end

    // Interrupt controller signal forwarding
    always_comb begin
        interrupt_ack = state == cu_pkg::writeback_state && decoded_opcode == cu_pkg::reti_op;
        interrupts_enabled = can_be_interrupted;
    end

    always_ff @(posedge clk, negedge nrst) begin
        if (!nrst) begin
            state <= cu_pkg::fetch_state;
            is_halted <= 1'b0;
            can_be_interrupted <= 1'b0;
            is_interrupted <= 1'b0;
            starting_int_service <= 1'b0;
        end else begin
            if (state == cu_pkg::writeback_state & (decoded_opcode == cu_pkg::ei_op | decoded_opcode == cu_pkg::reti_op))
                can_be_interrupted <= 1'b1;
            else if ((state == cu_pkg::writeback_state & decoded_opcode == cu_pkg::di_op) | is_interrupted)
                can_be_interrupted <= 1'b0;

            starting_int_service <= ~is_interrupted & // only start if we're not interrupted
                ((starting_int_service & next_state != cu_pkg::fetch_state) | // keep until writeback
                interrupt_requested); // or we're interrupted
            is_interrupted <= (is_interrupted & ~interrupt_ack) | (starting_int_service & state == cu_pkg::writeback_state);

            is_halted <= (is_halted | (decoded_opcode == cu_pkg::halt_op)) & ~interrupt_requested;
            if (~is_halted) state <= next_state;
            else state <= cu_pkg::decode_state;
        end
    end

endmodule
