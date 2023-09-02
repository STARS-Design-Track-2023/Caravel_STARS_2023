module integrated_designs (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    input wire clk, 
    input wire n_rst,

    input wire [3:0] design_select, 
    /* 
    if design select == 0, no design is selected.
    If design_select == 1, design_1 is selected 
    If design_select == 2, design_2 is selected
    ...
    Up to design_12  
    */

    input wire [33:0] gpio_in, 
    
    output wire [33:0] gpio_oeb,
    output wire [33:0] gpio_out
);

wire [33:0] designs_gpio_out[1:12]; // start counting from 1 b/c of the design_select behavior
wire [33:0] designs_gpio_oeb[1:12]; 

wire [12:1] designs_cs; // active low chip select input for the designs.

wire [12:1] designs_n_rst;  // active low reset for each design

/* 
    gpio_in signal multiplexing:

    Just pass all 34 gpio_in signals to each of the individual designs.
    
    Nothing will happen when the design is not selected, since all its FFs will its reset signal asserted.

*/


/* 
    gpio_out & gpio_oeb signal multiplexing:

    If design_1 is selected, pass its gpio_out & gpio_oeb outputs. 
    If design_2 is selected, pass its gpio_out & gpio_oeb outputs. 
    ....
    Up to design_12. 


    * NOTE: 

      ALL THE GPIO PINS WILL BE CONFIGURED TO BE INOUT, SO MAKE SURE TO ASSIGN GPIO_OEB VALUES_CORRECTLY. 
      
      IF THERE ARE ANY GPIO PINS THAT ARE NOT USED, YOU CAN SET THEM AS INPUTS BY SETTING "gpio_oeb = 1'b1" SINCE
      THEY ARE ACTIVE LOW. 
      
      FOR THE CORRESPONDING "gpio_out" PORT, YOU CAN JUST SET IT TO 1'b0. 

    *

*/

    // in the case where the design_select value does not correspond to a particular design, set all IOs to be inputs and set gpio_out to be all 0s 
    assign gpio_out = (design_select > 4'd0 && design_select < 4'd13) ? designs_gpio_out[design_select] : 'b0; 
    assign gpio_oeb = (design_select > 4'd0 && design_select < 4'd13) ? designs_gpio_oeb[design_select] : 'b1; 



/* chip select logic */

// assign designs_cs[0] = !(design_select == 0);
assign designs_cs[1] = !(design_select == 4'd1);
assign designs_cs[2] = !(design_select == 4'd2);
assign designs_cs[3] = !(design_select == 4'd3);
assign designs_cs[4] = !(design_select == 4'd4);
assign designs_cs[5] = !(design_select == 4'd5);
assign designs_cs[6] = !(design_select == 4'd6);
assign designs_cs[7] = !(design_select == 4'd7);
assign designs_cs[8] = !(design_select == 4'd8);
assign designs_cs[9] = !(design_select == 4'd9);
assign designs_cs[10] = !(design_select == 4'd10);
assign designs_cs[11] = !(design_select == 4'd11);
assign designs_cs[12] = !(design_select == 4'd12);

// always @ (*) begin
//     designs_cs = {12{1'b1}}; // default is off 

//     if(design_select > 4'd0 && design_select < 4'd13) begin
//         designs_cs[design_select] = 1'b0; // turn on the selected design
//     end 
// end


/* design reset logic */

reset_router design_reset (
    .clk(clk),
    .n_rst(n_rst),
    .designs_cs(designs_cs),
    .designs_n_rst(designs_n_rst)
);


/* 
Find your team's design and uncomment it here.

!!!!!!DO THIS FIRST!!!!!!
Update your wrapper module to correctly map the pins according to the spreadsheet

Then you can uncomment and make sure the module name matches
*/

Absentees_Wrapper design_1
(
    .clk(clk),
    .n_rst(designs_n_rst[1]),
    .ncs(designs_cs[1]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[1]), 
    .gpio_oeb(designs_gpio_oeb[1])
);

DigiDoggs_Wrapper design_2
(
    .clk(clk),
    .n_rst(designs_n_rst[2]),
    .ncs(designs_cs[2]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[2]), 
    .gpio_oeb(designs_gpio_oeb[2])
);

EightyTwos_Wrapper design_3
(
    .clk(clk),
    .n_rst(designs_n_rst[3]),
    .ncs(designs_cs[3]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[3]), 
    .gpio_oeb(designs_gpio_oeb[3])
);

Geriatrics_Wrapper design_4
(
    .clk(clk),
    .n_rst(designs_n_rst[4]),
    .ncs(designs_cs[4]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[4]), 
    .gpio_oeb(designs_gpio_oeb[4])
);
    
GuitarVillains_wrapper design_5
(
    .clk(clk),
    .n_rst(designs_n_rst[5]),
    .ncs(designs_cs[5]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[5]), 
    .gpio_oeb(designs_gpio_oeb[5])
);

MatrixMonSTARS_Wrapper design_6
(
    .clk(clk),
    .n_rst(designs_n_rst[6]),
    .ncs(designs_cs[6]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[6]), 
    .gpio_oeb(designs_gpio_oeb[6])
);

Outel_Wrapper design_7
(
    .clk(clk),
    .n_rst(designs_n_rst[7]),
    .ncs(designs_cs[7]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[7]), 
    .gpio_oeb(designs_gpio_oeb[7])
);

SaSS_wrapper design_8
(
    .clk(clk),
    .n_rst(designs_n_rst[8]),
    .ncs(designs_cs[8]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[8]), 
    .gpio_oeb(designs_gpio_oeb[8])
);

silly_synth_wrapper design_9
(
    .clk(clk),
    .n_rst(designs_n_rst[9]),
    .ncs(designs_cs[9]),

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[9]),
    .gpio_oeb(designs_gpio_oeb[9])
);

SyntheSTARS_Wrapper design_10
(
    .clk(clk),
    .n_rst(designs_n_rst[10]),
    .ncs(designs_cs[10]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[10]), 
    .gpio_oeb(designs_gpio_oeb[10])
);

SynthSurgeons_Wrapper design_11
(
    .clk(clk),
    .n_rst(designs_n_rst[11]),
    .ncs(designs_cs[11]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[11]), 
    .gpio_oeb(designs_gpio_oeb[11])
);

TMNT_Wrapper design_12
(
    .clk(clk),
    .n_rst(designs_n_rst[12]),
    .ncs(designs_cs[12]), 

    .gpio_in(gpio_in),
    .gpio_out(designs_gpio_out[12]), 
    .gpio_oeb(designs_gpio_oeb[12])
);
    
endmodule
