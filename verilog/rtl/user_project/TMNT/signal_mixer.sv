`default_nettype none

module signal_mixer(
    //inputs
    input logic [7:0] sample1 ,    
    input logic [7:0] sample2 ,
    input logic [7:0] sample3 ,
    input logic [7:0] sample4 ,
    input logic [7:0] sample5 ,
    input logic [7:0] sample6 ,
    input logic [7:0] sample7 ,
    input logic [7:0] sample8 ,
    input logic [7:0] sample9 ,
    input logic [7:0] sample10 ,
    input logic [7:0] sample11 ,
    input logic [7:0] sample12 ,
                                            // 12 samples 8-bit input
    input logic [11:0] sample_enable,       //12 samples enable
    //outputs
    output logic [11:0] sample_out,           //1 sample 8-bit output
    output logic [3:0] num_signals
    );
    
    //internal signals 
    logic [11:0] samples [11:0];            // 12 samples 8-bit input
    logic [3:0] sample_num;                 // 12 samples enable

 
    //assign the samples to the internal signals
    assign samples[0] = sample_enable[0]   ? {4'b0,sample1 }: 0;
    assign samples[1] = sample_enable[1]   ? {4'b0,sample2 }: 0;
    assign samples[2] = sample_enable[2]   ? {4'b0,sample3 }: 0;
    assign samples[3] = sample_enable[3]   ? {4'b0,sample4 }: 0;
    assign samples[4] = sample_enable[4]   ? {4'b0,sample5 }: 0;
    assign samples[5] = sample_enable[5]   ? {4'b0,sample6 }: 0;
    assign samples[6] = sample_enable[6]   ? {4'b0,sample7 }: 0;
    assign samples[7] = sample_enable[7]   ? {4'b0,sample8 }: 0;
    assign samples[8] = sample_enable[8]   ? {4'b0,sample9 }: 0;
    assign samples[9] = sample_enable[9]   ? {4'b0,sample10} : 0;
    assign samples[10] = sample_enable[10] ? {4'b0,sample11} : 0;
    assign samples[11] = sample_enable[11] ? {4'b0,sample12} : 0;
    
    //sum all the enabled samples
    assign sample_out = samples[0] + samples[1] + samples[2] + samples[3] + samples[4] + samples[5] + samples[6] + samples[7] + samples[8] + samples[9] + samples[10] + samples[11];
    assign sample_num = {3'b0,sample_enable[0] } + 
                         {3'b0,sample_enable[1] } + 
                         {3'b0,sample_enable[2] } + 
                         {3'b0,sample_enable[3] } + 
                         {3'b0,sample_enable[4] } + 
                         {3'b0,sample_enable[5] } + 
                         {3'b0,sample_enable[6] } + 
                         {3'b0,sample_enable[7] } + 
                         {3'b0,sample_enable[8] } + 
                         {3'b0,sample_enable[9] } + 
                         {3'b0,sample_enable[10]} + 
                         {3'b0,sample_enable[11]};

    assign num_signals = sample_num;

endmodule
