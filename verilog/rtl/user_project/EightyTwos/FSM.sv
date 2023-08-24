
module FSM (
    input logic clk, input logic n_rst,
    input logic instr_read_en,
    input logic [1:0] num_bytes,
    output logic [1:0] state,
    output logic shift_en, instr_ready);

    logic [1:0] next_state;

    always_ff @ ( posedge clk, negedge n_rst ) 
     if (!n_rst) begin 
        state <= 2'b0;
    end
    else begin
        state <= next_state;
    end 

    always_comb begin
        next_state = state;
        case(state) 
        2'b00 : next_state = (num_bytes == 2'b01)? 2'b11:2'b01;
        2'b01 : next_state = (num_bytes == 2'b10)? 2'b11:2'b10;
        2'b10 : next_state = 2'b11;
        2'b11 : next_state = (instr_read_en == 1'b1)? 2'b00: 2'b11;
        endcase
     end

     always_comb begin
        if (state == 2'b11) begin
            shift_en = 0;
            instr_ready = 1;
        end
        else begin
            shift_en = 1;
            instr_ready = 0;
        end
     end
     
endmodule








