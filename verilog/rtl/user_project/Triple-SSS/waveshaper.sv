module waveshaper
        (input logic [17:0] divider, count, 
        input logic [7:0] scaled_sig, 
        input logic [1:0] mode, 
        output logic [7:0] wave_out);
    
    logic [9:0] wave;
    logic [9:0] used_sig;

    always_comb begin
        used_sig = {2'b0, scaled_sig};
        case(mode)
            2'b00:   wave = 0; // no wave
            2'b01:   wave = (count < (divider >> 1)) ? (used_sig << 1) : (10'd512 - (used_sig << 1)); // triangle wave
            2'b10:   wave = used_sig; // sawtooth wave
            2'b11:   wave = (count < (divider >> 1)) ? 255 : 0; // square wave
        endcase
    end

    always_comb begin
        if (wave == 10'd256)
            wave_out = 8'hff;
        else
            wave_out = wave[7:0];
    end
endmodule