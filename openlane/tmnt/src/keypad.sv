`default_nettype none


module keypad(
    //inputs
    input logic clk,                   //clock
    input logic n_rst,                 // active low reset  
    input logic mode_in,               //input signal pb[15]
    input logic [1:0] octave_in,       //input signal pb[14], pb[13]
    output logic modekey,              //output signal modekey
    output logic octave_up,            //output logic octave_up
    output logic octave_down           //output logic octave_down
    );

//internal signals
logic [1:0] delay_in;
logic [1:0] delay_octave_up_in;
logic [1:0] delay_octave_down_in;

always_ff @( posedge clk, negedge n_rst ) begin : mode_edge_detection
    if (n_rst) 
        delay_in <= {delay_in[0], mode_in};
    else 
        delay_in <= 2'b00;
end

always_ff @( posedge clk, negedge n_rst ) begin : octave_up_edge_detection
    if (n_rst) 
        delay_octave_up_in <= {delay_octave_up_in[0], octave_in[1]};
    else 
        delay_octave_up_in <= 2'b00;
end

always_ff @( posedge clk, negedge n_rst ) begin : octave_down_edge_detection
    if (n_rst) 
        delay_octave_down_in <= {delay_octave_down_in[0], octave_in[0]};
    else 
        delay_octave_down_in <= 2'b00;
end

//posedge detection
assign modekey = delay_in[0] & ~delay_in[1];
assign octave_up = delay_octave_up_in[0] & ~delay_octave_up_in[1];
assign octave_down = delay_octave_down_in[0] & ~delay_octave_down_in[1];

endmodule