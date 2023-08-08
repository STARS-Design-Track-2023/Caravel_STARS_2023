module ByteBuffer (
input logic shift_en, clk, n_rst,
input logic [7:0] new_instr,
output logic [23:0] instr);

logic [1:0] counter, next_counter;
logic [23:0] next_instr;

always_ff @(posedge clk, negedge n_rst ) begin : ByteBuffer
    if ( !n_rst)begin
        counter <= 0;
        instr <= 0;
    end
    else begin
        counter <= next_counter;
        instr <= next_instr;
    end 
end

always_comb begin : ByteBufferLogic
    if (!shift_en) begin
        next_counter = 0;
    end
    else begin
       if (counter == 2'b11)
          next_counter = 2'b00;
      else begin
          next_counter = counter + 1;
        end
    end
end

always_comb begin : CounterValueChanger
    next_instr = instr;
    if (shift_en) begin
    case(counter)
        2'b00: begin 
            next_instr = {new_instr, instr[15:0]};

        end
        2'b01: begin 
            next_instr = {instr[23:16],new_instr, instr[7:0]};

        end
        2'b10: begin 
            next_instr = { instr[23:8],new_instr};

        end
        2'b11: next_instr = instr;
    endcase
    end
end
endmodule


