`timescale 1ns/1ns

module tb_sass_synth();


localparam CLK_PERIOD = 100; // 10 MHz clock

/****** DUT Input Signals ******/ 
reg[14:0] tb_piano_keys; 
reg tb_cs; 
reg tb_n_rst;
reg tb_clk; 
reg tb_tempo_select; 
reg tb_seq_power; 
reg tb_seq_play; 


/****** DUT Output Signals ******/ 
wire tb_pwm_o; 
wire tb_seq_led_on; 
wire[7:0] tb_beat_led;
wire[1:0] tb_mode_out;



// for loop var
integer i; 

// Generate the Clock
always begin
    tb_clk = 1'b0;
    #(CLK_PERIOD / 2.0);
    tb_clk = 1'b1; 
    #(CLK_PERIOD / 2.0);
end




/* --- Port Map (One for gl sim and the other for RTL sim) --- */
`ifdef USE_POWER_PINS
sass_synth DUT
(
    .VPWR(1),
    .VGND(0),
    
    .hwclk(tb_clk),
    .n_rst(tb_n_rst),
    .cs(tb_cs),
    .piano_keys(tb_piano_keys),
    .tempo_select(tb_tempo_select),
    .seq_power(tb_seq_power),
    .seq_play(tb_seq_play),

    .pwm_o(tb_pwm_o),
    .seq_led_on(tb_seq_led_on),
    .beat_led(tb_beat_led),
    .mode_out(tb_mode_out)
);
`else
sass_synth DUT
(
   .hwclk(tb_clk),
    .n_rst(tb_n_rst),
    .cs(tb_cs),
    .piano_keys(tb_piano_keys),
    .tempo_select(tb_tempo_select),
    .seq_power(tb_seq_power),
    .seq_play(tb_seq_play),

    .pwm_o(tb_pwm_o),
    .seq_led_on(tb_seq_led_on),
    .beat_led(tb_beat_led),
    .mode_out(tb_mode_out)
);
`endif
/* -------------------------- END ---------------------------- */

// Create a file for Signal Dump
initial begin
    $dumpfile ("dump.vcd");
    $dumpvars;
end

/* --------- SDF annotation to simulate time for the verilog model -------- */
`ifdef ENABLE_SDF
initial begin
    $sdf_annotate("mapped/synth.sdf", DUT,,);
end
`endif
/* ------ Please do not modify this code should be there in every tb ------ */




// store the simulation data
initial begin
    $dumpfile("dump.vcd");
    $dumpvars; 
end


initial begin
    // initialize values
    tb_piano_keys = 0; 
    tb_cs = 1'b0; 
    tb_n_rst = 1'b0; 
    tb_tempo_select = 0; 
    tb_seq_play = 0; 
    tb_seq_power = 0; 


    // de-assert the reset
    @(negedge tb_clk);
    tb_n_rst = 1'b1; 
    @(negedge tb_clk); 


    // NOTE 1: this test bench only attempts one test at a time

    // TEST CASE 1: test single note w/ the piano middle octave w/ square mode
    // tb_piano_keys[0] = 1'b1; // play a middle C-note (261 Hz)
    // tb_piano_keys[14] = 1'b1; 
    // @(negedge tb_clk); 
    // tb_piano_keys[14] = 1'b0; 


    // #(4000000); // wait enough for at least one period on the waveform
    // successfull: we get a 3.8 ms period square wave. 

    // // TEST CASE 2: test single note w/ the piano middle octave w/ triangle mode 
    // tb_piano_keys[0] = 1'b1; // play a middle C-note (261 Hz)
    
    // // change to square
    // tb_piano_keys[14] = 1'b1; 
    // @(negedge tb_clk); 
    // tb_piano_keys[14] = 1'b0; 
    // @(negedge tb_clk); 
    
    // // change to saw 
    // tb_piano_keys[14] = 1'b1; 
    // @(negedge tb_clk); 
    // tb_piano_keys[14] = 1'b0; 
    // @(negedge tb_clk); 

    // // change to tri
    // tb_piano_keys[14] = 1'b1; 
    // @(negedge tb_clk); 
    // tb_piano_keys[14] = 1'b0; 
    // @(negedge tb_clk); 
    


    // #(4000000); // wait enough for at least one period on the waveform
    // // successfull: we get a 3.8 ms period triangle wave. 


    // TEST CASE 3: test OCT 7 w/ 4 notes playing w/ saw
    // tb_piano_keys[3:0] = 4'hF; 
    
    // // change to saw
    // for(i = 0; i < 2; i = i + 1) begin
    //     tb_piano_keys[14] = 1'b1; 
    //     @(negedge tb_clk); 
    //     tb_piano_keys[14] = 1'b0; 
    //     @(negedge tb_clk); 
    // end


    // // change from OCT 4 to OCT 7
    // for(i = 0; i < 3; i = i + 1) begin
    //     tb_piano_keys[13] = 1'b1; 
    //     @(negedge tb_clk); 
    //     tb_piano_keys[13] = 1'b0;
    //     @(negedge tb_clk); 
    // end


    // #(70000); // wait and observe the waveform

    // comments: correct mode + octave + mixer and behaves as expected


    // TEST CASE 4: test the sequencer

    // turn on the sequencer
    tb_seq_power = 1'b1; 
    @(negedge tb_clk); 
    tb_seq_power = 1'b0; 

    tb_seq_play = 1'b1; 
    @(negedge tb_clk);
    tb_seq_play = 1'b0; 

    // change to SQ wave 
    tb_piano_keys[14] = 1'b1; 
    @(negedge tb_clk); 
    tb_piano_keys[14] = 1'b0; 


    // set the notes for the beat: D# in 4th octave
    for(i = 0; i < 4; i = i + 1) begin
        @(negedge tb_clk); 
        tb_piano_keys[0] = 1'b1; 
        @(negedge tb_clk); 
        tb_piano_keys = 1'b0; 
    end
    

    #(1000000000); // simulate for a second


    
    $finish;
end









endmodule 