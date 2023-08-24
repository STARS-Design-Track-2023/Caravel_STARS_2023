module MemControl (
input logic halt, load_en ,store_en , clk, n_rst,
output logic instr_read_en);

logic[1:0]state, next_state;

always_ff @ ( posedge clk, negedge n_rst ) 

    if (!n_rst) begin 
        state <= 0;
    end
    else begin
        state <= next_state;
    end 

always_comb begin 
    next_state = state;
    instr_read_en = 1;
    if  (halt) begin
        instr_read_en = 0;
        end
    else begin
        next_state = state;
        instr_read_en = 1;
        
        case(state) 
            2'b00 :  begin
                if (load_en||store_en) begin 
                    next_state = 2'b01; 
                    instr_read_en = 0; 
                end
                else begin
                    instr_read_en = 1; 
                end
                end
            2'b01 :begin next_state = 2'b10; instr_read_en = 0; end
            2'b10 : begin next_state = 2'b00; instr_read_en = 0; end
            default : begin next_state = state ; instr_read_en = 1; end
        endcase
    end
end

endmodule
