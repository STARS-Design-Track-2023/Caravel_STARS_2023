module note_led_display (
    input logic [2:0] mode, 
    input logic nrst, clk, 
    input logic [31:0] next_note1, next_note2, 
    input logic [4:0] next_idx1, next_idx2,
    output logic [6:0] display_note1 , display_note2);


    logic [6:0] next_d1, next_d2;

    always_ff @(posedge clk, negedge nrst) begin

        if(nrst == 1'b0) begin

            display_note1 <= 7'b0;
            display_note2 <= 7'b0;

        end

        else begin

            display_note1 <= next_d1;
            display_note2 <= next_d2;


        end



    end


    always_comb begin
        next_d1 = display_note1;
        next_d2 = display_note2;
        if(mode == 3'd2) begin 
            case(next_idx2)
            0: next_d2 = {next_note2[0], 6'b0};
            1: next_d2 = {next_note2[1:0], 5'b0};
            2: next_d2 = {next_note2[2:0], 4'b0};
            3: next_d2 = {next_note2[3:0], 3'b0};
            4: next_d2 = {next_note2[4:0], 2'b0};
            5: next_d2 = {next_note2[5:0], 1'b0};
            default: begin
                next_d2[0] = next_note2[next_idx2 - 6];
                next_d2[1] = next_note2[next_idx2 - 5];
                next_d2[2] = next_note2[next_idx2 - 4];
                next_d2[3] = next_note2[next_idx2 - 3];
                next_d2[4] = next_note2[next_idx2 - 2];
                next_d2[5] = next_note2[next_idx2 - 1];
                next_d2[6] = next_note2[next_idx2];
            end
            endcase
            
            case(next_idx1)
            0: next_d1 = {next_note1[0], 6'b0};
            1: next_d1 = {next_note1[1:0], 5'b0};
            2: next_d1 = {next_note1[2:0], 4'b0};
            3: next_d1 = {next_note1[3:0], 3'b0};
            4: next_d1 = {next_note1[4:0], 2'b0};
            5: next_d1 = {next_note1[5:0], 1'b0};
            default: begin
                next_d1[0] = next_note1[next_idx1 - 6];
                next_d1[1] = next_note1[next_idx1 - 5];
                next_d1[2] = next_note1[next_idx1 - 4];
                next_d1[3] = next_note1[next_idx1 - 3];
                next_d1[4] = next_note1[next_idx1 - 2];
                next_d1[5] = next_note1[next_idx1 - 1];
                next_d1[6] = next_note1[next_idx1];
            end
            endcase
        end
        else begin

            next_d1 = 0;
            next_d2 = 0;

        end

    end

    endmodule