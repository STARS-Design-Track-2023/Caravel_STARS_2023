module finish_counter (
    input logic clk, beat_clk, n_rst,
    output logic finish
);

logic [5:0] nxt_pulse, fin_pulse;

always_comb begin
    if ((beat_clk == 1'd1) && (fin_pulse != 6'd41))
        nxt_pulse = fin_pulse + 1;
    else if (fin_pulse == 6'd41)
        nxt_pulse = 6'b0;
    else   
        nxt_pulse = fin_pulse;
end

always_ff @ (posedge clk, negedge n_rst) begin
    if (!n_rst)
        fin_pulse <= 6'b0;
    else   
        fin_pulse <= nxt_pulse;
end

always_comb begin
    if (fin_pulse == 6'd41)
        finish = 1'b1;
    else
        finish = 1'b0;
end

endmodule