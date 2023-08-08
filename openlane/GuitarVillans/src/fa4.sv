module fa4 (
  input logic [3:0] a, b,
  input logic ci,
  output logic [3:0] s,
  output logic co
);
  wire [2:0] x;
  fa add1(.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]), .co(x[0]));
  fa add2(.a(a[1]), .b(b[1]), .ci(x[0]), .s(s[1]), .co(x[1]));
  fa add3(.a(a[2]), .b(b[2]), .ci(x[1]), .s(s[2]), .co(x[2]));
  fa add4(.a(a[3]), .b(b[3]), .ci(x[2]), .s(s[3]), .co(co));
endmodule