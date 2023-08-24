`default_nettype none
// Empty top module

module inputandcontroller (
  // USER INPUTS
  input logic [14:0] INPUT_keypad_i,
  input logic INPUT_clk,
  input logic INPUT_NRST,
  // USER OUTPUTS
  output logic OUTPUT_octave_input_out, OUTPUT_mode_out,
  output logic [3:0] OUTPUT_multi,
  output logic [3:0] OUTPUT_note_1, OUTPUT_note_2, OUTPUT_note_3, OUTPUT_note_4
);
// INTERNAL SIGNALS
logic [12:0] INTERNAL_SYNCED_I;
logic INTERNAL_OCTAVE_INPUT, INTERNAL_MODE;
// Module instances
synchronizer u1 (.keypad_i(INPUT_keypad_i), .clk(INPUT_clk), .nrst(INPUT_NRST), .synced_i(INTERNAL_SYNCED_I), .octave_input(INTERNAL_OCTAVE_INPUT), .mode(INTERNAL_MODE));
edgedetector u2 (.in(INTERNAL_OCTAVE_INPUT), .clk(INPUT_clk), .nrst(INPUT_NRST), .ris_edge_o(OUTPUT_octave_input_out));
edgedetector u3 (.in(INTERNAL_MODE), .clk(INPUT_clk), .nrst(INPUT_NRST), .ris_edge_o(OUTPUT_mode_out));
adder_encoder u4 (.key(INTERNAL_SYNCED_I), .multi(OUTPUT_multi), .note_1(OUTPUT_note_1), .note_2(OUTPUT_note_2), .note_3(OUTPUT_note_3), .note_4(OUTPUT_note_4));
endmodule


module synchronizer (
  input logic [14:0] keypad_i,
  input logic clk, nrst,
  output logic [12:0] synced_i,
  output logic octave_input, mode
);
logic [14:0] ff_intermediate;
always_ff @( posedge clk, negedge nrst ) begin : ff1
  if (~nrst)
    ff_intermediate <= 15'b0;
  else
    ff_intermediate <= keypad_i;
end
always_ff @( posedge clk, negedge nrst ) begin : ff2
  if (~nrst)
  begin
    synced_i <= 13'b0;
    octave_input <= 1'b0;
    mode <= 1'b0;
  end
  else
  begin
    synced_i <= ff_intermediate[12:0];
    octave_input <= ff_intermediate[13];
    mode <= ff_intermediate[14];
  end
end
endmodule


module edgedetector (
  input logic in,
  input logic clk, nrst,
  output logic ris_edge_o
);
logic next_in;
always_ff @( posedge clk, negedge nrst ) begin : edgedetector_ff
  if (~nrst)
    next_in <= 1'b0;
  else 
    next_in <= in;
end
always_comb begin
  ris_edge_o = in & (~next_in);
end
endmodule


module adder_encoder (
  input logic [12:0] key,
  output logic [3:0] multi,
  output logic [3:0] note_1, note_2, note_3, note_4
);
logic [12:0] intermediate_key1;
logic [12:0] intermediate_key2;
logic [12:0] intermediate_key3;
logic [12:0] intermediate_key4;
  // ADDER
logic [3:0] multi_temp;
assign multi_temp = {3'b0, key[0]} + {3'b0, key[1]} + {3'b0, key[2]} + {3'b0, key[3]} + {3'b0, key[4]} + {3'b0, key[5]} + {3'b0, key[6]} + {3'b0, key[7]} + {3'b0, key[8]} + {3'b0, key[9]} + {3'b0, key[10]} + {3'b0, key[11]} + {3'b0, key[12]};
assign multi = multi_temp > 4? 4 : multi_temp;
  // ENCODER
always_comb begin: BLOCK_1
intermediate_key1 = key;
casez(key)
  13'b????????????1: begin note_1 = 4'b0001; intermediate_key1[0] = 0; end
  13'b???????????10: begin note_1 = 4'b0010; intermediate_key1[1] = 0; end
  13'b??????????100: begin note_1 = 4'b0011; intermediate_key1[2] = 0; end
  13'b?????????1000: begin note_1 = 4'b0100; intermediate_key1[3] = 0; end
  13'b????????10000: begin note_1 = 4'b0101; intermediate_key1[4] = 0; end
  13'b???????100000: begin note_1 = 4'b0110; intermediate_key1[5] = 0; end
  13'b??????1000000: begin note_1 = 4'b0111; intermediate_key1[6] = 0; end
  13'b?????10000000: begin note_1 = 4'b1000; intermediate_key1[7] = 0; end
  13'b????100000000: begin note_1 = 4'b1001; intermediate_key1[8] = 0; end
  13'b???1000000000: begin note_1 = 4'b1010; intermediate_key1[9] = 0; end
  13'b??10000000000: begin note_1 = 4'b1011; intermediate_key1[10] = 0; end
  13'b?100000000000: begin note_1 = 4'b1100; intermediate_key1[11] = 0; end
  13'b1000000000000: begin note_1 = 4'b1101; intermediate_key1[12] = 0; end
  default: begin note_1 = 4'b0000; intermediate_key1 = 13'b0; end
endcase
end
always_comb begin : BLOCK_2
intermediate_key2 = intermediate_key1;
casez(intermediate_key1)
  13'b????????????1: begin note_2 = 4'b0001; intermediate_key2[0] = 0; end
  13'b???????????10: begin note_2 = 4'b0010; intermediate_key2[1] = 0; end
  13'b??????????100: begin note_2 = 4'b0011; intermediate_key2[2] = 0; end
  13'b?????????1000: begin note_2 = 4'b0100; intermediate_key2[3] = 0; end
  13'b????????10000: begin note_2 = 4'b0101; intermediate_key2[4] = 0; end
  13'b???????100000: begin note_2 = 4'b0110; intermediate_key2[5] = 0; end
  13'b??????1000000: begin note_2 = 4'b0111; intermediate_key2[6] = 0; end
  13'b?????10000000: begin note_2 = 4'b1000; intermediate_key2[7] = 0; end
  13'b????100000000: begin note_2 = 4'b1001; intermediate_key2[8] = 0; end
  13'b???1000000000: begin note_2 = 4'b1010; intermediate_key2[9] = 0; end
  13'b??10000000000: begin note_2 = 4'b1011; intermediate_key2[10] = 0; end
  13'b?100000000000: begin note_2 = 4'b1100; intermediate_key2[11] = 0; end
  13'b1000000000000: begin note_2 = 4'b1101; intermediate_key2[12] = 0; end
  default: begin note_2 = 4'b0000; intermediate_key2 = 13'b0; end
endcase
end
always_comb begin : BLOCK_3
intermediate_key3 = intermediate_key2;
casez(intermediate_key2)
  13'b????????????1: begin note_3 = 4'b0001; intermediate_key3[0] = 0; end
  13'b???????????10: begin note_3 = 4'b0010; intermediate_key3[1] = 0; end
  13'b??????????100: begin note_3 = 4'b0011; intermediate_key3[2] = 0; end
  13'b?????????1000: begin note_3 = 4'b0100; intermediate_key3[3] = 0; end
  13'b????????10000: begin note_3 = 4'b0101; intermediate_key3[4] = 0; end
  13'b???????100000: begin note_3 = 4'b0110; intermediate_key3[5] = 0; end
  13'b??????1000000: begin note_3 = 4'b0111; intermediate_key3[6] = 0; end
  13'b?????10000000: begin note_3 = 4'b1000; intermediate_key3[7] = 0; end
  13'b????100000000: begin note_3 = 4'b1001; intermediate_key3[8] = 0; end
  13'b???1000000000: begin note_3 = 4'b1010; intermediate_key3[9] = 0; end
  13'b??10000000000: begin note_3 = 4'b1011; intermediate_key3[10] = 0; end
  13'b?100000000000: begin note_3 = 4'b1100; intermediate_key3[11] = 0; end
  13'b1000000000000: begin note_3 = 4'b1101; intermediate_key3[12] = 0; end
  default: begin note_3 = 4'b0000; intermediate_key3 = 13'b0; end
endcase
end
always_comb begin : BLOCK_4
intermediate_key4 = intermediate_key3;
casez(intermediate_key3)
  13'b????????????1: begin note_4 = 4'b0001; intermediate_key4[0] = 0; end
  13'b???????????10: begin note_4 = 4'b0010; intermediate_key4[1] = 0; end
  13'b??????????100: begin note_4 = 4'b0011; intermediate_key4[2] = 0; end
  13'b?????????1000: begin note_4 = 4'b0100; intermediate_key4[3] = 0; end
  13'b????????10000: begin note_4 = 4'b0101; intermediate_key4[4] = 0; end
  13'b???????100000: begin note_4 = 4'b0110; intermediate_key4[5] = 0; end
  13'b??????1000000: begin note_4 = 4'b0111; intermediate_key4[6] = 0; end
  13'b?????10000000: begin note_4 = 4'b1000; intermediate_key4[7] = 0; end
  13'b????100000000: begin note_4 = 4'b1001; intermediate_key4[8] = 0; end
  13'b???1000000000: begin note_4 = 4'b1010; intermediate_key4[9] = 0; end
  13'b??10000000000: begin note_4 = 4'b1011; intermediate_key4[10] = 0; end
  13'b?100000000000: begin note_4 = 4'b1100; intermediate_key4[11] = 0; end
  13'b1000000000000: begin note_4 = 4'b1101; intermediate_key4[12] = 0; end
  default: begin note_4 = 4'b0000; intermediate_key4 = 13'b0; end
endcase
end
endmodule
