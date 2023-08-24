module NEW_high_score_check (
    input logic clk, n_rst, score_tog, flash, is_neg,
    input logic [7:0] score, hits, misses,
    input logic [2:0] mode,
    output logic [13:0] SS_disp,
    output logic red, green
);

logic [7:0] next_high, highest_score;
logic [6:0] SEG7 [9:0];
localparam FINISH = 3'd6;

always_comb begin
    if (mode == FINISH) begin // 3'b101 = FINISH state
        if (score > highest_score && ~is_neg)
            next_high = score;
        else
            next_high = highest_score;
    end
    else   
        next_high = highest_score;
end

always_ff @ (posedge clk, negedge n_rst) begin
    if (!n_rst)
        highest_score <= 0;
    else
        highest_score <= next_high;
end

// code for the display begins below

sync_posedgeqiao u1(.clk(clk), .n_rst(n_rst), .button(score_tog), .posout(sync_edg_det));

logic [1:0] nxt_mode, score_mode;
logic sync_edg_det;

localparam curr_score = 2'd0;
localparam hi_score = 2'd1;
localparam hit = 2'd2;
localparam miss = 2'd3;

always_comb begin
    SEG7[4'b0000] = 7'b0111111;
    SEG7[4'b0001] = 7'b0000110;
    SEG7[4'b0010] = 7'b1011011;
    SEG7[4'b0011] = 7'b1001111;
    SEG7[4'b0100] = 7'b1100110;
    SEG7[4'b0101] = 7'b1101101;
    SEG7[4'b0110] = 7'b1111101;
    SEG7[4'b0111] = 7'b0000111;
    SEG7[4'b1000] = 7'b1111111;
    SEG7[4'b1001] = 7'b1100111;
end

always_ff @ (posedge clk, negedge n_rst) begin
    if (!n_rst)
        score_mode <= curr_score;
    else 
        score_mode <= nxt_mode;
end

always_comb begin 
    case (score_mode)
        curr_score : begin
            SS_disp = (flash) ? {SEG7[score[7:4]], SEG7[score[3:0]]} : 0;
            red = 0;
            green = 0;
        end
        hi_score : begin
            SS_disp = {SEG7[highest_score[7:4]], SEG7[highest_score[3:0]]};
            red = 1;
            green = 1;
        end
        hit : begin
            SS_disp = {SEG7[hits[7:4]], SEG7[hits[3:0]]};
            red = 0;
            green = 1;
        end
        miss: begin
            SS_disp = {SEG7[misses[7:4]], SEG7[misses[3:0]]};
            red = 1;
            green = 0;
        end
        default: begin 
            SS_disp = {SEG7[score[7:4]], SEG7[score[3:0]]};
            red = 0;
            green = 0;
        end
    endcase
end

always_comb begin
    case (score_mode)
        curr_score : begin
            if (sync_edg_det == 1)
                nxt_mode = hi_score;
            else
                nxt_mode = curr_score;
        end
        hi_score : begin
            if (sync_edg_det == 1)
                nxt_mode = hit;
            else
                nxt_mode = hi_score;
        end
        hit : begin
            if (sync_edg_det == 1)
                nxt_mode = miss;
            else
                nxt_mode = hit;
        end
        miss : begin
            if (sync_edg_det == 1)
                nxt_mode = curr_score;
            else
                nxt_mode = miss;
        end
    endcase
end

endmodule