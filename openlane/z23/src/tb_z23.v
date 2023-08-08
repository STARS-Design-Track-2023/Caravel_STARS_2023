`default_nettype none
module memory_tb (
	clk,
	nrst,
	wr,
	address,
	data_in,
	data_out
);
	parameter FILE_NAME = 0;
	parameter TOP_OF_STACK = 0;
	parameter SIZE_OF_RAM = 16'h2000;
	parameter SIZE_OF_ROM = 16'h2000;
	input wire clk;
	input wire nrst;
	input wire wr;
	input wire [15:0] address;
	input wire [7:0] data_in;
	output reg [7:0] data_out;
	reg [7:0] rom [SIZE_OF_ROM - 1:0];
	reg [7:0] ram [SIZE_OF_RAM - 1:0];
	wire addr_is_rom;
	wire addr_is_ram;
	wire [15:0] ram_corrected_addr;
	integer fd;
	initial begin : sv2v_autoblock_1
		integer num_read;
		fd = $fopen(FILE_NAME, "rb");
		num_read = $fread(rom[SIZE_OF_ROM - 1:0], fd);
		$display("num_read: %d", num_read);
		$fclose(fd);
	end
	assign addr_is_rom = address < SIZE_OF_ROM;
	assign addr_is_ram = (address >= (TOP_OF_STACK - SIZE_OF_RAM)) & (address < TOP_OF_STACK);
	assign ram_corrected_addr = (address - TOP_OF_STACK) + SIZE_OF_RAM;
	always @(posedge clk or negedge nrst)
		if (~nrst) begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 16'h2000; i = i + 1)
				ram[i] <= 8'b00000000;
		end
		else if (wr & addr_is_ram)
			ram[ram_corrected_addr] <= data_in;
		else if (addr_is_rom)
			data_out <= rom[address];
		else if (addr_is_ram)
			data_out <= ram[ram_corrected_addr];
		else
			data_out <= 16'hzzzz;
endmodule
module z23_tb;
	parameter CLK_PERIOD = 100;
	wire signed [31:0] tb_fd;
	integer tb_done;
	integer tb_check;
	integer tb_mismatch;
	integer tb_asm_test_sel;
	reg tb_clk;
	reg tb_nrst;
	reg [7:0] tb_memory_data_in;
	wire [7:0] tb_programmable_gpio_in;
	wire tb_interrupt_gpio_in;
	wire [15:0] tb_keypad_input;
	wire [15:0] tb_memory_address_out;
	wire [7:0] tb_memory_data_out;
	wire [7:0] tb_programmable_gpio_out;
	wire tb_memory_wr;
	wire [7:0] tb_programmable_gpio_wr;
	wire [7:0] tb_ss7;
	wire [7:0] tb_ss6;
	wire [7:0] tb_ss5;
	wire [7:0] tb_ss4;
	wire [7:0] tb_ss3;
	wire [7:0] tb_ss2;
	wire [7:0] tb_ss1;
	wire [7:0] tb_ss0;
	wire [7:0] tb_asm_test_0_data_out;
	memory_tb #(
		.FILE_NAME("sim_build/a_should_be_0x70.bin"),
		.TOP_OF_STACK(16'hff00)
	) asm_test_0_dut(
		.clk(tb_clk),
		.nrst(tb_nrst),
		.wr(tb_memory_wr),
		.address(tb_memory_address_out),
		.data_in(tb_memory_data_out),
		.data_out(tb_asm_test_0_data_out)
	);
	wire [7:0] tb_asm_test_1_data_out;
	memory_tb #(
		.FILE_NAME("sim_build/multiply_example.bin"),
		.TOP_OF_STACK(16'hff00)
	) asm_test_1_dut(
		.clk(tb_clk),
		.nrst(tb_nrst),
		.wr(tb_memory_wr),
		.address(tb_memory_address_out),
		.data_in(tb_memory_data_out),
		.data_out(tb_asm_test_1_data_out)
	);
	z23 DUT(
		.clk(tb_clk),
		.nrst(tb_nrst),
		.memory_data_in(tb_memory_data_in),
		.programmable_gpio_in(tb_programmable_gpio_in),
		.keypad_input(tb_keypad_input),
		.memory_address_out(tb_memory_address_out),
		.memory_data_out(tb_memory_data_out),
		.programmable_gpio_out(tb_programmable_gpio_out),
		.memory_wr(tb_memory_wr),
		.programmable_gpio_wr(tb_programmable_gpio_wr),
		.ss7(tb_ss7),
		.ss6(tb_ss6),
		.ss5(tb_ss5),
		.ss4(tb_ss4),
		.ss3(tb_ss3),
		.ss2(tb_ss2),
		.ss1(tb_ss1),
		.ss0(tb_ss0)
	);
	task reset_dut;
		begin
			tb_nrst = 1'b0;
			@(posedge tb_clk)
				;
			@(posedge tb_clk)
				;
			@(negedge tb_clk)
				;
			tb_nrst = 1;
		end
	endtask
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars;
	end
	always begin : CLK_GEN
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2)
			;
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2)
			;
	end
	always begin
		case (tb_asm_test_sel)
			0: tb_memory_data_in = tb_asm_test_0_data_out;
			1: tb_memory_data_in = tb_asm_test_1_data_out;
			default: tb_memory_data_in = tb_asm_test_0_data_out;
		endcase
		#(0.1)
			;
	end
	initial begin
		reset_dut;
		tb_asm_test_sel = 0;
		#(CLK_PERIOD * 23);
		reset_dut;
		tb_asm_test_sel = 1;
		#(CLK_PERIOD * 200);
		tb_done = 1;
		$finish;
	end
endmodule
