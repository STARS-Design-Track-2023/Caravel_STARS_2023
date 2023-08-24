`default_nettype none

module PC(input logic [15:0] immediate, read_data_1,
          input logic shift_en, instr_read_en, pchl, n_rst, clk, jump, 
          output logic [15:0] i_mem_addr);

logic [15:0] next_pc, pc; // program counters

always_ff @(posedge clk, negedge n_rst) begin
    if(~n_rst) begin
        pc <= 0;
    end
    else begin
        pc <= next_pc;
    end
end

always_comb begin
    //pc only increments when instr_read_en and shift_en are on
    if(instr_read_en & shift_en) begin
        //checks if a jump is taking place (jump is controlled by JumpFlagController module)
        if(jump) begin
            //Mux that decides if read_data_1 or immediate will be used as jump value
            if(pchl) begin
                next_pc = read_data_1;
            end
            else begin
                next_pc = immediate;
            end
        end
        //increaments by one when a jump isn't taking place
        else begin
            next_pc = pc + 1;
        end
    end
    //keeps pc stagenent when instr_read_en or shift_en are off
    else begin
        next_pc = pc;
    end
    //sets i_mem_addr to the value of pc
    i_mem_addr = pc;
end

endmodule