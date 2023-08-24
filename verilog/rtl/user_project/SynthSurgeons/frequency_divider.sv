module frequency_divider (input logic [3:0] keycode, input logic [3:0] sound_series, input logic is_FPGA, en, output logic [15:0] divider);

logic [15:0] LUT_10MHz;
logic [15:0] LUT_12MHz;

/*
logic [15:0] LUT_10MHz [13] = {
    16'd19111,   // C (high)
    16'd20248,   // B
    16'd21452,   // A#
    16'd22727,   // A
    16'd24079,   // G#
    16'd25511,   // G
    16'd27027,   // F#
    16'd28635,   // F
    16'd30337,   // E
    16'd32141,   // D#
    16'd34052,   // D
    16'd36077,   // C#
    16'd38223   // C (low)
};

logic [15:0] LUT_12MHz [13] ={
    16'd22933,   // C (high)
    16'd24298,   // B
    16'd25742,   // A#
    16'd27272,   // A
    16'd28895,   // G#
    16'd30613,   // G
    16'd32432,   // F#
    16'd34362,   // F
    16'd36404,   // E
    16'd38569,   // D#
    16'd40862,   // D
    16'd43292,   // C#
    16'd45868   // C (low)
};
*/

logic [3:0] intermediate;

always_comb begin: selection
intermediate=4'b1111;
  if (en==1) begin
    if ((keycode != 4'b1111) && (sound_series == 4'b1111)) begin
        if ((keycode == 4'b1101 || keycode == 4'b1110)) begin
           intermediate=4'b1111;
        end
        else begin
          intermediate=keycode;
        end
    end
    else if ((keycode == 4'b1111) && (sound_series != 4'b1111)) begin
      if ((sound_series == 4'b1101 || sound_series == 4'b1110)) begin
        intermediate=4'b1111;
      end
      else begin
        intermediate=sound_series;
      end
    end
  end
end

always_comb begin : LUT_10MHz_set
  case(intermediate)
    4'd12: LUT_10MHz = 16'd19111;   // C (HIGH)
    4'd11: LUT_10MHz = 16'd20248;   // B
    4'd10: LUT_10MHz = 16'd21452;   // A#
    4'd9:  LUT_10MHz = 16'd22727;   // A
    4'd8:  LUT_10MHz = 16'd24079;   // G#
    4'd7:  LUT_10MHz = 16'd25511;   // G
    4'd6:  LUT_10MHz = 16'd27027;   // F#
    4'd5:  LUT_10MHz = 16'd28635;   // F
    4'd4:  LUT_10MHz = 16'd30337;   // E#
    4'd3:  LUT_10MHz = 16'd32141;   // E
    4'd2:  LUT_10MHz = 16'd34052;   // D#
    4'd1:  LUT_10MHz = 16'd36077;   // D
    4'd0:  LUT_10MHz = 16'd38223;   // C(LOW) 
    default: LUT_10MHz = 16'd1;
  endcase
end

always_comb begin: LUT_12MHz_set
case(intermediate)
4'd12: LUT_12MHz = 16'd22933;   // C (HIGH)
4'd11: LUT_12MHz = 16'd24298;   // B
4'd10: LUT_12MHz = 16'd25742;   // A#
4'd9:  LUT_12MHz = 16'd27272;   // A
4'd8:  LUT_12MHz = 16'd28895;   // G#
4'd7:  LUT_12MHz = 16'd30613;   // G
4'd6:  LUT_12MHz = 16'd32432;   // F#
4'd5:  LUT_12MHz = 16'd34362;   // F
4'd4:  LUT_12MHz = 16'd36404;   // E#
4'd3:  LUT_12MHz = 16'd38569;   // E
4'd2:  LUT_12MHz = 16'd40862;   // D#
4'd1:  LUT_12MHz = 16'd43292;   // D
4'd0:  LUT_12MHz = 16'd45868;   // C (LOW) 
default: LUT_12MHz = 16'd1;
endcase; 
end



always_comb begin : LUTS 
  if (is_FPGA == 0) begin
    divider= LUT_10MHz; 
  end
  else begin
    divider= LUT_12MHz; 
  end
end
endmodule