// `default_nettype none

// module top 
// (
//   // I/O ports
//   input  logic hz12M, reset,
//   input  logic [20:0] pb,
//   output logic [7:0] left, right,
//          ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
//   output logic red, green, blue,

//   // UART ports
//   output logic [7:0] txdata,
//   input  logic [7:0] rxdata,
//   output logic txclk, rxclk,
//   input  logic txready, rxready
// );

// synth_top U1 (.keypad_i(pb[14:0]), .en(pb[18]), .clk(hz12M), .n_rst(pb[19]), .pwm_o(left[7])); 

// endmodule

module synth (input logic en, input logic [14:0] keypad_i, input logic clk, n_rst, output logic pwm_o, output logic [3:0] sound_series);
logic [3:0] keycode;
logic mode_key, sound_edge;
keypad_encoder kp_encoder (.clk(clk), .n_rst(n_rst), .pb(keypad_i), .keycode(keycode), .mode_edge(mode_key), .sound_edge(sound_edge));

logic clkdiv;
//logic [3:0] sound_series;
sound_series_fsm SS_FSM (.clk(clk), .n_rst(n_rst), .sound_edge(sound_edge),.note_out(sound_series), .clkdiv(clkdiv));


logic [15:0] divider;
frequency_divider frqdiv (.keycode(keycode),.sound_series(sound_series),.divider(divider), .is_FPGA(1'b1), .en(en));

logic [15:0] count;
oscillator osc (.clk(clk), .n_rst(n_rst),.divider(divider),.count(count), .en(en));


logic sample_now;
clock_div clk_div (.clk(clk), .n_rst(n_rst), .flag(sample_now), .en(en));


logic [7:0] quotient;
sequential_div seq_div (.clk(clk), .n_rst(n_rst), .count(count),.flag(sample_now), .q_out(quotient), .divider(divider));


logic [1:0] wave_select;
mode_fsm mode_FSM (.clk(clk), .n_rst(n_rst), .modekey_edge(mode_key), .mode(wave_select));


logic [7:0] sample;
waveshaper waveshaper (.mode(wave_select), .quotient(quotient), .sample(sample));


pwm pwm (.clk(clk), .n_rst(n_rst), .sample(sample), .pwm_o(pwm_o), .en(en));


clock_8Hz clk8 (.clk(clk), .n_rst(n_rst), .en(en), .is_FPGA(1'b1), .flag(clkdiv));

endmodule 
