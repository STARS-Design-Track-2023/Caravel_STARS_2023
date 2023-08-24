//Octave FSM module

module oct_fsm(input logic octave_in, input logic clk, input logic nrst,
output [2:0] state);
logic [2:0]next_state;


always_comb begin
    case(state)
    3'd0: next_state = (octave_in == 1) ? 1:0; //0 - O1
    3'd1: next_state = (octave_in == 1) ? 2:1; //1 - O2
    3'd2: next_state = (octave_in == 1) ? 3:2; //2 - O3
    3'd3: next_state = (octave_in == 1) ? 4:3; //3 - O4
    3'd4: next_state = (octave_in == 1) ? 5:4; //4 - O5
    3'd5: next_state = (octave_in == 1) ? 6:5; //5 - O6
    3'd6: next_state = (octave_in == 1) ? 0:6; //6 - O7
    default: next_state = 3'd3;
    endcase
end

always_ff @ (posedge clk, negedge nrst) begin
    
    if(!nrst) begin
       state <= 3'd3;
    end
    else begin
       state <= next_state;
    end
end
endmodule