module keypad(input logic [16:0] sync_keys, 
              output logic octave_key_up, octave_key_down, mode_key, goof_key,
              output logic [3:0] keycode,
              output logic strobe);  
assign {octave_key_up, octave_key_down, mode_key, goof_key, keycode, strobe} = 
                          sync_keys[16] == 1? 9'b100000000: 
                          sync_keys[15] == 1? 9'b010000000: 
                          sync_keys[14] == 1? 9'b001000000:  
                          sync_keys[13] == 1? 9'b000100001:  
                          
                          
                          
                          sync_keys[12] == 1? 9'b000011001:  
                          sync_keys[11] == 1? 9'b000010111:  
                          sync_keys[10] == 1? 9'b000010101:  
                          sync_keys[9]  == 1? 9'b000010011:  
                          sync_keys[8]  == 1? 9'b000010001:  
                          sync_keys[7]  == 1? 9'b000001111:  
                          sync_keys[6]  == 1? 9'b000001101:  
                          sync_keys[5]  == 1? 9'b000001011: 
                          sync_keys[4]  == 1? 9'b000001001:  
                          sync_keys[3]  == 1? 9'b000000111:   
                          sync_keys[2]  == 1? 9'b000000101:  
                          sync_keys[1]  == 1? 9'b000000011:  
                          sync_keys[0]  == 1? 9'b000000001:  
                                              9'b000000000;
endmodule