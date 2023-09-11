module sound_driver (
    input logic clk, nrst,
    input logic [17:0] divider,
    input logic [1:0] mode,
    input logic strobe,
    output logic pwm_output
);

logic [17:0] signal, signal_buffer, signal_buffer1, signal_buffer2, divider_buffer, divider_buffer1, divider_buffer2;
logic [7:0] scaled_signal, scaled_buffer, wave;
logic pulse, pwm_signal;

oscillator sig_gen (divider_buffer, clk, nrst, signal);
clock_div39kHz sample_rate (clk, nrst, pulse);
sequential_divider div (clk, nrst, pulse, divider_buffer1, signal_buffer1, scaled_signal);
waveshaper shaper (divider_buffer, signal_buffer, scaled_buffer, mode, wave);
pwm output_gen (clk, nrst, strobe, wave, pwm_signal);

always_ff @(posedge clk, negedge nrst) begin
    if (~nrst) begin
        signal_buffer <= 0;
        divider_buffer <= 0;
        scaled_buffer <= 0;
        signal_buffer1 <= 0;
        signal_buffer2 <= 0;
        divider_buffer1 <= 0;
        divider_buffer2 <= 0;
    end else if (pulse) begin
        signal_buffer <= signal_buffer2;
        signal_buffer1 <= signal;
        signal_buffer2 <= signal_buffer1;
        divider_buffer <= divider_buffer2;
        divider_buffer1 <= divider;
        divider_buffer2 <= divider_buffer1;
        scaled_buffer <= scaled_signal;
    end
end

always_ff @(posedge clk, negedge nrst) begin
    if (~nrst)
        pwm_output <= 0;
    else
        pwm_output <= pwm_signal;
end

endmodule