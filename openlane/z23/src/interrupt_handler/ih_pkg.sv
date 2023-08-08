`ifndef INTERRUPT_HANDLER_PKG
`define INTERRUPT_HANDLER_PKG

`default_nettype none

package ih_pkg;
    typedef enum logic [1:0] {
        timer_is, input_is, gpio_is, external_is 
    } interrupt_source;
endpackage

`endif
