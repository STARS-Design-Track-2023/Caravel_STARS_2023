module bcdadd4 (
  input logic [15:0] a, b,
  input logic ci,
  output logic [15:0] s,
  output logic co
);
  wire [2:0] x;
  bcdadd1 add1(.a(a[3:0]), .b(b[3:0]), .ci(ci), .s(s[3:0]), .co(x[0]));
  bcdadd1 add2(.a(a[7:4]), .b(b[7:4]), .ci(x[0]), .s(s[7:4]), .co(x[1]));
  bcdadd1 add3(.a(a[11:8]), .b(b[11:8]), .ci(x[1]), .s(s[11:8]), .co(x[2]));
  bcdadd1 add4(.a(a[15:12]), .b(b[15:12]), .ci(x[2]), .s(s[15:12]), .co(co));
endmodule
