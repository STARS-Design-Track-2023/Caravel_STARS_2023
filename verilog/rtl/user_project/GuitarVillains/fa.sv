module fa (
  input logic a, b, ci,
  output logic s, co
);
  assign s = a ^ b ^ ci;
  assign co = (a & b) | ((a | b) & (ci));
endmodule