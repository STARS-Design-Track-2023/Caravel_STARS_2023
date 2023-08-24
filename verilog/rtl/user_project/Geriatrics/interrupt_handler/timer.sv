module timer(
    input logic clk, nrst,
    input logic enable,
    input logic [31:0] timer_max,
    output logic int_fire
);
    logic [31:0] count, next_count;

    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) count <= 32'b0;
        else       count <= next_count;
    end

    always_comb begin
        int_fire = count == timer_max - 1;
        if (enable)
            if (int_fire) next_count = 0;
            else          next_count = count + 1;
        else
            next_count = 0;
    end

endmodule
