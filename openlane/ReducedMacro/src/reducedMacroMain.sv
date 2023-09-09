module reducedMacroMain 
(

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

  input  logic        clk, nrst,
  input  logic [9:0]  in,
  output logic [13:0] out
);

  assign out = 14'd6;

endmodule