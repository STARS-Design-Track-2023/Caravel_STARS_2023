module clk_div(
  input logic clk, n_rst,
  input logic [22:0] lim,
  input logic [2:0]mode,
  output logic hzX,
  output logic [22:0] counter
);
  always_ff @ (posedge clk, negedge n_rst) begin
    if (~n_rst) begin
      counter <= 0;
      hzX <= 0;
    end
    else begin
      if ((counter == lim) && (mode == 3'd4)) begin
        counter <= 0;
        hzX <= 1'b1;
      end
      else begin
        counter <= counter + 1;
        hzX <= 1'b0;
      end
    end
  end
endmodule