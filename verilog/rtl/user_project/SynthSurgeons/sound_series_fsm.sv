module sound_series_fsm(
input logic sound_edge, clkdiv, n_rst, clk,
output logic [3:0] note_out
);

typedef enum logic [1:0] {off,sound1, off2, sound2} state_sound;
typedef enum logic [3:0] {OFF = 4'hF,C = 4'h0,Cs = 4'h1,
                          D = 4'h2,Ds = 4'h3,E = 4'h4,
                          F = 4'h5,Fs = 4'h6,G = 4'h7,
                          Gs = 4'h8,A = 4'h9,As = 4'hA,
                          B = 4'hB,Ch = 4'hC} tone;

logic [3:0] note, next_note;
logic [1:0] sound, next_sound;
logic  s1_on, s2_on;

always_comb begin

  case(sound)
    off: next_sound = sound_edge ? sound1:off;
    sound1: next_sound = sound_edge ? off2:sound1;
    off2: next_sound = sound_edge ? sound2:off2;
    sound2: next_sound = sound_edge ? off:sound2;
    default next_sound = off;
  endcase

  if(sound == sound1) begin
    s1_on = 1;
    s2_on = 0;
  end
  else if(sound == sound2) begin
    s1_on = 0;
    s2_on = 1;
  end
  else begin
    s1_on = 0;
    s2_on = 0;
  end

end


always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0)
    sound <= off;
  else
    sound <= next_sound;
end

logic [1039:0] sound1_data;
logic [51:0] sound2_data;

assign sound1_data = {
  Ds,  OFF, OFF, OFF, OFF, OFF, OFF, OFF, E,   OFF, OFF, OFF, OFF, OFF, OFF, OFF, Fs,  OFF, OFF, B,   OFF, OFF, As,  OFF, B,   OFF, // 26-Note Line
  OFF, Fs,  OFF, OFF, Ds,  OFF, B,   OFF, OFF, Cs,  OFF, OFF, Ds,  OFF, Cs,   OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF,
  OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, Ds,  OFF, OFF, OFF, OFF, OFF, OFF, OFF, E,   OFF, OFF, OFF, OFF, OFF, 
  Ds,  E,   Fs,  OFF, OFF, B,   OFF, OFF, Cs,  OFF, B,   OFF, OFF, OFF, OFF, OFF, B,   Cs,  E,   OFF, OFF, Ds,  OFF, OFF, Cs,  OFF,
  B,   OFF, OFF, OFF, Fs,  OFF, Gs,  OFF, OFF, OFF, Cs,  OFF, Cs,  OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, Cs,  Ds,  E,   OFF,
  OFF, Ds,  OFF, OFF, Cs,  OFF, B,   OFF, OFF, /*Cs,*/  B,   As,  /*Fs,*/  OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF,
  OFF, OFF, Cs,  Ds,  E,   OFF, OFF, Ds,  OFF, OFF, Cs,  OFF, B,   OFF, OFF, Ds,  /*Fs,*/  Cs,  /*E,*/   OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF,
  OFF, OFF, OFF, OFF, OFF, OFF, OFF, OFF, Fs,  Gs,  A,   OFF, OFF, Gs,  OFF, OFF, Fs,  OFF, E,   OFF, OFF, OFF, OFF, OFF, E,   Fs,
  G,   OFF, OFF, Fs,  OFF, OFF, E,   OFF, D,   OFF, OFF, OFF, OFF, OFF, D,   E,   F,   OFF, OFF, E,   OFF, OFF, D,   OFF, OFF, C,
  OFF, OFF, G,   OFF, OFF, E,   OFF, OFF, C,   OFF, F,   OFF, OFF, OFF, OFF, OFF, C,   OFF, C,   OFF, OFF, OFF, OFF, OFF, OFF, OFF
};

assign sound2_data = {
  C, Cs, D, Ds, E, F, Fs, G, Gs, A, As, B, Ch
};

assign note_out = (s1_on) ? sound1_data[(count<<2) - 1 -: 4] : (s2_on) ? sound2_data[(count << 2) - 1 -: 4] : OFF;

logic [8:0] next_count;
logic [8:0] count;

always_ff @ (posedge clk, negedge n_rst) begin 
  if (n_rst == 0) begin
    count <= 9'd260; end
  else begin
    count <= next_count; end
end

always_comb begin
  if (s1_on) begin
    if(clkdiv) begin
      if (count == 1) begin
        next_count = 9'd260;
      end
      else begin
        next_count = count - 1; 
      end
    end
    else
      next_count = count;
  end
  else begin
    next_count = 9'd260;
  end

  if (s2_on) begin
    if(clkdiv) begin
      if (count == 1 || count >= 14) begin
        next_count = 9'd13;
      end
      else begin
        next_count = count - 1; 
      end
    end
    else
      next_count = count;
  end

end

endmodule