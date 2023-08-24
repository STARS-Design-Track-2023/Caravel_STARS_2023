module clock_div39kHz
    (input logic clk, nrst, 
    output logic pulse);
    
    logic [7:0] count, next_count;

    always_comb begin
        next_count = count;
        if (count < 255)
            next_count = count + 1;
        if (count == 255)
            next_count = 0;
    end

    always_ff @ (posedge clk, negedge nrst) begin
        if (~nrst)
            count <= 0;
        else 
            count <= next_count;
    end

    always_comb
        pulse = count == 255;
endmodule