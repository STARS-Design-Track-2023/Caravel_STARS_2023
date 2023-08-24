module ALU(input logic rp_en, imm_pass_thru, 
        input logic [1:0] alu_source, 
        input logic [3:0] opcode, 
        input logic [7:0] flags_to_alu, 
        input logic [15:0] read_data_1, read_data_2, immediate, 
        output logic [7:0] flags,
        output logic [15:0] alu);
logic car, aux, sign, zero, par, ending, temp_car;
logic [15:0] output_large, zeros, ones, input1, input2;
logic [7:0] output_small;
logic [3:0] ones_amt;
//accumulator is input 1


always_comb
begin
zeros = 16'd0;
ones = 16'd1;
car = 0;
temp_car = 0;
output_large = 0;
output_small = 0;
if (imm_pass_thru == 1)
    input1 = zeros;
else
    input1 = read_data_1;


if (alu_source == 2'b00)
    input2 = read_data_2;
else if (alu_source == 2'b01)
    input2 = immediate;
else if (alu_source == 2'b10)
    input2 = zeros;
else
    input2 = ones;



if (rp_en == 1) begin
    case(opcode)
        0: {car, output_large[15:0]} = input1 + input2; //add
        2: begin {temp_car, output_large[15:0]} = input1 - input2; car = temp_car; end//sub
        default: begin output_large[15:0] = input1; car = 1; end
    endcase
    ending = output_large[15];
    ones_amt = {2'b0,output_large[0]} + {2'b0,output_large[1]} + {2'b0,output_large[2]} + {2'b0,output_large[3]} + {2'b0,output_large[4]} + {2'b0,output_large[5]} + {2'b0,output_large[6]} + {2'b0,output_large[7]} + {2'b0,output_large[8]} + {2'b0,output_large[9]} + {2'b0,output_large[10]} + {2'b0,output_large[11]} + {2'b0,output_large[12]} + {2'b0,output_large[13]} + {2'b0,output_large[14]} + {2'b0,output_large[15]};
    end

else begin
    
    case(opcode)
        0: {car, output_small[7:0]} = input1[7:0] + input2[7:0]; //add
        1: {car, output_small[7:0]} = input1[7:0] + input2[7:0] + {7'b0,flags_to_alu[0]}; //adc
        2: begin {temp_car, output_small[7:0]} = input1[7:0] - input2[7:0]; car = temp_car; end //sub
        3: begin {temp_car, output_small[7:0]} = input1[7:0] - (input2[7:0] + {7'b0,flags_to_alu[0]}); car = temp_car; end //sbb
        4: begin output_small[7:0] = input1[7:0] & input2[7:0]; car = 0; end //ana
        5: begin output_small[7:0] = input1[7:0] ^ input2[7:0]; car = 0; end //xra
        6: begin output_small[7:0] = input1[7:0] | input2[7:0]; car = 0; end //ora
        7: begin {temp_car, output_small[7:0]} = input1[7:0] - input2[7:0]; car = temp_car; end //cmp 
        8: {car, output_small[7:0]} = {input1[7:0],input1[7]}; //rlc
        9: {output_small[7:0], car} = {input1[0], input1[7:0]};//rrc
        10: {car, output_small[7:0]} = {input1[7:0], flags_to_alu[0]}; //ral
        11: {output_small[7:0], car} = {flags_to_alu[0], input1[7:0]}; //rar
        12: begin output_small[7:0] = ~input1[7:0]; car = flags_to_alu[0]; end //daa ********************** DO AUX CARRY
        13: begin output_small[7:0] = ~input1[7:0]; car = flags_to_alu[0]; end//cma
        14: begin output_small[7:0] = input1[7:0]; car = 1; end //stc
        15: begin output_small[7:0] = input1[7:0]; car = ~flags_to_alu[0]; end //cmc
        default: begin output_small[7:0] = input1[7:0]; car = 1; end
    endcase
    ending = output_small[7];
    ones_amt = {2'b0,output_small[0]} + {2'b0,output_small[1]} + {2'b0,output_small[2]} + {2'b0,output_small[3]} + {2'b0,output_small[4]} + {2'b0,output_small[5]} + {2'b0,output_small[6]} + {2'b0,output_small[7]};
end



if (rp_en == 1)
    alu = output_large;
else
    alu = {8'b0, output_small};


if (ones_amt == 4'd1 || ones_amt == 4'd3 || ones_amt == 4'd5 || ones_amt == 4'd7 || ones_amt == 4'd9 || ones_amt == 4'd11 || ones_amt == 4'd13 || ones_amt == 4'd15)
    par = 0;
else 
    par = 1;

if (alu == 16'd0)
    zero = 1;
else
    zero = 0;

sign = ending;

/*
case(opcode)
    0: {car, outalu[15:0]} = input1 + input2; //add
    1: {car, outalu[15:0]} = input1 + input2 + flags_to_alu[0]; //adc
    2: {~car, outalu[15:0]} = input1 - input2; //sub
    3: {~car, outalu[15:0]} = input1 - input2 - flags_to_alu[0]; //sbb
    4: begin outalu[15:0] = input1 & input2; car = 0; end //ana
    5: begin outalu[15:0] = input1 ^ input2; car = 0; end //xra
    6: begin outalu[15:0] = input1 | input2; car = 0; end //ora
    7: {~car, outalu[15:0]} = input1 - input2; //cmp 
    8: {car, outalu[15:8]} = {input1[7:0],input1[7]}; //rlc
    9: {outalu[15:8], car} = {input1[0], input1[7:0]};//rrc
    10: {car, outalu[15:8]} = {input1[7:0], car}; //ral
    11: {outalu[15:8], car} = {car, input1[7:0]}; //rar
    12: begin outalu[15:8] = ~input1; car = flags_to_alu[0]; end //daa
    13: begin outalu[15:8] = ~input1; car = flags_to_alu[0]; end//cma
    14: begin outalu[15:0] = input1; car = 1; end //stc
    15: begin outalu[15:0] = input1; car = ~flags_to_alu[0]; end //cmc
    default: begin outalu[15:0] = input1; car = 1; end
endcase
*/

flags = {sign, zero, 1'b0, 1'b0, 1'b0, par, 1'b1, car};

end
endmodule



