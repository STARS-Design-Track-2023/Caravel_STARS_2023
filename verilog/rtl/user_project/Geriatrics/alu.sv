`default_nettype none
`include "source/alu/alu_pkg.sv"
`include "source/control_unit/cu_pkg.sv"

module alu (input logic Cin,
            input alu_pkg::alu_op alu_op,
            input logic [15:0] X, Y,
            output cu_pkg::f_register flag,
            output logic [15:0] result);

  logic [16:0] sum_diff;  // result from adding/subtracting (extended to 17 bits)
  logic [7:0] reset_mask; // Used for RES/SET
  logic C;  // carry flag
  logic S;  // sign flag
  logic Z;  // zero flag
  logic V;  // overflow flag
  
  // Add or Subtract Results
  always_comb begin
    case(alu_op)
      alu_pkg::ADD8:    sum_diff = {1'b0, X} + {1'b0, Y};
      alu_pkg::SUB8:    sum_diff = {1'b0, X} - {1'b0, Y};
      alu_pkg::ADC:     sum_diff = {1'b0, X} + {1'b0, Y} + {16'b0, Cin};
      alu_pkg::SBC:     sum_diff = {1'b0, X} - {1'b0, Y} - {16'b0, Cin};
      alu_pkg::ADD16:   sum_diff = {1'b0, X} + {1'b0, Y};
      alu_pkg::SUB16:   sum_diff = {1'b0, X} - {1'b0, Y};
      default: sum_diff = 0;
    endcase
  end

  // Result Selection Logic
  always_comb begin
    result = 16'b0;
    reset_mask = 8'hff;
    reset_mask[Y[2:0]] = 1'b0;
    case (alu_op)
      alu_pkg::ADD8  : result[7:0] = sum_diff[7:0];
      alu_pkg::SUB8  : result[7:0] = sum_diff[7:0];
      alu_pkg::ADC   : result[7:0] = sum_diff[7:0];
      alu_pkg::SBC   : result[7:0] = sum_diff[7:0];
      alu_pkg::AND   : result[7:0] = X[7:0] & Y[7:0];
      alu_pkg::OR    : result[7:0] = X[7:0] | Y[7:0];
      alu_pkg::XOR   : result[7:0] = X[7:0] ^ Y[7:0];
      alu_pkg::NOT   : result[7:0] = ~X[7:0];
      alu_pkg::ADD16 : result      = sum_diff[15:0];
      alu_pkg::SUB16 : result      = sum_diff[15:0];
      alu_pkg::RR    : result[7:0] = {Cin, X[7:1]};
      alu_pkg::RL    : result[7:0] = {X[6:0], Cin};
      alu_pkg::RRC   : result[7:0] = {X[0], X[7:1]};
      alu_pkg::RLC   : result[7:0] = {X[6:0], X[7]};
      alu_pkg::SLA   : result[7:0] = {X[6:0], 1'b0};
      alu_pkg::SRA   : result[7:0] = {X[7], X[7:1]};
      alu_pkg::SLL   : result[7:0] = {X[6:0], 1'b1};
      alu_pkg::SRL   : result[7:0] = {1'b0, X[7:1]};
      alu_pkg::RES   : result[7:0] = X[7:0] & reset_mask;
      alu_pkg::SET   : result[7:0] = X[7:0] | ~reset_mask;
      default : result = 16'b0;
    endcase
  end
  
  // Carry (C) Flag Logic
  always_comb begin
    case(alu_op)
      alu_pkg::ADD8:    C = sum_diff[8];
      alu_pkg::SUB8:    C = sum_diff[8];
      alu_pkg::ADC:     C = sum_diff[8];
      alu_pkg::SBC:     C = sum_diff[8];
      alu_pkg::ADD16:   C = sum_diff[16];
      alu_pkg::SUB16:   C = sum_diff[16];
      alu_pkg::RL:      C = X[7];
      alu_pkg::RLC:     C = X[7];
      alu_pkg::RR:      C = X[0];
      alu_pkg::RRC:     C = X[0];
      alu_pkg::SLA:     C = X[7];
      alu_pkg::SRA:     C = X[0];
      alu_pkg::SLL:     C = X[7];
      alu_pkg::SRL:     C = X[0];
      default: C = 1'b0;
    endcase
  end
  
  // Sign (S) Flag Logic
  always_comb begin
    case(alu_op)
      alu_pkg::ADD16:   S = result[15];
      alu_pkg::SUB16:   S = result[15];
      default: S = result[7];
    endcase
  end
  
  // Zero (Z) Flag Logic
  always_comb begin
    case(alu_op)
      alu_pkg::ADD16:   Z = (result == 16'b0);
      alu_pkg::SUB16:   Z = (result == 16'b0);
      alu_pkg::BIT:     Z = X[Y[3:0]] == 1'b0;
      default: Z = (result[7:0] == 8'b0);
    endcase
  end
  
  // Overflow (V) Flag Logic
  always_comb begin
    case (alu_op)
      alu_pkg::ADD8:    V = (X[7] == Y[7] && result[7] != X[7]);
      alu_pkg::SUB8:    V = (X[7] == ~Y[7] && result[7] != X[7]);
      alu_pkg::ADC:     V = (X[7] == Y[7] && result[7] != X[7]);
      alu_pkg::SBC:     V = (X[7] == ~Y[7] && result[7] != X[7]);
      alu_pkg::ADD16:   V = (X[15] == Y[15] && result[15] != X[15]);
      alu_pkg::SUB16:   V = (X[15] == ~Y[15] && result[15] != X[15]);
      alu_pkg::AND:     V = ~^result[7:0];
      alu_pkg::OR:      V = ~^result[7:0];
      alu_pkg::XOR:     V = ~^result[7:0];
      alu_pkg::SLA:     V = ~^result[7:0];
      alu_pkg::SRA:     V = ~^result[7:0];
      alu_pkg::SLL:     V = ~^result[7:0];
      default: V = 1'b0;
    endcase
  end
  
  // Assign output flag
  always_comb begin
    flag.s = S;
    flag.z = Z;
    flag._unused2 = 0;
    flag._unsused1 = 0;
    flag._usused1 = 0;
    flag.v = V;
    flag.n = (alu_op == alu_pkg::ADD8) | (alu_op == alu_pkg::ADC) | (alu_op == alu_pkg::ADD16);
    flag.c = C;
  end
  
endmodule
