module synch
        (input logic clk, nrst, 
        input logic [16:0] async_keys, 
        output logic [16:0] sync_keys);
    
    logic [16:0] half_sync;

    always_ff @ (posedge clk, negedge nrst) begin
        if (~nrst)
            half_sync <= 17'b0;
        else
            half_sync <= async_keys;
    end

    always_ff @ (posedge clk, negedge nrst) begin
        if (~nrst)
            sync_keys <= 17'b0;
        else
            sync_keys <= half_sync;
    end
endmodule