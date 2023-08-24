module oscillator
        (input logic [17:0] divider, 
        input logic clk, nrst, 
        output logic [17:0] count);
    
    logic [17:0] next_count;

    always_comb begin
        if (count == divider)
            next_count = {17'b0, 1'b1};
        else    
            next_count = count + 1;
    end

    always_ff @ (posedge clk, negedge nrst) begin
        if (~nrst)
            count <= {17'b0, 1'b1};
        else
            count <= next_count;
    end
endmodule