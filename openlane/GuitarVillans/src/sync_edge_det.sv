
module sync_edge_det( input logic clk, Rst, button_i, output logic sig_f);

logic sync_b, edge_1, edge_2;

always_ff @(posedge clk, negedge Rst) begin

if(Rst == 1'b0) begin

    sync_b <= 1'b0;
    edge_1 <= 1'b0;
    edge_2 <= 1'b0;

end

else begin

    sync_b <= button_i;
    edge_1 <= sync_b;
    edge_2 <= edge_1;

end


end

assign sig_f = edge_1 & (~edge_2);


endmodule