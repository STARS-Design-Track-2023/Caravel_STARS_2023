`default_nettype none

module top 
(
  // I/O ports
  input  logic hwclk, reset,
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
       logic pb1, pb0, clkdiv, clear, read, write, enable, enable_decrement, enable_increment,time_up;
       logic [1:0] output_select;
       logic [11:0] time_out, time_to_decode, timer_out, memout;
       logic [5:0] out0, out2, out1, out3;
       edge_detect e1 (.clk(hwclk), .nrst(~reset), .async_in(pb[0]), .pos_edge(pb0));
       edge_detect e2 (.clk(hwclk), .nrst(~reset), .async_in(pb[1]), .pos_edge(pb1));
       fsm FSM (.clk(hwclk), .nrst(~reset), .pb1(pb1), .pb0(pb0), .clear(clear), .read(read), .write(write), .enable_increment(enable_increment), 
       .enable_decrement(enable_decrement), 
       .output_select(output_select), .flag(time_up), .enable(enable));
       clkdiv CLKDIV (.clk(hwclk), .nrst(~reset), .secpulse(clkdiv));
       counter CTR (.clk(hwclk), .nrst(~reset), .enable(enable), .clock_div(clkdiv), .time_out(time_out), .clear(clear));
       output_sel sel (.timer(timer_out), .stopwatch(time_out), .mem(memout), .output_select(output_select), .time_to_decode(time_to_decode));
       decoder D1 (.counter_out(time_to_decode), .out0(out0), .out1(out1), .out2(out2), .out3(out3));
       timer TIM (.clk(hwclk), .nrst(~reset), .enable_dec(enable_decrement), .enable_in(enable_increment), 
       .clk_div(clkdiv), .lap(pb0), .clear(clear), .time_up(time_up), .timer_out(timer_out));
       memory MEM (.clk(hwclk), .nrst(~reset), .count(time_out), .read(read), .write(write), .out(memout), .clear(clear));
       assign red = time_up;
       assign {left[3:0], right} = timer_out;
       encode ec0 (.binary(out0), .sv_seg(ss0[6:0]));
       encode ec1 (.binary(out1), .sv_seg(ss1[6:0]));
       encode ec2 (.binary(out2), .sv_seg(ss2[6:0]));
       encode ec3 (.binary(out3), .sv_seg(ss3[6:0]));
       
endmodule


// module output_sel (
//     input logic [11:0] timer, stopwatch, mem, 
//     input logic [1:0] output_select,
//     output logic [11:0] time_to_decode
// );

// module timer (input logic clk, input logic nrst, input logic enable_dec, 
// input logic enable_in, input logic clk_div, input logic lap, input logic clear, output logic time_up, output logic [11:0] timer_out);


// module memory (
//   input logic clk, nrst,
//   input logic [11:0] count, input logic read, input logic write, output logic [11:0] out);