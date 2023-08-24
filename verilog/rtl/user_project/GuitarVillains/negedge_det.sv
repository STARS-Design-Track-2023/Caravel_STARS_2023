module negedge_det(
    input logic clk, n_rst, in,
    output logic neg_edge
);
  logic edge_1, edge_2;

  always_ff @ (posedge clk, negedge n_rst) begin
    if (~n_rst) begin
      edge_1 <= 0;
      edge_2 <= 0;
    end
    else begin
      edge_1 <= in;
      edge_2 <= edge_1;
    end
  end
 
  assign neg_edge = ~edge_1 & edge_2;
endmodule