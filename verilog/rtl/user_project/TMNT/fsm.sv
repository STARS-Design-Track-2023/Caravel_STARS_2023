module fsm(
    //inputs
    input logic clk,   
                n_rst,
                modekey,//2-bit "off" "square" "triangle" "sawtooth" 
        
    //outputs
    output logic [1:0] mode           //1 sample 8bit output
    );
    //internal signals
    logic [1:0]next_mode;

    //flip flop
    always_ff @( posedge clk, negedge n_rst ) begin : fsm_ff
        if (~n_rst) 
        mode <= 0;
    else 
        mode <= next_mode;
    end

    //next state logic
    always_comb begin : next_state_logic
      case (mode)
        2'b00: next_mode = modekey ? 2'b01 : 2'b00;
        2'b01: next_mode = modekey ? 2'b10 : 2'b01;
        2'b10: next_mode = modekey ? 2'b11 : 2'b10;
        2'b11: next_mode = modekey ? 2'b00 : 2'b11;
        default: next_mode = 2'b00;
      endcase   
    end
endmodule