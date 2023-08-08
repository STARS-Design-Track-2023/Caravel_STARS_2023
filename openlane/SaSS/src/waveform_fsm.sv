/************************************************************************************************************/
// Inputs:
//    mode_key -> 1 or 0 "pulse" value describing if the key to cycle between modes has been pressed
//    clk -> 10kHz clock
//    n_rst -> Async negative reset, resets when n_rst is 0
//
// Outputs:
//    mode -> A 2-bit value 0-3 which corresponds to one of the 4 possible states which the waveform_fsm can be in
//   
/*************************************************************************************************************/

module waveform_fsm (input logic mode_key, clk, n_rst, output logic [1:0]mode);

logic [1:0]next_state; // Declaring intermediate variable for flip-flop

// Giving names to states, OFF is 0, SQUARE is 1, SAW is 2, and TRI is 3
parameter [1:0] OFF = 0;
parameter [1:0] SQUARE = 1;
parameter [1:0] SAW = 2;
parameter [1:0] TRI = 3;


    always_ff @ (posedge clk, negedge n_rst) begin
        if(n_rst)
            mode <= next_state;
        else
            mode <= 2'd0; // Mode set to OFF on reset
    end

    always_comb begin // When mode_key is pressed if cycles modes in the order: OFF -> SQUARE -> SAW -> TRI -> OFF -> ...

        case(mode)
        OFF: next_state = mode_key ? SQUARE : OFF; 
        SQUARE: next_state = mode_key ? SAW : SQUARE;
        SAW: next_state = mode_key ? TRI : SAW;
        TRI: next_state = mode_key ? OFF : TRI;
        endcase

    end


endmodule