module output_sel (
    input logic [11:0] timer, stopwatch, mem, 
    input logic [1:0] output_select,
    output logic [11:0] time_to_decode
);


    always_comb begin

    case(output_select)
    1:time_to_decode = stopwatch;
    2:time_to_decode = mem; 
    3: time_to_decode = timer;
    default:time_to_decode = 0;
    endcase
    end 
endmodule