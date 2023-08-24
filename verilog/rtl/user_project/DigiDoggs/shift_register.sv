`default_nettype none

module shift_reg #( 
    parameter DEPTH = 24,
    parameter ENTERS_AT_LSB = 1
) (
    input logic clk, nrst, en, q,
    output logic [DEPTH-1:0] p_out
);
    
    logic [DEPTH-1:0] next_p_out, p_shifted;

    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) 
            p_out <= 0;
        else
            p_out <= next_p_out;
    end

    assign next_p_out = en ? p_shifted : p_out;

    generate
        if (ENTERS_AT_LSB) begin
            assign p_shifted = {p_out[DEPTH-2:0], q};
        end
        else begin
            assign p_shifted = {q, p_out[DEPTH-1:1]};
        end
    endgenerate

endmodule
