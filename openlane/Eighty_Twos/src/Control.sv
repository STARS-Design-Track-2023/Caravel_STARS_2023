module Control(input logic [1:0] num_bytes, 
               input logic instr_ready,
               input logic [7:0] instr, 
               output logic halt, load_en, store_en, 
                 imm_pass_thru, rp_en, reg_write_en, 
                 flag_write_en, pchl, 
               output logic [1:0] alu_source);

logic [7:0] code;
assign code = instr; 

always_comb  begin
  halt = 0; // changed by Dev from 1 to 0
  load_en = 0;
  store_en = 0;
  pchl = 0;
  rp_en = 0;
  imm_pass_thru = 0;
  alu_source = 2'b00;
  reg_write_en = 0;
  flag_write_en = 0;



  if(instr_ready == 1) 
  begin
    halt = 0;
    load_en = 0;
    store_en = 0;
    pchl = 0;
    rp_en = 0;

    if (code[7:6] == 2'b00) begin //NOP, LXI, STAX, INX, INR, DCR, MVI, ROTATES, DAD, LDAX, DCX 
      if (code[2] == 0) begin //NOP, LXI, STAX, INX, DAD, LDAX, DCX
        if (code[2:0] == 3'd0) begin //NOP = everything 0
          imm_pass_thru = 0;
          alu_source = 2'b00;
          reg_write_en = 0;
          flag_write_en = 0;
        end
        else begin//LXI, STAX, INX, DAD, LDAX, DCX
          rp_en = 1;
          if (code[1:0] == 2'b01) begin //LXI, DAD
            if (code[3] == 1'b1) begin//DAD
              imm_pass_thru = 0;
              alu_source = 2'b00;
              reg_write_en = 1;
              flag_write_en = 1; 
            end
            else begin//LXI
              imm_pass_thru = 1;
              alu_source = 2'b01;
              reg_write_en = 1;
              flag_write_en = 0; 
            end
          end
          else if (code[1:0] == 2'b10) begin //LDAX, STAX
            imm_pass_thru = 0;
            alu_source = 2'b10;
            if (code[3] == 1'b1) begin//LDAX into register
              load_en = 1;
              reg_write_en = 1;
              flag_write_en = 1; 
            end
            else begin //STAX into RAM
              store_en = 1;
              reg_write_en = 0;
              flag_write_en = 0; 
            end
          end
          else if (code[1:0] == 2'b11) begin //INX, DCX
            imm_pass_thru = 0;
            alu_source = 2'b11;
            reg_write_en = 1;
            flag_write_en = 0; end
          else begin //NOP
            imm_pass_thru = 0;
            alu_source = 2'b00;
            reg_write_en = 0;
            flag_write_en = 0; end
        end
      end
      else begin
        if (code[1] == 0) begin // INR/DCR
          imm_pass_thru = 0; 
          alu_source = 2'b11;
          reg_write_en = 1;
          flag_write_en = 1; 
        end
        else begin //INR, DCR, MVI, STC/CMC, DAA/CMA, RLC/RRC/RAL/RAR
          if (code[0] == 1) begin // STC/CMC, DAA/CMA, RLC/RRC/RAL/RAR
            if (code[5] == 1) begin // STC/CMC, DAA/CMA
              if(code[4] == 1) begin // STC/CMC
                imm_pass_thru = 0;
                alu_source = 2'b00;
                reg_write_en = 0;
                flag_write_en = 1; 
              end
              else begin // DAA/CMA
                imm_pass_thru = 0;
                alu_source = 2'b00;
                reg_write_en = 1;
                flag_write_en = 0; 
              end
            end
            else begin // RLC/RRC/RAL/RAR
              imm_pass_thru = 0; 
              alu_source = 2'b10;
              reg_write_en = 1;
              flag_write_en = 1; 
            end
          end
          else begin //MVI
            imm_pass_thru = 1;
            alu_source = 2'b01;
            reg_write_en = 1;
            flag_write_en = 0; 
          end
        end
      end
    end
    else if(code[7:6] == 2'b01) begin //MOV, HLT
      if (code[5:0] == 6'b110110) begin //HLT
        halt = 1'b1;
        imm_pass_thru = 0;
        alu_source = 2'b00;
        reg_write_en = 0;
        flag_write_en = 0;
      end
      else begin //MOV
        imm_pass_thru = 0;
        alu_source = 2'b10;
        reg_write_en = 1;
        flag_write_en = 0; 
      end
    end



    else if(code[7:6] == 2'b10) begin //ALU stuff 
      imm_pass_thru = 0;
      alu_source = 2'b00;
      flag_write_en = 1;
      if (code[5:3] == 3'b111)
        reg_write_en = 0;
      else
        reg_write_en = 1; 
    end
 


    else begin // code[7:6] == 2'b11
      if (code[2:0] == 3'b110) begin //ALU immediate 
        imm_pass_thru = 1;
        alu_source = 2'b01;
        flag_write_en = 1; 
        if (code[5:3] == 3'b111)
          reg_write_en = 0;
        else
          reg_write_en = 1;
      end
      else if (code[2:1] == 2'b01) begin //jumpy jump JMP
        imm_pass_thru = 1;
        alu_source = 2'b01;
        reg_write_en = 0;
        flag_write_en = 0; 
      end
      else if(code[5:0] == 6'b101001) begin //pchl
          
        imm_pass_thru = 1;
        alu_source = 2'b01;
        reg_write_en = 0;
        flag_write_en = 0; 
        pchl = 1;
      end
      else begin
        imm_pass_thru = 0;
        alu_source = 2'b00;
        reg_write_en = 0;
        flag_write_en = 0; 
      end
    end
  end

end
endmodule