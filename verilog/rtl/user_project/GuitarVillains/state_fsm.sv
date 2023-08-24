module state_fsm(
    input logic clk,
    input logic n_rst,
    input logic pushed_3,
    input logic pushed_4,
    input logic fin_check,
    
    output logic [2:0]mode
);
    localparam IDLE = 3'd1;
    localparam EDIT = 3'd2;
    localparam DIFF = 3'd3;
    localparam RUN = 3'd4;
    localparam PAUSE = 3'd5;
    localparam FINISH = 3'd6;

    logic [2:0]nxt_mode;
    logic pb_3out;
    logic pb_4out;
    sync_posedgeqiao u2(.clk(clk), .n_rst(n_rst), .button(pushed_3), .posout(pb_3out));
    sync_posedgeqiao u3(.clk(clk), .n_rst(n_rst), .button(pushed_4), .posout(pb_4out));


    always_ff @( posedge clk, negedge n_rst)
    begin
        if (~n_rst) begin
            mode <= IDLE;

        end
        else begin
            mode <= nxt_mode;

        end
    end

    always_comb 
    begin
        //FSM for State Transition
        if(pb_3out == 1'b1) begin
            case(mode)
                IDLE:
                    nxt_mode = EDIT;
                EDIT:
                    nxt_mode = DIFF;
                DIFF:
                    nxt_mode = RUN;
                RUN:
                    nxt_mode = PAUSE;
                PAUSE:
                    nxt_mode = RUN;
                FINISH:
                    nxt_mode = IDLE;
                default:
                    nxt_mode = IDLE;
            endcase
        end
        else if (pb_4out == 1'b1) begin
            //FSM For moving everything to finish (Quit Button)
            if (mode != EDIT)
                nxt_mode = FINISH;
            else
                nxt_mode = mode;
        end
        else begin
            //Autofinish via the counter
            if(fin_check == 1'b1)
                nxt_mode = FINISH;
            else
                nxt_mode = mode;
        end
    end


endmodule