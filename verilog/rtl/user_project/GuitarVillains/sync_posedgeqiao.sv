module sync_posedgeqiao(
    input logic clk,
    input logic n_rst,
    input logic button,

    output logic posout
);
    logic Q1;
    logic Q2;
    logic sync_pb;

    always_ff @(posedge clk, negedge n_rst)
    begin
        if (n_rst == 1'b0)
        begin
            sync_pb <= 0;
            Q1 <= 0;
            Q2 <= 0;
        end
        else
        begin
            sync_pb <= button;
            Q1 <= sync_pb;
            Q2 <= Q1;
        end
    end

    assign posout = Q1 & ~Q2;


endmodule