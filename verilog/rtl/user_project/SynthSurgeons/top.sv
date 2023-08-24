`default_nettype none

module top 
(
  // I/O ports
  input  logic hz12M, hz1000, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);



logic [3:0] display; 
logic [12:0] note;
synth U1 (.keypad_i(pb[14:0]), .en(~pb[18]), .clk(hz12M), .n_rst(~pb[19]), .pwm_o(left[7]), .sound_series(display));

assign {left[4:0], right[7:0]}=note;

always_comb begin
  note = pb [12:0];
  note[display] = 1'b1; 
end
endmodule
 

 // Seven Segment decoder
/*module ssdec (input logic [3:0] val, input logic dp_on, output [7:0] segment);
always_comb begin : encoder
  case(val)
  4'b0000 : segment[6:0] = 7'h3F; // 11111100
  4'b0001 : segment[6:0] = 7'h06; // 01100000
  4'b0010 : segment[6:0] = 7'h5B; // 11011010
  4'b0011 : segment[6:0] = 7'h4F; // 11110010
  4'b0100 : segment[6:0] = 7'h66; // 01100110          
  4'b0101 : segment[6:0] = 7'h6D; // 10110110
  4'b0110 : segment[6:0] = 7'h7D; // 10111110
  4'b0111 : segment[6:0] = 7'h07; // 11100000
  4'b1000 : segment[6:0] = 7'h7F; // 11111110
  4'b1001 : segment[6:0] = 7'h6F; // 11110110
  4'b1010 : segment[6:0] = 7'h77; // 11101110
  4'b1011 : segment[6:0] = 7'h7C; // 00111110
  4'b1100 : segment[6:0] = 7'h39; // 10011100
  4'b1101 : segment[6:0] = 7'h5E; // 01111010
  4'b1110 : segment[6:0] = 7'h79; // 10011110
  4'b1111 : segment[6:0] = 7'h71; // 10001110
  endcase
  segment[7] = dp_on;
end
endmodule*/



// module synth_top (input logic en, input logic [14:0] keypad_i, input logic clk, n_rst, output logic pwm_o);

// logic [3:0] keycode;
// logic mode_key, sound_edge;
// keypad_encoder kp_encoder (.clk(clk), .n_rst(n_rst), .pb(keypad_i), .keycode(keycode), .mode_edge(mode_key), .sound_edge(sound_edge));

// logic clkdiv;
// logic [3:0] sound_series;
// sound_series_fsm SS_FSM (.clk(clk), .n_rst(n_rst), .sound_edge(sound_edge),.note_out(sound_series), .clkdiv(clkdiv));


// logic [15:0] divider;
// frequency_divider frqdiv (.keycode(keycode),.sound_series(sound_series),.divider(divider), .is_FPGA(1'b1), .en(en));

// logic [15:0] count;
// oscillator osc (.clk(clk), .n_rst(n_rst),.divider(divider),.count(count), .en(en));


// logic sample_now;
// clock_div clk_div (.clk(clk), .n_rst(n_rst), .flag(sample_now), .en(en));


// logic [7:0] quotient;
// sequential_div seq_div (.clk(clk), .n_rst(n_rst), .count(count),.flag(sample_now), .q_out(quotient), .divider(divider));


// logic [1:0] wave_select;
// mode_fsm mode_FSM (.clk(clk), .n_rst(n_rst), .modekey_edge(mode_key), .mode(wave_select));


// logic [7:0] sample;
// waveshaper waveshaper (.mode(wave_select), .quotient(quotient), .sample(sample));


// pwm pwm (.clk(clk), .n_rst(n_rst), .sample(sample), .pwm_o(pwm_o));


// clock_8Hz clk8 (.clk(clk), .n_rst(n_rst), .en(en), .is_FPGA(1'b1), .flag(clkdiv));

// endmodule 
