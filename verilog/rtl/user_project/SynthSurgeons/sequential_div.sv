
module sequential_div(input logic clk, n_rst, flag, input logic [15:0] count, input logic [15:0] divider, output logic [7:0] q_out );

logic [2:0] next_count;
logic [2:0] count_div;
logic div, done, load;
logic [23: 0] R, next_r;
logic [7:0] Q, next_q, next_q_out;
logic [15:0] D, next_d, D_count, dividend;
logic [6:0] Q_lower;

//Iterations of divider

always_ff @ (posedge clk, negedge n_rst) begin 
    if (n_rst == 0) begin
        count_div <= 3'b0; end
    else begin
        count_div <= next_count; end
end

always_comb begin : FSM_ITER
    if(state == Divide) begin
    next_count = count_div + 1;
    end
    else begin
    next_count = count_div;
    end
end

//State Machine

typedef enum logic [1:0] {Start, Load, Divide, Done} FSM;
logic [1:0] state, next_state;

always_comb begin : NEXT_STATE_LOGIC
    next_state = state;
    case(state)
        Start: if(flag) next_state = Load; 
        Load: next_state = Divide;
        Divide: if(count_div == 7) next_state = Done;
        Done: if(flag) next_state = Load;
    endcase
    div = (state == Divide);
    done = (state == Done);
    load = (state == Load);
end

always_ff @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
       state <= Start; 
    end
    else begin
        state <= next_state;
    end
end

//Count input and output blocks

always_comb begin
    if(flag) begin
        D_count = count;
    end
    else begin
        D_count = dividend;    
    end
end 

always_comb begin
    if(done) begin
        next_q_out = Q;
    end
    else begin
        next_q_out = q_out;    
    end
end 

always_ff @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
       dividend <= 16'b0; 
       q_out <= 0;
    end
    else begin
        dividend <= D_count;
        q_out <= next_q_out;
    end
end

//Divider block
assign Q_lower = Q[6:0];

always_comb begin
    next_r = R;
    next_q = Q;
    next_d = D;    
    if(load) begin
        next_r = {dividend, 8'b0};
        next_q = 0;
        next_d = divider;    
    end
    if(div) begin
        if(R[23:7] >= {1'b0, D}) begin
            next_r = {R << 1} - {D, 8'b0};
            next_q = {Q_lower, 1'b1};
        end
        else begin
            next_r = {R << 1};
            next_q = {Q_lower, 1'b0};
        end
    end
end

always_ff @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
        R <= 0;
        Q <= 0;
        D <= 0;
    end
    else begin
        R <= next_r;
        Q <= next_q;
        D <= next_d;    
    end
end

endmodule


