module stopwatch (
    input logic clk, nrst, pb_0, pb_1,
    output logic [6:0] out_0, out_1, out_2, out_3,
    output logic time_done
);

       logic pb1, pb0, clkdiv, clear, read, write, enable, enable_decrement, enable_increment,time_up;
       logic [1:0] output_select;
       logic [11:0] time_out, time_to_decode, timer_out, memout;
       logic [5:0] out0, out2, out1, out3;
       edge_detect e1 (.clk(clk), .nrst(nrst), .async_in(pb_0), .pos_edge(pb0));
       edge_detect e2 (.clk(clk), .nrst(nrst), .async_in(pb_1), .pos_edge(pb1));
       fsm FSM (.clk(clk), .nrst(nrst), .pb1(pb1), .pb0(pb0), .clear(clear), .read(read), .write(write), .enable_increment(enable_increment), 
       .enable_decrement(enable_decrement), 
       .output_select(output_select), .flag(time_up), .enable(enable));
       clkdiv CLKDIV (.clk(clk), .nrst(nrst), .secpulse(clkdiv));
       counter CTR (.clk(clk), .nrst(nrst), .enable(enable), .clock_div(clkdiv), .time_out(time_out), .clear(clear));
       output_sel sel (.timer(timer_out), .stopwatch(time_out), .mem(memout), .output_select(output_select), .time_to_decode(time_to_decode));
       decoder D1 (.counter_out(time_to_decode), .out0(out0), .out1(out1), .out2(out2), .out3(out3));
       timer TIM (.clk(clk), .nrst(nrst), .enable_dec(enable_decrement), .enable_in(enable_increment), 
       .clk_div(clkdiv), .lap(pb0), .clear(clear), .time_up(time_up), .timer_out(timer_out));
       memory MEM (.clk(clk), .nrst(nrst), .count(time_out), .read(read), .write(write), .out(memout), .clear(clear));
       encode ec0 (.binary(out0), .sv_seg(out_0));
       encode ec1 (.binary(out1), .sv_seg(out_1));
       encode ec2 (.binary(out2), .sv_seg(out_2));
       encode ec3 (.binary(out3), .sv_seg(out_3));
       assign time_done = time_up;
endmodule
