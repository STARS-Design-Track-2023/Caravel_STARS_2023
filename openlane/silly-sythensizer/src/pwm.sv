module pwm(
    input logic clk, nrst, strobe, 
    input logic [7:0] sample, 
    output logic pwm_ff);
    
    logic [7:0] count, next_count;
    logic pwm_unff;

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

    always_comb begin
        if (strobe == 0)
            pwm_unff = 0;
        else begin
            if (count < sample)
                pwm_unff = 1;
            else 
                pwm_unff = 0;
        end
    end

    always_ff @ (posedge clk, negedge nrst) begin
        if (~nrst)
            pwm_ff <= 0;
        else
            pwm_ff <= pwm_unff;
    end
endmodule