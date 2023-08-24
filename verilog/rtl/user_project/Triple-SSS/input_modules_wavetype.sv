module wavetype(input logic clk, n_rst, mode_key, output logic [1:0] mode); 

typedef enum logic [1:0] {s1, s2, s3, s4} state_t; 

state_t state;
state_t next_state; 

always_ff @ (posedge clk, negedge n_rst) begin 
    if (~n_rst) 
        state <= s1; 
    else
        state <= next_state; 
end 

always_comb
begin
  case (state)
    s1: mode = 2'd0;
    s2: mode = 2'd1;
    s3: mode = 2'd2;
    s4: mode = 2'd3;
    default: mode = 2'd0;
  endcase
end

always_comb begin 
    next_state = state;
    case(state)
    s1: begin 
        if (mode_key == 1) 
            next_state = s2; 
        else  
            next_state = s1; 
    end 
    s2: begin 
        if (mode_key == 1) 
            next_state = s3; 
        else  
            next_state = s2; 
    end  
    s3: begin 
        if (mode_key == 1) 
            next_state = s4; 
        else  
            next_state = s3; 
    end  
    s4: begin 
        if (mode_key == 1) 
            next_state = s1; 
        else  
            next_state = s4; 
    end  
    default: next_state = s1;
endcase 
end 

endmodule