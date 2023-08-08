`default_nettype none

`include "/home/designer-25/CUP/openlane/z23/src/interrupt_handler/ih_pkg.sv"

module interrupt_handler(
    input logic clk, nrst,
    input logic [7:0] gpio_interrupt_pins, gpio_interrupt_mask,
    input logic timer_enable,
    input logic [31:0] timer_duration,
    input logic interrupt_pin,
    input logic input_handler_enable,
    input logic [15:0] input_handler_source,
    input logic interrupts_enabled,
    input logic interrupt_ack,
    output logic [15:0] input_handler_output,
    output logic interrupt_requested,
    output ih_pkg::interrupt_source interrupt_source
);
    ih_pkg::interrupt_source next_interrupt_source;
    logic interrupt_scheduled;
    logic ip_re, t_if, ih_if;
    logic gpio_interrupt_fire, input_handler_fire;

    assign gpio_interrupt_fire = |(gpio_interrupt_pins & gpio_interrupt_mask);
    assign input_handler_fire = ih_if & input_handler_enable;

    timer t(
        .clk(clk),
        .nrst(nrst),
        .enable(timer_enable),
        .timer_max(timer_duration),
        .int_fire(t_if)
    );

    input_handler ih(
        .clk(clk),
        .nrst(nrst),
        .in(input_handler_source),
        .in_sync(input_handler_output),
        .int_fire(ih_if)
    );

    edge_detector ip_ed(
        .clk(clk),
        .nrst(nrst),
        .data_in(interrupt_pin),
        .rising_edge(ip_re),
        .held()
    );

    // Only request interrupts if interrupts are enabled and either one is
    // scheduled or the currently scheduled one has not been serviced
    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin
            interrupt_requested <= 1'b0;
            interrupt_source <= ih_pkg::timer_is;
        end else begin
            interrupt_requested <= interrupts_enabled & ((interrupt_requested & ~interrupt_ack) | interrupt_scheduled);
            if (interrupt_scheduled) interrupt_source <= next_interrupt_source;
        end
    end

    always_comb begin
        interrupt_scheduled = t_if | input_handler_fire | interrupt_pin | gpio_interrupt_fire;
        if (t_if)                     next_interrupt_source = ih_pkg::timer_is;
        else if (input_handler_fire)  next_interrupt_source = ih_pkg::input_is;
        else if (gpio_interrupt_fire) next_interrupt_source = ih_pkg::gpio_is;
        else if (ip_re)               next_interrupt_source = ih_pkg::external_is;
        else                          next_interrupt_source = ih_pkg::timer_is;
    end
endmodule
