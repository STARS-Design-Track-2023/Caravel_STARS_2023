module decoder (input logic [11:0] counter_out,
output logic [5:0] out0, out1, out2, out3
);
  
  logic [5:0] minute, second;
  logic [5:0] m1, m0, s1, s0;
  
  always_comb begin
    minute = counter_out[11:6];
    second = counter_out[5:0];


        if(second >= 60) begin 
            out1 = 6;
            out0 = second - 60;
        end 
        else if(second >= 50) begin 
            out1 = 5;
            out0 = second - 50;

        end 
        else if(second >= 40) begin
            out1 = 4;
            out0 = second - 40;
        end 

        else if(second >= 30) begin
            out1 = 3;
            out0 = second - 30;
        end 
        else if(second >= 20) begin
            out1 = 2;
            out0 = second - 20;
        end 
        else if(second >= 10) begin
            out1 = 1;
            out0 = second - 10;
        end 
        else begin
            out1 = 0;
            out0 = second;
        end 



        // if(minute >= 90) begin 
        //     out3 = 9;
        //     out2 = second - 90;
        // end 
        // else if(minute >= 80) begin 
        //     out3 = 8;
        //     out2 = minute - 80;
        // end 
        // else if(minute >= 70) begin 
        //     out3 = 7;
        //     out2 = minute - 70;
        // end 
        if(minute >= 60) begin 
            out3 = 6;
            out2 = minute - 60;
        end 
        else if(minute >= 50) begin 
            out3 = 5;
            out2 = minute - 50;

        end 
        else if(minute >= 40) begin
            out3 = 4;
            out2 = minute - 40;
        end 

        else if(minute >= 30) begin
            out3 = 3;
            out2 = minute - 30;
        end 
        else if(minute >= 20) begin
            out3 = 2;
            out2 = minute - 20;
        end 
        else if(minute >= 10) begin
            out3 = 1;
            out2 = minute - 10;
        end 
        else begin
            out3 = 0;
            out2 = minute;
        end 
  end 

  
endmodule

