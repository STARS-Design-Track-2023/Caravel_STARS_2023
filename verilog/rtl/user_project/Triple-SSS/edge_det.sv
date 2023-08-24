module edge_det
        (input logic clk, nrst, in, 
        output logic det_edge);

    logic ff_out, ff_in;

    always_ff @ (posedge clk, negedge nrst) begin
        if (~nrst)
            ff_out <= 0;
        else 
            ff_out <= in;
    end

    always_comb begin
        if ((in == 1) & (ff_out == 0))
            ff_in = 1;
        else
            ff_in = 0;
    end

    always_ff @ (posedge clk, negedge nrst) begin
        if (~nrst)
            det_edge <= 0;
        else
            det_edge <= ff_in;
    end
endmodule