module memory_tb#(parameter FILE_NAME, TOP_OF_STACK, SIZE_OF_RAM=16'h2000, SIZE_OF_ROM=16'h2000)(
    input logic clk, nrst, wr,
    input logic [15:0] address,
    input logic [7:0] data_in,
    output logic [7:0] data_out
);
    logic [7:0] rom [SIZE_OF_ROM-1:0];
    logic [7:0] ram [SIZE_OF_RAM-1:0];
    logic addr_is_rom;
    logic addr_is_ram;
    logic [15:0] ram_corrected_addr;
    integer fd;

    initial begin
        integer num_read;
        fd = $fopen(FILE_NAME, "rb");
        num_read = $fread(rom, fd);
        $display("num_read: %d", num_read);
        $fclose(fd);
    end

    assign addr_is_rom = address < SIZE_OF_ROM;
    assign addr_is_ram = address >= TOP_OF_STACK - SIZE_OF_RAM & address < TOP_OF_STACK;
    assign ram_corrected_addr = address - TOP_OF_STACK + SIZE_OF_RAM;

    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin
            for (int i = 0; i < 16'h2000; i++)
                ram[i] <= 8'b0;
        end else begin
            if (wr & addr_is_ram) begin
                ram[ram_corrected_addr] <= data_in;
            end else begin
                if (addr_is_rom) data_out <= rom[address];
                else if (addr_is_ram) data_out <= ram[ram_corrected_addr];
                else data_out <= 16'hzzzz;
            end
        end
    end
endmodule
