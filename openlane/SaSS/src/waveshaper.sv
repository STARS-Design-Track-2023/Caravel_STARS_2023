// ************************************************************************************************
// Waveshaper
//   inputs: Q <- 8 bits from seq div the quotient
//           mode <- 3 bits from mode FSM to determine if synth should output off, square, saw,
//                   or triangle
//           count <- 19 bits from osc
//           divisor <- 19 bits from freq div table
//
//   output: sample <- 8 bit fed to PWM to determine duty cycle
//
//   Use: turns vaules from seq div into shaped waves
//
//        off         
//
//                   __________________________  
//
//
//        square     _____        ______
//                        |      |      |
//                        |______|      |______
//   
//        saw          /|  /|  /|  /|  /|  /|
//                    / | / | / | / | / | / | /
//                   /  |/  |/  |/  |/  |/  |/
//
//        triangle     /\    /\    /\    /\
//                    /  \  /  \  /  \  /  \
//                   /    \/    \/    \/    \
//
//
// ************************************************************************************************

module waveshaper(
    input logic [8:0] Q,
    input logic [2:0] mode,
    input logic [18:0] count, divisor,
    output logic [8:0] sample
);
    logic [10:0] b_sample;      //larger sample used as a inbetween holder for the triangle wave math
    logic [10:0] q_temp;

    assign q_temp = {2'b00, Q};  
    always_comb begin
        case(mode)
            0: b_sample = 0;                                //off
            1: b_sample = (count > divisor >> 1) ? 11'd256 : 0; //square, if the count is half way through the total value out put high
            2: b_sample = {q_temp};                        //saw, out put the scaled value from the seq div
            3: begin                                        //triangle, increasig like a saw wave while below half way through the total then decreasing
                if(count < divisor >> 1)                    // |
                    b_sample = {q_temp} << 1;              // |
                else                                        // |
                    b_sample = 11'd512 - ({q_temp} << 1);      //\ /
               end
            default: b_sample = 0;
        endcase
        sample = b_sample[8:0];
    end
endmodule