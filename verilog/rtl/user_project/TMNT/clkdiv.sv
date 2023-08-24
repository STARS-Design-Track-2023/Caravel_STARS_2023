
module clkdiv#(
    parameter BITLEN = 8
    ) (
    input logic clk,                    // clock
    input logic n_rst,                  // active high reset 
    input logic [BITLEN-1:0] lim,       // limit for counter
    output logic hzX,                   // output clock
    output logic [BITLEN-1:0] cnt_out   // counter
    );

    logic [BITLEN-1:0] cnt;
    logic [BITLEN-1:0] next_cnt;
    logic next_hzX;

    //flip flop
    always_ff @(posedge clk, negedge n_rst) begin
        if (!n_rst) begin
            cnt <= 0;
            hzX <= 0;
        end
        else begin
            cnt <= next_cnt;
            hzX <= next_hzX;
        end
    end

    //combinational logic
    always_comb begin
        if (cnt == lim) begin
            next_cnt = 0;
            next_hzX = 1;
        end
        else begin
            next_cnt = cnt + 1;
            next_hzX = 0;
        end
    end
    
    assign cnt_out = cnt;

            

endmodule