`default_nettype none

/*
    The module outputs the necessary counts for all 12 notes based on the
    given octave (low, medium, high). A higher octave is achieved by dividing
    each of the counts by 2
*/

module frequency_divider (
    input logic clk, nrst,
    input logic o_up, o_down, // octave control up and down
    output logic [17:0] div0, div1, div2, div3, div4, div5, div6, div7, div8, div9, div10, div11
);
    // All counts are derived from the known periods of a full scale
    // (exluding the 13th note) and multiplied by the clock frequency of 10MHz
    logic [17:0] low_c, low_cs, low_d, low_ds, low_e, low_f, low_fs, low_g, low_gs, low_a, low_as, low_b;
    assign low_c = 18'd38223; // count for lowest C
    assign low_cs = 18'd36077; // count for lowest C#
    assign low_d = 18'd34052; // count for lowest D
    assign low_ds = 18'd32141; // count for lowest D#
    assign low_e = 18'd30337; // count for lowest E
    assign low_f = 18'd28635; // count for lowest F
    assign low_fs = 18'd27027; // count for F#
    assign low_g = 18'd25511; // count for G
    assign low_gs = 18'd24079; // count for G#
    assign low_a = 18'd22727; // count for A
    assign low_as = 18'd21452; // count for A#
    assign low_b = 18'd20248; // count for B  

    logic [2:0] state;
    logic [2:0] next_state;

    always_ff @ (posedge clk or negedge nrst) begin
        if (!nrst) begin
            state <= 3'b010;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        if (o_up && !o_down && state != 3'b100)
            next_state = state + 1'b1;
        else if (o_down && !o_up && state != 3'b000)
            next_state = state - 1'b1;
        else
            next_state = state;

        if (state >= 3'b010) begin
            div0 = low_c >> (state - 3'b010);
            div1 = low_cs >> (state - 3'b010);
            div2 = low_d >> (state - 3'b010);
            div3 = low_ds >> (state - 3'b010);
            div4 = low_e >> (state - 3'b010);
            div5 = low_f >> (state - 3'b010);
            div6 = low_fs >> (state - 3'b010);
            div7 = low_g >> (state - 3'b010);
            div8 = low_gs >> (state - 3'b010);
            div9 = low_a >> (state - 3'b010);
            div10 = low_as >> (state - 3'b010);
            div11 = low_b >> (state - 3'b010);
        end
        else begin
            div0 = low_c << (3'b010 - state);
            div1 = low_cs << (3'b010 - state);
            div2 = low_d << (3'b010 - state);
            div3 = low_ds << (3'b010 - state);
            div4 = low_e << (3'b010 - state);
            div5 = low_f << (3'b010 - state);
            div6 = low_fs << (3'b010 - state);
            div7 = low_g << (3'b010 - state);
            div8 = low_gs << (3'b010 - state);
            div9 = low_a << (3'b010 - state);
            div10 = low_as << (3'b010 - state);
            div11 = low_b << (3'b010 - state);        
        end
    end

endmodule