`default_nettype none

module completion_logic(
    input logic mem_read_en, mem_write_en, cmp_o,
    input logic [15:0] next_data,
    output logic ack,
    output logic [15:0] data_output
);
    always_comb begin
        data_output = 16'b0;
        ack = 1'b0;
        //completion logic
        if (mem_read_en & cmp_o) begin
            data_output = next_data;
            ack = 1'b1;
        end else if (mem_write_en & cmp_o) ack = 1'b1;
    end
endmodule
