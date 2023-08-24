`default_nettype none

module InstructionDecoder (
  input logic [1:0] num_bytes,
  input logic [23:0] instr,
  output logic jump_en,
  output logic [2:0] jump_flag, read_addr_1, read_addr_2, write_addr,
  output logic [3:0] opcode,
  output logic [15:0] immediate
);

// Splitting the instruction into pieces
logic [7:0] small_instr;
assign small_instr = instr[23:16];
assign immediate = {instr[7:0], instr[15:8]};


always_comb begin : InstructionDecoder

    // Set Defaults
    /* 
        Unless otherwise changed: 
            All Jumping is Disabled
            All Register Addresses point to the Accumulator
            The ALU opcode will be addition.
    */                                                  /* NOP */
    jump_flag   = 3'b0;     // 000 jump flag
    jump_en     = 1'b0;     // jump is off
    read_addr_1 = 3'b111;   // accumulator
    read_addr_2 = 3'b111;   // accumulator
    write_addr  = 3'b111;   // accumulator
    opcode      = 4'b0;     // addition

    if      (small_instr[7:6] == 2'b11) begin                       /* Functions 11 */
        casez (small_instr[2:1])
            2'b00: begin                                /* PCHL */
                read_addr_1 = 3'b10;            // HL
                jump_en     = 1;                // PC
            end
            2'b01: begin                                /* Jump */
                jump_flag = small_instr[5:3];   // jump_flag
                jump_en =   small_instr[0];     // jump_en
            end
            2'b11: begin                                /* Immediate ALU */
                opcode = {1'b0, small_instr[5:3]};// op
            end
            default: begin                              /* NOP */
                jump_flag   = 3'b0;             // 000 jump flag
                jump_en     = 1'b0;             // jump is off
                read_addr_1 = 3'b111;           // accumulator
                read_addr_2 = 3'b111;           // accumulator
                write_addr  = 3'b111;           // accumulator
                opcode      = 4'b0;             // addition
            end
        endcase
    end
    else if (small_instr[7:6] == 2'b10) begin           /* ALU         Functions 10 */
        opcode = small_instr[6:3];              // op
        read_addr_2 = small_instr[2:0];         // reg
    end
    else if (small_instr[7:6] == 2'b01) begin           /* MOV/HLT     Functions 01 */
        read_addr_1 = small_instr[2:0];         // src
        write_addr =  small_instr[5:3];         // dst
    end
    else /* small_instr[7:6] == 2'b00*/ begin                       /* Functions 00 */

        casez (small_instr[5:0])
             6'b??0001: begin                           /* LXI */
                write_addr = small_instr[6:4];  // rp
             end
             6'b??1001: begin                           /* DAD */
                read_addr_1 = 3'b10;            // HL
                read_addr_2 = small_instr[6:4]; // rp
                write_addr =  3'b10;            // HL
             end
             6'b0??010: begin                           /* STAX/LDAX */
                read_addr_1 = small_instr[6:4]; // rp
             end
             6'b10?010: begin                           /* SHLD/LHLD */
                read_addr_1 = 3'b10;            // HL
                read_addr_2 = 3'b101;           // L
                write_addr  = 3'b101;           // L
             end
             6'b11?010: begin                           /* STA/LDA */
                read_addr_1 = 3'b10;            // HL
             end
             6'b???011: begin                           /* INX/DCX */
                read_addr_1 = small_instr[6:4]; // rp
                write_addr  = small_instr[6:4]; // rp
                opcode = 2 * {3'b0, small_instr[3]};// op
             end
             6'b???10?: begin                           /* INR/DCR */
                read_addr_1 = small_instr[5:3]; // reg
                write_addr  = small_instr[5:3]; // reg
                opcode = 2 * {3'b0, small_instr[0]};// op
             end
             6'b???110: begin                           /* MVI */
                write_addr = small_instr[5:3];  // rp
             end
             6'b???111: begin                           /* RLC/RRC/RAL/RAR/DAA/CMA/STC/CMC */
                opcode = {1'b1, small_instr[5:3]};//op
             end
             default: begin                             /* NOP */
                jump_flag   = 3'b0;             // 000 jump flag
                jump_en     = 1'b0;             // jump is off
                read_addr_1 = 3'b111;           // accumulator
                read_addr_2 = 3'b111;           // accumulator
                write_addr  = 3'b111;           // accumulator
                opcode      = 4'b0;             // addition
             end
        endcase

    end
end
endmodule