module oscillator (input logic clk,n_rst, en, input logic [15:0] divider, output logic [15:0] count);

logic [15:0] next_count;

always_ff @ (posedge clk, negedge n_rst) begin 
if (n_rst==0) begin
        count<=16'b1; end
    else begin
        count<=next_count; end
end

always_comb begin : freq_gen
    if (en==1) begin
        if (count>=divider) begin
        next_count= 16'd1; end
        else begin
        next_count= count+1; end
    end
    else begin
        next_count=16'd1; end
end
endmodule