`default_nettype none

module program_counter#(parameter RESET_ADDR=16'h1000)(
    input logic clk, nrst,
    input logic next_instruction_request, condition_is_true, jump_is_relative, call_or_jump,
    input logic [7:0] offset,
    input logic [15:0] absolute,
    output logic [15:0] pc_o
);
    logic [15:0] next_pc;

    always_comb begin
        if (next_instruction_request) begin
            if (condition_is_true) begin
                if (jump_is_relative) next_pc = pc_o + {{8{offset[7]}}, offset};
                else if (call_or_jump) next_pc = absolute;
                else next_pc = pc_o + 1;
            end else next_pc = pc_o + 1;
        end else next_pc = pc_o;
    end

    always_ff @(posedge clk, negedge nrst) begin
        if (!nrst) pc_o <= RESET_ADDR;
        else pc_o <= next_pc;
    end
endmodule
