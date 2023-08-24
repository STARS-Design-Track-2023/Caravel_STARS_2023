module keypad_encoder(
input logic clk, n_rst,
input logic [14:0] pb,
output logic [3:0] keycode,
output logic mode_edge,
output logic sound_edge
);

logic [14:0] q;
logic [14:0] sync_out;
always_ff @(posedge clk, negedge n_rst) begin : sync
    if (n_rst == 1'b0) begin
        sync_out <= 0;
        q <= 0;
    end
    else begin
        q <= pb;
        sync_out <= q;
    end  
end

always_comb begin
casez (sync_out[12:0])
    13'b????????????1: keycode = 4'b0000; //C(low)
    13'b???????????10: keycode = 4'b0001; //C#
    13'b??????????100: keycode = 4'b0010; //D
    13'b?????????1000: keycode = 4'b0011; //D#
    13'b????????10000: keycode = 4'b0100; //E
    13'b???????100000: keycode = 4'b0101; //F
    13'b??????1000000: keycode = 4'b0110; //F#
    13'b?????10000000: keycode = 4'b0111; //G
    13'b????100000000: keycode = 4'b1000; //G#
    13'b???1000000000: keycode = 4'b1001; //A
    13'b??10000000000: keycode = 4'b1010; //A#
    13'b?100000000000: keycode = 4'b1011; //B
    13'b1000000000000: keycode = 4'b1100; //C(high)
    default: keycode = 4'b1111; //No valid output
endcase    
end

logic last_mk;
always_ff @(posedge clk, negedge n_rst) begin : e_detect

if (n_rst == 1'b0) begin
        last_mk <= 0;
    end
    else begin
        last_mk <= sync_out[13];
    end  
end

assign mode_edge = sync_out[13] & ~last_mk;

logic last_sk;
always_ff @(posedge clk, negedge n_rst) begin : s_detect

if (n_rst == 1'b0) begin
        last_sk <= 0;
    end
    else begin
        last_sk <= sync_out[14];
    end  
end

assign sound_edge = sync_out[14] & ~last_sk;


endmodule