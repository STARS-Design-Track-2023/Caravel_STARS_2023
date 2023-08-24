`default_nettype none
module waveshaper (
    // HW
    input logic [7:0] quotient, input logic [1:0] mode,
    output logic [7:0] sample
);

logic [9:0] int_2;
logic [8:0] int_1;

assign int_1 = {quotient, 1'b0};
assign int_2 = {10'd510 - {1'b0, quotient, 1'b0}};

always_comb begin 
  case(mode)
  2'b00 : sample = quotient;
  2'b01 : sample = (quotient >= 128 ? int_2[7:0]: int_1[7:0]);
  2'b10 : sample = (quotient >= 128 ? 255 : 0);
  2'b11 : sample = 0;
  endcase  
end
endmodule