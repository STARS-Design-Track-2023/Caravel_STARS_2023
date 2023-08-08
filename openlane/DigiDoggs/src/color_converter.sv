`default_nettype none

module color_converter(
    input logic [7:0] iteration, 
    input logic ismandelbrot, 
    output logic [23:0] RGB
);

logic [7:0] R, G, B;

always_comb begin 
    if (ismandelbrot) begin
        R = 8'b0;
        G = 8'b0;
        B = 8'b0;
    end
    else begin
        R = iteration;
        G = iteration;
        B = iteration; 
    end
end

assign RGB = {R, G, B};

endmodule
