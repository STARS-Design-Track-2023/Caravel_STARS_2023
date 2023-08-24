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
//sync_low u1(.clk(hz100), .n_rst(pb[0]), .async_in(pb[1]), .sync_out(right[0]));
//EdgeDetector u2(.clk(hz100), .n_rst(pb[0]), .async_in(pb[1]), .sync_out(right[0]));
decoder u3(.output_select([2:0]), .counter_out([11:0]), .memory_out([11:0]), .timer_out([11:0]));
endmodule

`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
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

  // Your code goes here...
  decoder dut1 (.counter_out(12'b011000011000), .out0(ss0[6:0]), .out1(ss1[6:0]), .out2(ss2[6:0]), .out3(ss3[6:0]));

endmodule

// Add more modules down here...

module mux (input logic [11:0] counter_out, timer_out,
input logic output_select, 
output logic [11:0] mux_out
);
always_comb begin
  case(output_select)
    1'b0: mux_out=counter_out;
    1'b1: mux_out=timer_out;
  endcase
 end
endmodule

module decoder (input logic [11:0] counter_out, timer_out, 
output logic [6:0] out0, out1, out2, out3
);
  
  logic [5:0] minute, second;
  logic [3:0] m1, m0, s1, s0;
  
  
  always_comb begin
    {minute , second} = counter_out;
    s1 = 0;
    s0 = 0;
    m1 = 0;
    m0 = 0;
    
    if(second > 9) begin
        {2'b0,s1} = second / 10;
        {2'b0,s0} = second % 10;
    end
    else
        s0 = second[3:0]; 
    
    if(minute > 9) begin
        {2'b0,m1} = minute / 10;
        {2'b0,m0} = minute % 10;
    end
    else 
        m0 = minute[3:0];
    

  end 
    encode x1 (.in(m0), .out(out0));
    encode x2 (.in(m1), .out(out1));
    encode x3 (.in(s0), .out(out2));
    encode x4 (.in(s1), .out(out3));
  
endmodule
// Add more modules down here...
module encode (input logic [3:0] in, output logic [6:0] out);
  always_comb begin
    case(in)
     0: out = 7'b0111111;
     1: out = 7'b0000110;
     2: out = 7'b1011011;
     3: out = 7'b1001111;
     4: out = 7'b1100110;
     5: out = 7'b1101101;
     6: out = 7'b1111101;
     7: out = 7'b0000111;
     8: out = 7'b1111111;
     9: out = 7'b1101111;
     default: out = 0;
    endcase
  end
  


endmodule









// module sync_low ( input logic clk, n_rst, async_in, 
// output logic sync_out);

// always_ff @( posedge clk, negedge n_rst) begin
//   if ( ! n_rst)begin
//     sync_out <= 1'b0 ;
//   end 
//   else begin
//     sync_out <= async_in ;
//   end 
// end
// endmodule




// module EdgeDetector( input wire clk, n_rst, async_in,
//   output wire sync_out);
  
//   always @(posedge clk or posedge n_rst) begin
//     if (n_rst)
//       async_in <= 1'b0;
//     else
//       async_in <= sync_out;
//   end
  
//   assign edge_detected = sync_out & (~asyn_in);
  
// endmodule