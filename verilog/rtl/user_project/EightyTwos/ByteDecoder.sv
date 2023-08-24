`default_nettype none

module ByteDecoder (
  input logic clk, n_rst, instr_ready,
  input logic [7:0] new_instr,
  input logic shift_en,
  input logic [1:0] state,
  output logic [1:0] next_num_bytes
);

logic [1:0] num_bytes;

always_comb begin : ByteDecoder
    if (state == 0) begin
        if(new_instr[2:0] == 3'b110 & ~(new_instr[7] ^ new_instr[6]) || // MVI and Immediate ALU
            (new_instr == 8'b11010011 || // OUT (Not Used)
            new_instr == 8'b11011011) // IN (Not Used)
        ) begin
            next_num_bytes = 2'd2;
        end
        else if ((new_instr[7:6] == 2'b00 & (new_instr[3:0] == 4'b0001 | {new_instr[5], new_instr[2:0]} == 4'b1010)) || // LXI and SHLD/LHLD and STA/LDA
                (new_instr[7:6] == 2'b11 & new_instr[2:0] == 3'b010) || // Conditional Jumps
                (new_instr[7:6] == 2'b11 & new_instr[2:0] == 3'b100) || // Conditional Calls (Not Used)
                (new_instr[7:6] == 2'b11 & new_instr[3:0] == 4'b1100) || // CALL (Not Used) (Some Illegal Opcodes)
                new_instr == 8'b11000011 || // JMP
                new_instr == 8'b11001011 // JMP (Illegal Opcode)
        ) begin
            next_num_bytes = 2'd3;
        end
        else begin
            next_num_bytes = 2'd1;
        end
    end
    else begin
        next_num_bytes = num_bytes;
    end
end

always_ff @(posedge clk, negedge n_rst) begin : Remember_num_bytes
    if (!n_rst) begin
        num_bytes <= 2'd0;
    end
    else begin
        num_bytes <= next_num_bytes;
    end
end

endmodule