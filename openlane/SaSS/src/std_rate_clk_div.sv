
/************************************************************************************************************/
// Inputs:
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//
// Outputs:
//    pulse -> A 1 or 0 "pulse" which tells the waveshaper to take a value from the oscilator
//   
/*************************************************************************************************************/

module std_rate_clk_div (input logic clk, nrst, output logic pulse);

  parameter MAX = 8'd255; // Max value to count to is 255
  logic [7:0]count; // Current count
  logic [7:0]next_count; // Next count value

  always_ff @(posedge clk, negedge nrst) begin
    if(nrst)
    count <= next_count;
    else
    count <= 0; // Count set to zero on reset
  end

  always_comb begin

    if(count == MAX) begin // When count reaches 255 it resets to 0 and the pulse output is 1
      next_count = 0;
      pulse = 1;
    end
    else begin // Any other time it just increments by 1 and keeps pulse 0
      next_count = count + 1;
      pulse = 0;
    end

    end 

endmodule