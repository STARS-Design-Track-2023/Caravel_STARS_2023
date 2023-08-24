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

  // Internal signals
  logic [7:0] ram_dout;
  logic [7:0] ram_din;
  logic [15:0] mem_addr;
  logic mem_write_en;

  // Instantiate ram module
  ram ram (
    .din(ram_din),
    .addr(mem_addr[11:0]),
    .write_en(mem_write_en),
    .clk(hwclk),
    .dout(ram_dout)
  );

  // Instantiate z23 module
  z23 z23FPGA (
    .clk(hwclk),
    .nrst(~reset),
    .memory_data_in(ram_dout),
    .programmable_gpio_in(9'b0),
    .keypad_input(pb[15:0]),
    .memory_address_out(mem_addr),
    .memory_data_out(ram_din),
    .programmable_gpio_out(),
    .memory_wr(mem_write_en),
    .programmable_gpio_wr(),
    .ss7(ss7),
    .ss6(ss6),
    .ss5(ss5),
    .ss4(ss4),
    .ss3(ss3),
    .ss2(ss2),
    .ss1(ss1),
    .ss0(ss0)
  );
  
endmodule

module ram #(parameter addr_width = 12, parameter data_width = 8) (
  input logic [addr_width-1:0] addr,
  input logic [data_width-1:0] din,
  input logic write_en, clk,
  output logic [data_width-1:0] dout
); // 4096x8
  logic [data_width-1:0] mem [(1<<addr_width) - 1:0];

  // Register for updating memory
  always_ff @(posedge clk) begin
    if (write_en)
      mem[(addr)] <= din;
    dout <= mem[addr]; // Output register controlled by clock.
  end
endmodule
