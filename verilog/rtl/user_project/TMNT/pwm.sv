`default_nettype none


module pwm(
    //inputs
    input logic clk,            //clock
    input logic n_rst,          //active low reset
    input logic start,          //start signal from wave shaper
    input logic [7:0] final_in, //final input from signal mixer
    //outputs
    output logic pwm_out         //pwm output
    );

    //internal signals
    logic [7:0] final_sample_in;     //sample input from signal mixer
    logic [7:0] counter;            //counter for pwm
    logic [7:0] next_counter;       //next counter for pwm
    logic next_pwm_out;             //next pwm output

    //Flip flop for pwm
    always_ff @(posedge clk, negedge n_rst) begin
        if (!n_rst) begin
            counter <= 8'b0;
            pwm_out <= 1'b0;
            final_sample_in <= 0;
        end
        else begin
            if (start)
                final_sample_in <= final_in;
            counter <= next_counter;
            pwm_out <= next_pwm_out;
        end
    end

    //comb logic for pwm
    always_comb begin
        //next counter
        if(counter == 255)
            next_counter = 8'b0;
        else
            next_counter = counter + 1;

        //next pwm output
        if( counter < final_sample_in)
            next_pwm_out = 1'b1;
        else
            next_pwm_out = 1'b0;
    end

endmodule