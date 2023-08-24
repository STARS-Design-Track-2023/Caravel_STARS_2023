
/********************* for 12 MHz clock ********************************/
/*module lookup_table(input logic [3:0]note, input logic [2:0]octave,
                output logic [18:0]divider);
always_comb begin
  case(note)
   4'd1: divider = 19'd366937 >> octave; //C
   4'd2: divider = 19'd346342 >> octave; //C#
   4'd3: divider = 19'd326903 >> octave; //D
   4'd4: divider = 19'd308556 >> octave; //D#
   4'd5: divider = 19'd291238 >> octave; //E
   4'd6: divider = 19'd274892 >> octave; //F
   4'd7: divider = 19'd259463 >> octave; //F#
   4'd8: divider = 19'd244901 >> octave; //G
   4'd9: divider = 19'd231156 >> octave; //G#
   4'd10: divider = 19'd218182 >> octave; //A
   4'd11: divider = 19'd205936 >> octave; //A#
   4'd12: divider = 19'd194378 >> octave; //B
   4'd13: divider = 19'd183468 >> octave; //C
   default: divider = 19'd370000; //Off
  endcase
end
endmodule
*/

/********************* for 10 MHz clock ********************************/
module lookup_table(input logic [3:0]note, input logic [2:0]octave,
                output logic [18:0]divider);
always_comb begin
  case(note)
   4'd1: divider = 19'd305780 >> octave; //C
   4'd2: divider = 19'd288618 >> octave; //C#
   4'd3: divider = 19'd272419 >> octave; //D
   4'd4: divider = 19'd257130 >> octave; //D#
   4'd5: divider = 19'd242698 >> octave; //E
   4'd6: divider = 19'd229077 >> octave; //F
   4'd7: divider = 19'd216219 >> octave; //F#
   4'd8: divider = 19'd204084 >> octave; //G
   4'd9: divider = 19'd192630 >> octave; //G#
   4'd10: divider = 19'd181818 >> octave; //A
   4'd11: divider = 19'd171618 >> octave; //A#
   4'd12: divider = 19'd161982 >> octave; //B
   4'd13: divider = 19'd152890 >> octave; //C
   default: divider = 19'd370000; //Off
  endcase
end
endmodule