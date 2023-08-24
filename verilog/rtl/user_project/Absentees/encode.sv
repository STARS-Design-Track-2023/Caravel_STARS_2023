module encode (input logic [5:0] binary, output logic [6:0] sv_seg);
  always_comb begin
    case(binary)
     0: sv_seg = 7'b0111111;
     1: sv_seg = 7'b0000110;
     2: sv_seg = 7'b1011011;
     3: sv_seg = 7'b1001111;
     4: sv_seg = 7'b1100110;
     5: sv_seg = 7'b1101101;
     6: sv_seg = 7'b1111101;
     7: sv_seg = 7'b0000111;
     8: sv_seg = 7'b1111111;
     9: sv_seg = 7'b1101111;
     default: sv_seg = 7'b0;
    endcase
  end
endmodule