module buffer_register(
    input logic clk, nrst, 
    input logic signal_in,
    output logic signal_out
  );


  always_ff @ (posedge clk, negedge nrst) begin
  if (!nrst) begin
    signal_out <= 0;
  end
  else begin
    signal_out <= signal_in; 
  end
end

//mosi is 17 bits
endmodule
