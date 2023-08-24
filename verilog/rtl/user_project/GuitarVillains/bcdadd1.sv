module bcdadd1 (
  input logic [3:0] a, b,
  input logic ci,
  output logic [3:0] s,
  output logic co
);
  logic[4:0] result; 

  assign result = {1'b0, a} + {1'b0, b} + {4'b0, ci} ;


  assign {co, s} = (result[4] == 1'b1 || result[3:0] > 4'd9) ? result + 6 : result;
endmodule