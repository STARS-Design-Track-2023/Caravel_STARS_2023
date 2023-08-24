`default_nettype none

module waveshaper(
  //inputs
  input logic [17:0] fd,
  input logic [17:0] count,
  input logic [1:0] mode,
  input logic start,
  input logic clk,
  input logic nrst,
  //outputs
  output logic [7:0] signal,
  output logic done
);

  //internal signals
  logic [7:0] quotient;
  logic hasquo;

  assign done = hasquo;
  //your code here

  sequential_div #(26) div(
    .clk(clk),
    .nrst(nrst), // Updated signal name from "nrst" to "rst"
    .start(start),
    .done(hasquo),
    .dividend({count, 8'b0}),
    .divisor({8'b0, fd}),
    .fin_quo(quotient),
    .rem()
  );

  always_comb begin
    if (!nrst) begin // Asynchronous negative-edge reset
      signal = 0;
    end else begin
      case (mode)
        2'b00: begin
          //off
          signal = 0;
        end
        2'b01: begin
          //square
          signal = {8{(count > fd/2)}};
        end
        2'b10: begin
          //triangle
          signal = (count > (fd>>1)) ? (quotient << 1) : 128 - (quotient << 1);
        end
        2'b11: begin
          //sawtooth
          signal = quotient;
        end
      endcase
    end
  end
 
endmodule


