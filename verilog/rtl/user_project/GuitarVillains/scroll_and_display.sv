module scroll_and_display (
    input logic clk, n_rst, scroll,
    input logic [31:0] notes1, notes2,
    input logic [2:0] mode,
    output logic [38:0] padded_notes1, padded_notes2,
    output logic [13:0] out
);
  logic [38 : 0] shift1, shift2;
  logic [6:0] curr1, curr2;
  always_ff @ (posedge clk, negedge n_rst) begin
    if (~n_rst) begin
      padded_notes1 <= {7'b0, 32'hcccccccc};
      padded_notes2 <= {7'b0, 32'hAAAAAAAA};
    end
    else begin
      padded_notes1 <= shift1;
      padded_notes2 <= shift2;
    end
  end

  always_comb begin

    if(mode == 3'd3) begin 
      shift1 = {7'b0, notes1};
      shift2 = {7'b0, notes2};   
    end
    else begin
      shift1 = padded_notes1;
      shift2 = padded_notes2;   
    end   

    if(mode == 3'd4) begin
      if (scroll) begin
        shift1 = padded_notes1 << 1;
        shift2 = padded_notes2 << 1;
      end
      else begin
        shift1 = padded_notes1;
        shift2 = padded_notes2;
      end
    end
    curr1 = padded_notes1[38: 32];
    curr2 = padded_notes2[38: 32];
  
    out = {curr2, curr1};

  end

endmodule