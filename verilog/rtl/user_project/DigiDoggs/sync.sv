`default_nettype none

module syncronizer #(
    parameter WIDTH = 1,
    parameter DEPTH = 2
) (
    input logic clk, nrst, 
    input logic [WIDTH-1:0] async_in,
    output logic [WIDTH-1:0] sync_out
);

generate
    if (DEPTH == 0) begin
        assign sync_out = async_in;
    end
    else begin
        logic [DEPTH*WIDTH-1:0] internal_shift_reg;
        logic [DEPTH*WIDTH-1:0] next_internal_shift_reg;

        always_ff @(posedge clk, negedge nrst) begin
            if (~nrst)
                internal_shift_reg <= 0;
            else begin
                internal_shift_reg <= next_internal_shift_reg;
            end
        end

        assign next_internal_shift_reg = {async_in, internal_shift_reg[DEPTH*WIDTH-1:WIDTH]};
        assign sync_out = internal_shift_reg[WIDTH-1:0];
    end
endgenerate
    
endmodule
