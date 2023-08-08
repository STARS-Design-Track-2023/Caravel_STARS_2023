// ************************************************************************************************
// Soundpath module
//   inputs: sample_now <- from sample clk divider to activate seqdiv
//           mode <- off, sqare, saw, triangle
//           note <- from key decoder expects a note 1 - 13
//           octave <- used to shift the values in LUT to correct octave
//           clk
//           n_rst <- expects a ACTIVE LOW rst Signals
//   output: sample <- 8 bit sample to be give to wave_comb and pwm
//           done <- signals when value is ready to be read
//
//   Use: This is an integration module that groups together the oscilator, seqential divider, and
//        waveshaper as they are always used together in a path.
// ************************************************************************************************

module soundpath(input logic clk, n_rst, sample_now,
                 input logic [3:0] note,
                 input logic [2:0] octave,
                 input logic [1:0] mode,
                 output logic [8:0] sample,
                 output logic done
);

  logic [8:0] Q; //quotient value before it is shaped by the waveshaper
  logic [18:0] count; //counting up value from oscilator, serves as dividend
  logic [18:0] divisor; //value from LUT based on key pressed

  logic [18:0] count_m;
  logic [18:0] divisor_m;

  lookup_table LUT (.note(note),
                    .octave(octave),
                    .divider(divisor));

  oscilator osc (.clk(clk),
                   .nrst(n_rst),
                   .max(divisor),
                   .count(count));

  seqdiv sdiv (.clk(clk),
               .RST(n_rst),
               .sample(sample_now),
               .count(count),
               .dsor(divisor),
               .done(done),
               .Q_out(Q),
               .count_m(count_m),
               .divisor_m(divisor_m));

  waveshaper waveshape (.Q(Q),
                        .mode({1'b0, mode}),
                        .count(count_m),
                        .divisor(divisor_m),
                        .sample(sample));

endmodule