module clkdiv (input logic clk, nrst,
               output logic secpulse);

logic [23:0] count;
always_ff @ (posedge clk, negedge nrst) begin
    if (!nrst) begin 
        count <= 0;
        secpulse <= 0;
    end 
    else begin 
        
        if (count == 10000000) begin
            count <= 0;
            secpulse <= 1;
          
        end

        else begin
            count <= count + 1;
            secpulse <=0;
        end 

    end
end


endmodule