`default_nettype none

module JumpFlagController(input logic [7:0] flags,
                         input logic [2:0] jump_flag,
                         input logic jump_en,
                         output logic jump);

always_comb begin
    //jump flag controls which flag jump dectects
    case(jump_flag)
        3'b000: jump =  (jump_en | (jump_en & ~flags[6]));  //jump_en ? 1'b1 : (~flags[6]);    // jump_en or non-zero
        3'b001: jump = (flags[6]);                      // zero
        3'b010: jump = (~flags[0]);                     // non-carry
        3'b011: jump = (flags[0]);                      // carry
        3'b100: jump = (~flags[2]);                     // parity odd
        3'b101: jump = (flags[2]);                      // parity even
        3'b110: jump = (flags[7]);                      // plus
        3'b111: jump = (~flags[7]);                     // minus
        default: jump = 0;
    endcase
end

endmodule