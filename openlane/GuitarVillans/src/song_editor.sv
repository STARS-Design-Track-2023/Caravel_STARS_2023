module song_editor ( // THIS CODE ONLY WORKS WHEN RESET IS ACTIVATED

    // HW

    input logic clk, nrst, toggle, 
    input logic [2:0] mode,
    input logic [1:0] note,

    // Wrapper

    // Chip Select (Active Low)
    output logic [31:0] note1, note2, 
    
    // outputs
    output logic [6:0] display_note1 , display_note2,
    output logic [4:0] position, 
    output logic toggle_state
);


logic [31:0] next_note1, next_note2;
logic [4:0] idx_note1, idx_note2, next_idx1, next_idx2;
logic next_toggle;
logic [4:0] next_position;
logic [1:0] boton_e;
logic boton02e;
parameter [31:0] initial1 = 32'hcccccccc;
parameter [31:0] initial2 = 32'hAAAAAAAA;

// parameter [31:0] initial1 = 32'hFFFFFFFF;
// parameter [31:0] initial2 = 32'hFFFFFFFF;

sync_edge_det boton0e ( .clk(clk), .Rst(nrst), .button_i(note[0]), .sig_f(boton_e[0]));
sync_edge_det boton1e ( .clk(clk), .Rst(nrst), .button_i(note[1]), .sig_f(boton_e[1]));
sync_edge_det boton2e ( .clk(clk), .Rst(nrst), .button_i(toggle), .sig_f(boton02e));
note_led_display drum (.clk(clk), .nrst(nrst), .next_note1(next_note1), .next_note2(next_note2), .mode(mode),
                         .next_idx1(next_idx1), .next_idx2(next_idx2), .display_note1(display_note1), .display_note2(display_note2));

always_ff @(posedge clk, negedge nrst) begin
    if(nrst == 0) begin     
        idx_note1 <= 5'd31;
        idx_note2 <= 5'd31;
        position <= 5'd31;
        toggle_state <= 1'b0;
        note1 <= initial1;
        note2 <= initial2;
    end

    else begin
        idx_note1 <= next_idx1;
        idx_note2 <= next_idx2;
        position <= next_position;
        toggle_state <= next_toggle;
        note1 <= next_note1;
        note2 <= next_note2;
    end
end


always_comb begin
    /*
    if (mode == 3'd1)
        if (pushed_2)
            /set initial values
    */
    if(mode == 3'd2) begin
    next_toggle = toggle_state;
        if(boton02e) begin
            next_toggle = ~toggle_state;
        end
        next_note1 = note1; 
        next_idx1 = idx_note1;
        next_note2 = note2; 
        next_idx2 = idx_note2;
        next_position = position;
        if(toggle_state) begin
            next_note1[idx_note1] = note1[idx_note1]; 
            next_idx1 = idx_note1;
            next_position = idx_note2;
            case(boton_e)
                1: begin next_note2[idx_note2] = 1'b0; next_idx2 = idx_note2 - 1; end
                2: begin next_note2[idx_note2] = 1'b1; next_idx2 = idx_note2 - 1;end
                default: begin next_note2[idx_note2] = note2[idx_note2] ; next_idx2 = idx_note2; end
            endcase  
        end
    else begin
        next_note2[idx_note2] = note2[idx_note2]; 
        next_idx2 = idx_note2;
        next_position = idx_note1;
        case(boton_e)
            1: begin next_note1[idx_note1] = 1'b0; next_idx1 = idx_note1 - 1; end
            2: begin next_note1[idx_note1] = 1'b1; next_idx1 = idx_note1 - 1; end
            default: begin next_note1[idx_note1] = note1[idx_note1] ; next_idx1 = idx_note1; end
        endcase
    end
end 

else begin 
    next_idx1 = 5'd31;
    next_idx2 = 5'd31;
    next_position = 5'd31;
    next_toggle = 1'b0;
    next_note1 = note1;
    next_note2 = note2;

end

end

endmodule







