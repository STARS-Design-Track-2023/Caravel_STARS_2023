`default_nettype none
module mode_fsm (
    // HW
    input logic modekey_edge, clk, n_rst,
    output logic [1:0] mode
);
logic [1:0] next_mode;
typedef enum logic [1:0] {saw, _tri, off, sq} state_t; 
always_ff @ (posedge clk, negedge n_rst) begin
  if(1'b0 == n_rst) begin
    mode <= saw;
  end
  else begin
    mode <= next_mode;
  end
end
always_comb begin
    case(mode)
    saw : next_mode = (modekey_edge ? _tri : saw);
    _tri : next_mode = (modekey_edge ? sq : _tri);
    sq : next_mode = (modekey_edge ? off : sq);
    off : next_mode = (modekey_edge ? saw : off);
    endcase

end



endmodule