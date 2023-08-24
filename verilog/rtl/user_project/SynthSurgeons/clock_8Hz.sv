
module clock_8Hz(input logic clk, n_rst, en, is_FPGA, output logic flag);

logic [20:0] next_count; // 1.5M needs 21 bits for counting.
logic [20:0] count;
logic [20:0] max;

assign max = is_FPGA ? 21'd1500000 : 21'd1250000;

always_ff @ (posedge clk, negedge n_rst) begin 
if (n_rst == 0) begin
        count <= 21'b0; end
    else begin
        count <= next_count; end
end

always_comb begin
    flag = 0;

    if (en == 1) begin
        if (count == max)begin
        next_count = 21'b0;
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