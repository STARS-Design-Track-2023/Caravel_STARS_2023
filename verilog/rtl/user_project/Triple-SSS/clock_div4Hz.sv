module clock_div4Hz
    #(parameter DIV = 2500000) (
        input logic clk, nrst, 
        output logic pulse
    );

    logic [$clog2(DIV):0] next_count, count;

    always_comb begin
        if (count == DIV)
            next_count = 1;
        else
            next_count = count + 1;
    end

    always_ff @ (posedge clk, negedge nrst) begin
        if (~nrst)
            count <= 1;
        else 
            count <= next_count;
    end

    always_comb begin
        pulse = count == DIV;
    end
endmodule