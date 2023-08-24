module bcdssdec (
    input logic enable,
    input logic [7:0] in,
    output logic [13:0] out
);

logic [6:0] SEG7 [9:0];

always_comb begin
    SEG7[4'b0000] = 7'b0111111;
    SEG7[4'b0001] = 7'b0000110;
    SEG7[4'b0010] = 7'b1011011;
    SEG7[4'b0011] = 7'b1001111;
    SEG7[4'b0100] = 7'b1100110;
    SEG7[4'b0101] = 7'b1101101;
    SEG7[4'b0110] = 7'b1111101;
    SEG7[4'b0111] = 7'b0000111;
    SEG7[4'b1000] = 7'b1111111;
    SEG7[4'b1001] = 7'b1100111;
end

assign out = (enable) ? {SEG7[in[7:4]], SEG7[in[3:0]]} : 0;

endmodule