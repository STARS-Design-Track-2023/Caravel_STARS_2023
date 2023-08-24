/************************************************************************************************************/
// Inputs:
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//    max -> Maximum value the oscilator will count to, given by the lookup table
//
// Outputs:
//    count -> Current value that the oscilator is on while counting
//   
/*************************************************************************************************************/

module oscilator (input logic clk, nrst, input logic [18:0] max, output logic [18:0]count);

  logic [18:0]next_count; // Initializing next_count variable for use in flip-flop

  always_ff @(posedge clk, negedge nrst) begin
    if(nrst)
    count <= next_count;
    else
    count <= 1; // Reset sets count to one
  end

  always_comb begin
    if(max == 19'd370000) begin
      next_count = 19'd1;
    end
    else begin
      if(count == max) begin
        next_count = 1; // Once the count hits the inputted max (divider) it wraps to 1
      end
      else begin
        next_count = count + 1; // Counting by 1
      end

    end 
  end

endmodule