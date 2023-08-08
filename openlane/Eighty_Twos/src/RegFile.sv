`default_nettype none

module RegFile(input logic [15:0] write_data,
               input logic [7:0] flags,
               input logic [2:0] read_addr_1, read_addr_2, write_addr,
               input logic rp_en, write_en, flag_write_en, n_rst, clk,
               output logic [7:0] accumulator,
               output logic [7:0] flags_to_alu,
               output logic [15:0] read_data_1, read_data_2);

logic [7:0] A, B, C, D, E, H, L, flag_reg, next_A, next_B, next_C, next_D, next_E, next_H, next_L, next_flag_reg;

always_ff @(negedge clk, negedge n_rst) begin
    if(~n_rst) begin
      {A, B, C, D, E, H, L, flag_reg} <= 0;
    end
    else begin
      {A, B, C, D, E, H, L, flag_reg} <= {next_A, next_B, next_C, next_D, next_E, next_H, next_L, next_flag_reg};
    end
end

assign accumulator = A;
assign flags_to_alu = flag_reg;


always_comb begin
  {read_data_1, read_data_2} = 0;
  {next_A, next_B, next_C, next_D, next_E, next_H, next_L, next_flag_reg} = {A, B, C, D, E, H, L, flag_reg};
    //checks if the instruction was to write to the register
  
  if(write_en) begin
      //checks if the write is to a reg or an rp
      if(rp_en) begin
          case(write_addr[1:0])
              2'b11: {next_A, next_flag_reg} = write_data;
              2'b10: {next_H, next_L} = write_data;
              2'b01: {next_D, next_E} = write_data;
              2'b00: {next_B, next_C} = write_data;
          endcase
      end
      else begin
          case(write_addr)
              3'b111: next_A = write_data[7:0];
              3'b110: next_flag_reg = write_data[7:0];
              3'b101: next_L = write_data[7:0];
              3'b100: next_H = write_data[7:0];
              3'b011: next_E = write_data[7:0];
              3'b010: next_D = write_data[7:0];
              3'b001: next_C = write_data[7:0];
              3'b000: next_B = write_data[7:0];
          endcase
      end
  end
  //checks if the instruction was to write a flag
  else if(flag_write_en) begin
    next_flag_reg = flags;
  end
    
  //runs if the instruction was to read

  //checks if the read is from a reg or an rp
  if(rp_en) begin
    case(read_addr_1[1:0])
        2'b11: read_data_1 = {A, flag_reg};
        2'b10: read_data_1 = {H, L};
        2'b01: read_data_1 = {D, E};
        2'b00: read_data_1 = {B, C};
    endcase

    case(read_addr_2[1:0])
        2'b11: read_data_2 = {A, flag_reg};
        2'b10: read_data_2 = {H, L};
        2'b01: read_data_2 = {D, E};
        2'b00: read_data_2 = {B, C};
    endcase
  end
  else begin
    case(read_addr_1)
        3'b111: read_data_1 = {8'b0, A};
        3'b110: read_data_1 = {8'b0, flag_reg};
        3'b101: read_data_1 = {8'b0, L};
        3'b100: read_data_1 = {8'b0, H};
        3'b011: read_data_1 = {8'b0, E};
        3'b010: read_data_1 = {8'b0, D};
        3'b001: read_data_1 = {8'b0, C};
        3'b000: read_data_1 = {8'b0, B};
    endcase

    case(read_addr_2)
        3'b111: read_data_2 = {8'b0, A};
        3'b110: read_data_2 = {8'b0, flag_reg};
        3'b101: read_data_2 = {8'b0, L};
        3'b100: read_data_2 = {8'b0, H};
        3'b011: read_data_2 = {8'b0, E};
        3'b010: read_data_2 = {8'b0, D};
        3'b001: read_data_2 = {8'b0, C};
        3'b000: read_data_2 = {8'b0, B};
    endcase
  end

end

endmodule 