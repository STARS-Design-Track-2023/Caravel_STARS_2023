`default_nettype none

module read_write(
    input logic clk, mem_write_en, mem_read_en, dbl_byte_en, cmp, nrst, ack,
    input logic [15:0] data_in, address,
    output logic enable, cmp_o, wr,
    output logic [3:0] max,
    output logic [7:0] data_to_mem,
    output logic [15:0] address_to_mem
);

    logic write_check, cmp_check;
    logic [2:0] state, next_state;
    typedef enum logic [2:0] {idle, read8, write8, read16, write16, write16_2, read16_2} state_t;

    always_ff @(posedge clk, negedge nrst) begin : bandaidflop
        if (~nrst) begin 
            state <= idle;
            cmp_o <= 0;
        end
        else begin
            state <= next_state;
            cmp_o <= cmp_check;
        end
    end

    always_comb begin //ensures writing to RAM only
        if (address <= 16'h7FFF && mem_write_en) write_check = 0;
        else write_check = mem_write_en & ~cmp_o;
    end

    always_comb begin
        case (state)
            idle: begin
                enable = 0;
                wr = 0;
                address_to_mem = 16'h0000;
                data_to_mem = 8'b0;
                cmp_check = 0;
            end
            read8: begin
                wr = 0;
                enable = 1;
                address_to_mem = address;
                data_to_mem = 8'b0;
                cmp_check = cmp? 1:0;
            end
            write8: begin
                wr = 1;
                enable = 1;
                data_to_mem = data_in[7:0];
                address_to_mem = address;
                cmp_check = cmp;
            end
            read16: begin
                wr = 0;
                enable = 1; //ensures enable for counter stays on during use
                data_to_mem = 8'b0;
                address_to_mem = address;
                cmp_check = 0;
            end
            write16: begin
                wr = 1;
                enable = 1; //ensures enable for counter stays on during use
                data_to_mem = data_in[7:0];
                address_to_mem = address - 2;
                cmp_check = 0;
            end
            write16_2: begin
                wr = 1;
                enable = 1; //ensures enable for counter stays on during use
                data_to_mem = data_in[15:8];
                address_to_mem = address - 1;
                cmp_check = cmp;
            end
            read16_2: begin
                wr = 0;
                enable = 1; //ensures enable for counter stays on during use
                data_to_mem = 8'b0;
                address_to_mem = address + 1;
                cmp_check = cmp;
            end
            default: begin
                wr = 0;
                enable = 0;
                address_to_mem = 16'b0;
                data_to_mem = 8'b0;
                cmp_check = 0;
            end
        endcase
    end

    always_comb begin
        // TODO: DETERMINE PROPER MAXIMUM HERE
        max = 2;
        case (state)
            idle: if (mem_read_en && ~ ack) begin
                      if (dbl_byte_en) next_state = read16;
                      else next_state = read8; end
                  else if (write_check && ~ack) begin
                      if (dbl_byte_en) next_state = write16;
                      else next_state = write8; end
                  else begin
                        next_state = idle;
                  end
            read8: next_state = ack ? idle : read8;
            write8: next_state = ack ? idle : write8;
            read16: if (cmp) next_state = read16_2;
                    else next_state = read16;
            write16: if (cmp) next_state = write16_2;
                     else next_state = write16;
            write16_2: if (ack) next_state = idle;
                       else next_state = write16_2;
            read16_2: if (ack) next_state = idle;
                      else next_state = read16_2;
            default: next_state = idle;
        endcase
    end
endmodule
