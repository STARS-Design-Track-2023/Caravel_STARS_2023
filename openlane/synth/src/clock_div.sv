
module clock_div(input logic clk, n_rst, en, output logic flag);

logic [7:0] next_count;
logic [7:0] count;
logic [7:0] max;

assign max = 8'b11111111;

always_ff @ (posedge clk, negedge n_rst) begin 
if (n_rst == 0) begin
        count <= 8'b0; end
    else begin
        count <= next_count; end
end

always_comb begin

    flag = 0;

    if (en == 1) begin
        if (count == max)begin
        next_count = 8'b0;
        flag = 1;
        end

        else begin
        next_count = count + 1; 
        end
    end
    else begin
        next_count = 0; end

end
endmodule