`ifndef ALU_PKG
`define ALU_PKG

`default_nettype none

package alu_pkg;
    typedef enum logic [4:0] {
        ADD8, SUB8, ADC, SBC, AND, OR, XOR, NOT,
        ADD16, SUB16, RR, RL, RRC, RLC,
        SLA, SRA, SLL, SRL, BIT, RES, SET
    } alu_op;
endpackage

`endif
