module ha (
    input logic a, b,
    output logic s, co
    );
   
  assign s = a ^ b;
  assign co = a & b;

endmodule