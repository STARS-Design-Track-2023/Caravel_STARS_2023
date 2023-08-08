`default_nettype none

module counter #(
    parameter N = 4
) (
    input logic clk, nrst, clear, wrap, en, 
    input logic [N-1:0] max,
    output logic [N-1:0] count,
    output logic at_max
);

logic [N-1:0] next_count;

always_ff @(posedge clk, negedge nrst, posedge clear) begin
    if (~nrst)
        count <= 0;
    else if (clear)
        count <= 0;
    else
        count <= next_count;
end

always_comb begin
    casez ({clear, en, wrap})
        3'b1??: next_count = 0; // Clear condition
        3'b00?: next_count = count; // Unenabled condition
        3'b010: next_count = (at_max) ? count : count + 1; // Unwraped condition
        3'b011: next_count = (at_max) ? 0 : count + 1; // Wrapped condition
        default: next_count = {N{1'bx}}; // "Oh shit something went wrong" condition
    endcase
end

assign at_max = (count == max);
    
endmodule