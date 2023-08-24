`default_nettype none

module posedge_detector (
    input logic clk, nrst, 
    input logic signal,
    output logic posedge_detected
);

logic q;

always_ff @(posedge clk, negedge nrst) begin
  if (~nrst)
    q <= 0;
  else
    q <= signal;
end

assign posedge_detected = ~q & signal;

endmodule
