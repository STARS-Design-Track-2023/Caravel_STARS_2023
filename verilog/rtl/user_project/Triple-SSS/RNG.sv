module rng( 
    input logic clk, nrst, pulse, en,
    output logic [5:0] note
);
    logic [15:0] out;
    logic feedback;
    assign feedback= ~(out[10]^(out[12]^(out[13]^out[15])));
    logic feedback_2; 
    assign feedback_2 = ~(note[3]^(note[4]^note[5]));

    always_ff @ (posedge clk, negedge nrst) begin  
        if (~nrst)
            out <= 16'b1010010001010101;
        else
            out <= {out[14:0],feedback}; 
    end

    logic [5:0] next_note;

    always_comb begin
        next_note = note;
        if (pulse & en) begin
            next_note = {note[4:0],feedback_2};
            if (out[15] == 1)
                next_note = ~{note[4:0],feedback_2};
        end
    end

    always_ff @ (posedge clk, negedge nrst) begin 
        if (~nrst)
            note <= 6'b101101;
        else 
            note <= next_note;
    end
endmodule 

