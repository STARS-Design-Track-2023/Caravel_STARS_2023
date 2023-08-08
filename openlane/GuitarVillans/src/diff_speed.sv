module diff_speed(
    input logic clk,
    input logic n_rst,
    input logic [2:0]mode,
    input logic pushed_1,

    output logic [22:0]diff_speed,
    output logic [1:0]level 
);

    localparam EASY = 2'd1;
    localparam MEDIUM = 2'd2;
    localparam HARD = 2'd3;

    localparam DIFF = 3'd3;
    
    logic [1:0]nxt_lvl;
    logic pb_1out;
    sync_posedgeqiao u4(.clk(clk), .n_rst(n_rst), .button(pushed_1), .posout(pb_1out));

    always_ff @(posedge clk, negedge n_rst)
    begin
        if(n_rst == 1'b0) begin
            level <= EASY;
        end
        else begin
            level <= nxt_lvl;
        end
    end

    always_comb begin
        if (mode == DIFF) begin
            if (pb_1out == 1'b1) begin
                case(level)
                    EASY: begin
                        nxt_lvl = MEDIUM;
                    end
                    MEDIUM: begin
                        nxt_lvl = HARD;
                    end
                    HARD: begin
                        nxt_lvl = EASY;
                    end
                    default: begin
                        nxt_lvl = EASY;
                    end
                endcase
            end
            else begin
                nxt_lvl = level;
            end
        end
        else begin
            nxt_lvl = level;
        end
    end

    always_comb begin
        if (level == EASY)
            diff_speed = 23'd5000000;
        else if (level == MEDIUM)
            diff_speed = 23'd4000000;
        else if (level == HARD)
            diff_speed = 23'd3000000;
        else 
            diff_speed = 23'd5000000;
    end
endmodule