`default_nettype none

module instruction_register(
    input logic clk, nrst,
    input logic [7:0] data,
    input logic hold, mem_ack, clear,
    output logic [7:0] opcode_o,
    output logic [15:0] immediate
);
    logic [7:0] opcode, imm_low, imm_high;
    logic [1:0] idx, next_idx;

    always_comb begin
        if (clear) next_idx = 0;
        else if (hold) next_idx = idx;
        else next_idx = idx + mem_ack;
        opcode_o = opcode;
        immediate = {imm_high, imm_low};
    end

    always_ff @(posedge clk, negedge nrst) begin
        if (!nrst) begin
            {opcode, imm_low, imm_high} <= {8'b0, 8'b0, 8'b0};
            idx <= 2'b0;
        end else begin
            idx <= next_idx;
            case (idx)
                2'b00   : opcode <= data;
                2'b01   : imm_low <= data;
                2'b10   : imm_high <= data;
                default : ;
            endcase
        end
    end
endmodule
