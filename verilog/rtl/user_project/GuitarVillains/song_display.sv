module song_display ( output logic toggle_green, toggle_red, input logic clk, nrst, toggle, input logic [2:0] mode,

                     input logic [1:0] note, output logic [31:0] note1, note2, output logic [6:0] units, tens, output logic [6:0] display_note1 , display_note2) ;

    //logic [31:0]  next_display, current_note;
    logic toggle_state, next_green, next_red;
    logic [4:0] position;

    song_editor um (.clk(clk), .nrst(nrst), .toggle(toggle), .note(note), .note1(note1), 
                    .display_note1(display_note1), .display_note2(display_note2), 
                    .note2(note2), .position(position), .toggle_state(toggle_state), .mode(mode));
    ssdec mi6 (.in(position), .out(units), .tens(tens));


    always_ff @(posedge clk, negedge nrst) begin

        if(nrst == 1'b0) begin

            toggle_green <= 0;
            toggle_red <= 0;

        end

        else begin

            // current_note <= next_display;
            toggle_green <= next_green;
            toggle_red <= next_red;

        end



    end



    always_comb begin


        if(mode == 3'd2) begin
        /* case(toggle_state)
        0: next_display = note1;
        1: next_display = note2;
        endcase */
        next_green = ~toggle_state;
        next_red = toggle_state;


        end
        else begin

            next_green = 1'b0;
            next_red = 1'b0;

        end

    end



endmodule

// Add more modules down here...


