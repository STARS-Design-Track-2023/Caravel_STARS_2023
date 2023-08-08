`default_nettype none

module top_asic 
(
  // I/O ports
  input  logic clk, reset,
  input  logic [14:0] pb,
  output logic sigout,
  output logic [1:0] mode_out,

);

logic modekey;              //modekey signal  to be used for mode change
logic octave_up, octave_down; //octave up and down signals
logic [11:0] done;          //done signals from wave shaper
logic [1:0] mode;           //mode signal
logic [17:0] freq_div_table [11:0]; //frequency division table
logic [17:0] Count [11:0];  //counters for wave shaper from oscillator
logic [7:0] samples [11:0]; //samples from wave shaper to signal mixer
logic [11:0] sample_enable; //sample enable for signal mixer
logic [7:0] final_sample;   //final sample from normalizer to pwm
logic [11:0] mixed_sample;  //mixed sample from signal mixer
logic [3:0] num_signals;    //number of signals to be mixed
logic start;                //start signal from wave shaper
logic pwm, pwm_out;         //pwm output

assign sample_enable = pb[11:0]; //sample enable from keypad

//keypad for modekey //good
keypad modein(
    .clk(clk),
    .n_rst(reset),
    .mode_in(pb[14]),
    .octave_in({pb[13], pb[12]}),
    .modekey(modekey),
    .octave_up(octave_up),
    .octave_down(octave_down)
);

//freq divider table //good
frequency_divider freq_div(
    .clk(clk),
    .nrst(reset),
    .o_up(octave_up),
    .o_down(octave_down),
    .div0(freq_div_table[0]),
    .div1(freq_div_table[1]),
    .div2(freq_div_table[2]),
    .div3(freq_div_table[3]),
    .div4(freq_div_table[4]),
    .div5(freq_div_table[5]),
    .div6(freq_div_table[6]),
    .div7(freq_div_table[7]),
    .div8(freq_div_table[8]),
    .div9(freq_div_table[9]),
    .div10(freq_div_table[10]),
    .div11(freq_div_table[11])
);


//sample rate clk div // good
sample_rate_clkdiv smpl_rt_clkdiv(
  .clk(clk),
  .n_rst(reset),
  .sample_now(start)
);

//oscillators
generate
  genvar i;
    for (i=0; i<12; i= i +1)begin
        oscillator osc(
            .clk(clk),
            .n_rst(reset),
            .freq_in(freq_div_table[i]),
            .count_out(Count[i])
        );
    end
endgenerate

//FSM
fsm FSM(
    .clk(clk),
    .n_rst(reset),
    .modekey(modekey),
    .mode(mode)
);

//waveshapers
generate
        for (i = 0; i < 12; i = i + 1) begin
            waveshaper wave_shpr(
                .clk(clk),
                .nrst(reset),
                .fd(freq_div_table[i]),
                .count(Count[i]),
                .mode(mode),
                .start(start),
                .signal(samples[i]),
                .done(done[i])
            );
        end
endgenerate


//signal mixer
signal_mixer mixer(
    .sample1(samples[0]),
    .sample2(samples[1]),
    .sample3(samples[2]),
    .sample4(samples[3]),
    .sample5(samples[4]),
    .sample6(samples[5]),
    .sample7(samples[6]),
    .sample8(samples[7]),
    .sample9(samples[8]),
    .sample10(samples[9]),
    .sample11(samples[10]),
    .sample12(samples[11]),
    .sample_enable(sample_enable),
    .sample_out(mixed_sample),
    .num_signals(num_signals)
);

logic norm_done; //done signal from normalizer
sequential_div #(12) sig_norm(
    .clk(clk),
    .nrst(reset),
    .start(|done),
    .dividend(mixed_sample),
    .divisor({8'b0,num_signals}),
    .fin_quo(final_sample),
    .done(norm_done),
    .rem()
);


//pwm
pwm PWM(
  .clk(clk),
  .n_rst(reset),
  .start(norm_done),
  .final_in(final_sample),
  .pwm_out(pwm)
);

//output logic
always_ff @(posedge clk, negedge reset)
  if(!reset) begin
    pwm_out <= 0;
  end
  else begin 
    pwm_out <= pwm;
  end 

assign sigout = pwm_out;
assign mode_out = mode;

endmodule
