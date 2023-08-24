module sync_posedge(
    input logic clk, n_rst, button,
    input logic [2:0] mode,
    output logic posout
);
    logic sync_out, edge_1, edge_2; //accept, next_accept;
    logic [22:0] counter, next_count;
    always_ff @ (posedge clk, negedge n_rst) begin
        if (~n_rst) begin
            sync_out <= 0;
            edge_1 <= 0;
            edge_2 <= 0;
            //accept <= 1;
            counter <= 0;
        end
        else begin
            sync_out <= button;
            edge_1 <= sync_out;
            edge_2 <= edge_1;
            //accept <= next_accept;
            counter <= next_count;
        end
    end

    always_comb begin
        //next_accept = accept;
        next_count = 0;
        posout = 0;
    
        if (mode == 3'd4) begin
            posout = edge_1 & ~edge_2;
            /*
            if (accept)
                posout = edge_1 & ~edge_2;
            else
                posout = 0;

            if (posout)
                next_accept = ~accept;

            
            if (~accept) begin
                if (counter == 800000) begin
                    next_accept = 1'b1;
                    next_count = 0;
                end
                else
                    next_count = counter + 1;
            end*/
        end

    end
endmodule