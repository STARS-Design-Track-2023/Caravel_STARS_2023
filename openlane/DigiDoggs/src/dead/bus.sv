`define SPI_IN_BUS_PORT 0
`define SPI_OUT_BUS_PORT 1
`define RAM_BUS_PORT 2
`define MANDLEBROT_BUS_PORT 3
`define NUM_OF_MODULES 2
`define BUS_WIDTH 16

/*
Bus 

Parameter: 
    MODULES
    WIDTH 

Inputs:
    [$clog2(MODULES):0] Write select
    [WIDTH-1:0] data coming from modules (bus inputs) [MODULES-1:0]

Outputs: 
    [WIDTH-1:0] data going to modules (bus outputs) [MODULES-1:0]
*/

module bus(
    input logic [$clog2(MODULES):0] write_select,
    input logic [WIDTH-1:0] data_from_modules [MODULES-1:0],
    output logic [WIDTH-1:0] data_to_modules [MODULES-1:0]
);
    generate
        for (genvar i = 0; i < MODULES; i = i + 1) begin
            assign data_to_modules[i] = data_from_modules[write_select];
        end
    endgenerate
endmodule



/*
TOP MODULE STUFF:

logic [BUS_WIDTH - 1:0] bus inputs top [NUM_OF_MODULES - 1:0]
logic [BUS_WIDTH - 1:0] bus outputs top [NUM_OF_MODULES - 1:0]
logic [$clog2(NUM_OF_MODULES):0] Write select

bus #(.WIDTH(BUS_WIDTH), .MODULES(NUM_OF_MODULES)) data_bus (
    .Write select(Write select)
    .bus inputs (bus inputs top)
    .bus outputs (bus outputs top)
);

assign bus inputs top [SPI_IN_BUS_PORT] = spi in data
assign bus outputs top [SPI_OUT_BUS_PORT] = spi out data in
*/