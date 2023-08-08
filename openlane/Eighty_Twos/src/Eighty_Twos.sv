`default_nettype none
module Eighty_Twos (
    // HW
    input logic clk, nrst,
    
    // Wrapper
    input logic cs, // Chip Select (Active Low)
    input logic [33:0] gpi, // Breakout Board Pins
    output logic [33:0] gpo // Breakout Board Pins
);



// Declarations
logic n_rst, halt, load_en, store_en, imm_pass_thru, rp_en, reg_write_en, 
  flag_write_en, pchl, jump_en, shift_en, instr_ready, instr_read_en, jump;
logic [1:0] alu_source, num_bytes, state;
logic [2:0] jump_flag, read_addr_1, read_addr_2, write_addr;
logic [3:0] opcode;
logic [7:0] flags, new_instr, accumulator, flags_to_alu;
logic [15:0] i_mem_addr, immediate, read_data_1, read_data_2, alu, write_data, ram_read_data;
logic [23:0] instr;

// Make nrst compatible with the variable n_rst
assign n_rst = nrst;

// Assign IO pins
always_comb begin : IOPins
  gpo = 0;
  new_instr = 0;
  write_data = load_en? ram_read_data : alu; // mux
  ram_read_data = 0;
  if (cs) begin
      if (gpi[23]) begin // data bus
          if (store_en) begin
              gpo[7:0] = read_data_2[15:8]; // store ram
          end
          else begin
              ram_read_data = {8'b0, gpi[7:0]}; // load ram
          end
      end
      else begin
          new_instr = gpi[7:0]; // read ROM from PC
      end

      gpo[23:8] = store_en? alu : i_mem_addr; // address bus

      gpo[25:24] = {store_en, (load_en | instr_read_en)}; // enables for ROM/RAM
      gpo[33:26] = accumulator; // Accumulator
  end
end

// Instantiating Modules and Connecting Their Inputs and Outputs
PC PC (
  .clk(clk), .n_rst(n_rst), 
  .shift_en(shift_en), .instr_read_en(instr_read_en), .pchl(pchl), .jump(jump), 
  .immediate(immediate), .read_data_1(read_data_1), .i_mem_addr(i_mem_addr)
);

Control Control (
  .instr_ready(instr_ready), .num_bytes(num_bytes), .instr(instr[23:16]),
  .halt(halt), .load_en(load_en), .store_en(store_en), .imm_pass_thru(imm_pass_thru), 
  .rp_en(rp_en), .reg_write_en(reg_write_en), .flag_write_en(flag_write_en), 
  .pchl(pchl), .alu_source(alu_source)
);

ByteDecoder ByteDecoder (
  .clk(clk), .n_rst(n_rst), .instr_ready(instr_ready), .state(state),
  .shift_en(shift_en), .new_instr(new_instr), .next_num_bytes(num_bytes)
);

InstructionDecoder InstructionDecoder(
  .num_bytes(num_bytes), .instr(instr), .jump_flag(jump_flag), .jump_en(jump_en), 
  .read_addr_1(read_addr_1), .read_addr_2(read_addr_2), .write_addr(write_addr), 
  .opcode(opcode), .immediate(immediate)
);

RegFile RegFile (
  .clk(clk), .n_rst(n_rst), 
  .write_data(write_data), .flags(flags), .read_addr_1(read_addr_1), 
  .read_addr_2(read_addr_2), .write_addr(write_addr), .rp_en(rp_en), 
  .write_en(reg_write_en), .flag_write_en(flag_write_en), .read_data_1(read_data_1),
  .read_data_2(read_data_2), .accumulator(accumulator), .flags_to_alu(flags_to_alu)
);

FSM FSM (
  .clk(clk), .n_rst(n_rst), .instr_read_en(instr_read_en),
  .num_bytes(num_bytes), .shift_en(shift_en), .instr_ready(instr_ready), .state(state)
);

ByteBuffer ByteBuffer (
  .clk(clk), .n_rst(n_rst), 
  .shift_en(shift_en), .new_instr(new_instr), .instr(instr)
);

MemControl MemControl (
  .clk(clk), .n_rst(n_rst), 
  .halt(halt), .load_en(load_en), .store_en(store_en), .instr_read_en(instr_read_en)
);

JumpFlagController JumpFlagController (
  .flags(flags), .jump_flag(jump_flag), .jump_en(jump_en), .jump(jump)
);

ALU ALU (
  .rp_en(rp_en), .opcode(opcode), .read_data_1(read_data_1), .read_data_2(read_data_2), 
  .imm_pass_thru(imm_pass_thru), .alu_source(alu_source), .immediate(immediate), 
  .flags(flags), .alu(alu), .flags_to_alu(flags_to_alu)
);

endmodule