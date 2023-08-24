module freq_table(input logic goof, 
             input logic [2:0] octave,
             input logic [5:0] rng,
             input logic [3:0] keycode,
             output logic [17:0] frequency); 
/*
 if goof=1 
 * read rng as decimal, output frequency of note using rng as index
 * else
 * read modekey and octave as index in frequency table
*/

// divider list for top notes @ 10 Mhz
localparam C2 = 18'd152882;
localparam Cs2 = 18'd144300;
localparam D2 = 18'd136203;
localparam Ds2 = 18'd128568;
localparam E2 = 18'd121345;
localparam F2 = 18'd114534;
localparam Fs2 = 18'd108180;
localparam G2 = 18'd102040;
localparam Gs2 = 18'd96311;
localparam A2 = 18'd90909;
localparam As2 = 18'd85807;
localparam B2 = 18'd80991;
localparam C3 = 18'd76446;

always_comb begin
    frequency = C3 >> 1;
    if (goof) begin
        case (rng)
            6'd0:  frequency = C2 >> 0;
            6'd1:  frequency = Cs2 >> 0;
            6'd2:  frequency = D2 >> 0;
            6'd3:  frequency = Ds2 >> 0;
            6'd4:  frequency = E2 >> 0;
            6'd5:  frequency = F2 >> 0;
            6'd6:  frequency = Gs2 >> 0;
            6'd7:  frequency = G2 >> 0;
            6'd8:  frequency = Gs2 >> 0;
            6'd9:  frequency = A2 >> 0;
            6'd10: frequency = As2 >> 0;
            6'd11: frequency = B2 >> 0;
            6'd12: frequency = C2 >> 1;
            6'd13: frequency = Cs2 >> 1;
            6'd14: frequency = D2 >> 1;
            6'd15: frequency = Ds2 >> 1;
            6'd16: frequency = E2 >> 1;
            6'd17: frequency = F2 >> 1;
            6'd18: frequency = Fs2 >> 1;
            6'd19: frequency = G2 >> 1;
            6'd20: frequency = Gs2 >> 1;
            6'd21: frequency = A2 >> 1;
            6'd22: frequency = As2 >> 1;
            6'd23: frequency = B2 >> 1;
            6'd24: frequency = C2 >> 2;
            6'd25: frequency = Cs2 >> 2;
            6'd26: frequency = D2 >> 2;
            6'd27: frequency = Ds2 >> 2;
            6'd28: frequency = E2 >> 2;
            6'd29: frequency = F2 >> 2;
            6'd30: frequency = Fs2 >> 2;
            6'd31: frequency = G2 >> 2;
            6'd32: frequency = Gs2 >> 2;
            6'd33: frequency = A2 >> 2;
            6'd34: frequency = As2 >> 2;
            6'd35: frequency = B2 >> 2;
            6'd36: frequency = C2 >> 3;
            6'd37: frequency = Cs2 >> 3;
            6'd38: frequency = D2 >> 3;
            6'd39: frequency = Ds2 >> 3;
            6'd40: frequency = E2 >> 3;
            6'd41: frequency = F2 >> 3;
            6'd42: frequency = Fs2 >> 3;
            6'd43: frequency = G2 >> 3;
            6'd44: frequency = Gs2 >> 3;
            6'd45: frequency = A2 >> 3;
            6'd46: frequency = As2 >> 3;
            6'd47: frequency = B2 >> 3;
            6'd48: frequency = C2 >> 4;
            6'd49: frequency = Cs2 >> 4;
            6'd50: frequency = D2 >> 4;
            6'd51: frequency = Ds2 >> 4;
            6'd52: frequency = E2 >> 4;
            6'd53: frequency = F2 >> 4;
            6'd54: frequency = Fs2 >> 4;
            6'd55: frequency = G2 >> 4;
            6'd56: frequency = Gs2 >> 4;
            6'd57: frequency = A2 >> 4;
            6'd58: frequency = As2 >> 4;
            6'd59: frequency = B2 >> 4;
            6'd60: frequency = C2 >> 1;
            6'd61: frequency = C2 >> 2;
            6'd62: frequency = C2 >> 3;
            6'd63: frequency = C2 >> 4;
        endcase
    end
    else begin
        case (keycode)
            4'd0: frequency = C2 >> octave;
            4'd1: frequency = Cs2 >> octave;
            4'd2: frequency = D2 >> octave;
            4'd3: frequency = Ds2 >> octave;
            4'd4: frequency = E2 >> octave;
            4'd5: frequency = F2 >> octave;
            4'd6: frequency = Fs2 >> octave;
            4'd7: frequency = G2 >> octave;
            4'd8: frequency = Gs2 >> octave;
            4'd9: frequency = A2 >> octave;
            4'd10: frequency = As2 >> octave;
            4'd11: frequency = B2 >> octave;
            4'd12: frequency = C3 >> octave;
            default: frequency = C2 >> 2;
        endcase
    end
end

endmodule 