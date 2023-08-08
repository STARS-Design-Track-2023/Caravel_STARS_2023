`default_nettype none

// 200Hz
`define TIMER_DURATION_MAX 50000

// Size of IO registers in bytes
`define GPIO_CONTROL_SIZE 8
`define GPIO_ACCESS_SIZE 8
`define SS_ACCESS_SIZE 8
// ih0, ih1, enable
`define INPUT_HANDLER_ACCESS_SIZE 3
`define GPIO_INTERRUPT_MASK_SIZE 1
// enable, duration0, duration1, duration2, duration4
`define TIMER_SIZE 5

`define GPIO_CONTROL_START_ADDR (MMIO_START_ADDR + {8'b0, GPIO_CONTROL_OFFSET})
`define GPIO_CONTROL_END_ADDR (`GPIO_CONTROL_START_ADDR + `GPIO_CONTROL_SIZE - 1)
`define GPIO_ACCESS_START_ADDR (MMIO_START_ADDR + {8'b0, GPIO_ACCESS_OFFSET})
`define GPIO_ACCESS_END_ADDR (`GPIO_ACCESS_START_ADDR + `GPIO_ACCESS_SIZE - 1)
`define SS_ACCESS_START_ADDR (MMIO_START_ADDR + {8'b0, SS_ACCESS_OFFSET})
`define SS_ACCESS_END_ADDR (`SS_ACCESS_START_ADDR + `SS_ACCESS_SIZE - 1)
`define INPUT_HANDLER_ACCESS_START_ADDR (MMIO_START_ADDR + {8'b0, INPUT_HANDLER_ACCESS_OFFSET})
`define INPUT_HANDLER_ACCESS_END_ADDR (`INPUT_HANDLER_ACCESS_START_ADDR + `INPUT_HANDLER_ACCESS_SIZE - 1)
`define GPIO_INTERRUPT_MASK_START_ADDR (MMIO_START_ADDR + {8'b0, GPIO_INTERRUPT_MASK_OFFSET})
`define GPIO_INTERRUPT_MASK_END_ADDR (`GPIO_INTERRUPT_MASK_START_ADDR + `GPIO_INTERRUPT_MASK_SIZE - 1)
`define TIMER_START_ADDR (MMIO_START_ADDR + {8'b0, TIMER_OFFSET})
`define TIMER_END_ADDR (`TIMER_START_ADDR + `TIMER_SIZE - 1)


module memory_controller#(parameter
    MMIO_START_ADDR=16'hff00,
    GPIO_CONTROL_OFFSET=8'h80,
    GPIO_ACCESS_OFFSET=8'h90,
    SS_ACCESS_OFFSET=8'ha0,
    INPUT_HANDLER_ACCESS_OFFSET=8'hb0,
    GPIO_INTERRUPT_MASK_OFFSET=8'hc0,
    TIMER_OFFSET=8'hd0
)(
    input logic mem_write_en, mem_read_en, dbl_byte_en, nrst, hwclk,
    input logic [7:0]  data_from_mem,
    input logic [15:0] data_in, address, input_handler,
    input logic [7:0] programmable_gpio_in,
    output logic wr, ack,
    output logic [7:0] data_to_mem,
    output logic [15:0] address_to_mem, data_output,
    output logic [7:0] programmable_gpio_wr,
    output logic [7:0] programmable_gpio_out,
    output logic [7:0] ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
    output logic [7:0] gpio_interrupt_pins, gpio_interrupt_mask,
    output logic timer_enable,
    output logic [31:0] timer_duration,
    output logic input_handler_enable
);
    logic cmp, enable, cmp_o;
    logic [3:0] max;
    logic next_count, count;
    logic [15:0] next_data;
    logic ack_t;
    logic [15:0] data_t;
    logic addr_is_input_handler, addr_is_gpio_control, addr_is_gpio_pin, addr_gpio_is_read, addr_is_ss, addr_is_gpio_interrupt_mask, addr_is_timer;
    logic [7:0] ss7_driver, ss6_driver, ss5_driver, ss4_driver, ss3_driver, ss2_driver, ss1_driver, ss0_driver;
    logic [7:0] programmable_gpio_out_driver;
    logic [7:0] gpio_interrupt_mask_driver;
    logic timer_enable_driver, ih_enable_driver;
    logic [31:0] timer_duration_driver;
    logic cmp_rising_edge;

    read_write rw(
        .clk(hwclk),
        .nrst (nrst),
        .mem_write_en(mem_write_en),
        .mem_read_en(mem_read_en),
        .dbl_byte_en(dbl_byte_en),
        .cmp(cmp),
        .data_in(data_in),
        .address(address),
        .enable(enable),
        .cmp_o(cmp_o),
        .wr(wr),
        .max(max),
        .data_to_mem(data_to_mem),
        .address_to_mem(address_to_mem),
        .ack(ack)
    );

    completion_control cc(
        .clk(hwclk),
        .nrst(nrst),
        .enable(enable),
        .max(max),
        .cmp(cmp)
    );


    completion_logic cl(
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .cmp_o(cmp_o),
        .next_data(next_data),
        .ack(ack_t),
        .data_output(data_t)
    );

    always_ff @(posedge hwclk, negedge nrst) begin
        if (~nrst) begin
            count <= 0;
            next_data <= 0;
        end else begin
            if (ack) begin
                next_data <= 16'b0;
                count <= 1'b0;
            end else begin
                count <= next_count;
                if (count==0) next_data[7:0] <= data_from_mem;
                else          next_data[15:8] <= data_from_mem;
            end
        end
    end

    always_comb begin
        if (cmp) next_count = count + 1;
        else next_count = count;
    end

    // Memory mapping
    always_comb begin
        addr_is_gpio_control = address >= `GPIO_CONTROL_START_ADDR && address <= `GPIO_CONTROL_END_ADDR;
        addr_is_gpio_pin = address >= `GPIO_ACCESS_START_ADDR && address <= `GPIO_ACCESS_END_ADDR;
        addr_is_ss = address >= `SS_ACCESS_START_ADDR && address <= `SS_ACCESS_END_ADDR;
        addr_is_input_handler = address >= `INPUT_HANDLER_ACCESS_START_ADDR && address <= `INPUT_HANDLER_ACCESS_END_ADDR;
        addr_is_gpio_interrupt_mask = address >= `GPIO_INTERRUPT_MASK_START_ADDR && address <= `GPIO_INTERRUPT_MASK_END_ADDR;
        addr_is_timer = address >= `TIMER_START_ADDR && address <= `TIMER_END_ADDR;
        addr_gpio_is_read = ~programmable_gpio_wr[address[2:0]];
    end

    // Drive memory mapped logic
    always_comb begin
        ss7_driver = ss7;
        ss6_driver = ss6;
        ss5_driver = ss5;
        ss4_driver = ss4;
        ss3_driver = ss3;
        ss2_driver = ss2;
        ss1_driver = ss1;
        ss0_driver = ss0;
        programmable_gpio_out_driver = programmable_gpio_out;
        gpio_interrupt_mask_driver = gpio_interrupt_mask;
        timer_enable_driver = timer_enable;
        timer_duration_driver = timer_duration;
        ih_enable_driver = input_handler_enable;
        data_output = 16'b0;
        if (addr_is_input_handler) begin
            if (mem_write_en) case (address[1:0])
                2'b10 : ih_enable_driver = data_in[0];
                default ;
            endcase else if (mem_read_en)
                if (dbl_byte_en && address[1:0] != 2'b10) data_output = {input_handler[15:8], input_handler[7:0]};
                else case (address[1:0])
                    2'b00 : data_output = {8'b0, input_handler[7:0]};
                    2'b01 : data_output = {8'b0, input_handler[15:8]};
                    2'b10 : data_output = {15'b0, input_handler_enable};
                    default : ;
                endcase
            ack = mem_read_en | mem_write_en;
        end else if (addr_is_gpio_control) begin
            if (mem_read_en) data_output = {8'b0, programmable_gpio_wr};
            ack = mem_read_en | mem_write_en;
        end else if (addr_is_gpio_pin) begin
            if (addr_gpio_is_read & mem_read_en) data_output = {15'b0, programmable_gpio_in[address[2:0]]};
            else if (~addr_gpio_is_read & mem_read_en) data_output = {15'b0, programmable_gpio_out_driver[address[2:0]]};
            else if (~addr_gpio_is_read) programmable_gpio_out_driver[address[2:0]] = data_in[0];
            ack = mem_read_en | mem_write_en;
        end else if (addr_is_ss) begin
            if (mem_write_en) case (address[2:0])
                3'b000 : ss0_driver = data_in[7:0];
                3'b001 : ss1_driver = data_in[7:0];
                3'b010 : ss2_driver = data_in[7:0];
                3'b011 : ss3_driver = data_in[7:0];
                3'b100 : ss4_driver = data_in[7:0];
                3'b101 : ss5_driver = data_in[7:0];
                3'b110 : ss6_driver = data_in[7:0];
                3'b111 : ss7_driver = data_in[7:0];
            endcase
            case (address[2:0])
                3'b000 : data_output = {8'b0, ss0};
                3'b001 : data_output = {8'b0, ss1};
                3'b010 : data_output = {8'b0, ss2};
                3'b011 : data_output = {8'b0, ss3};
                3'b100 : data_output = {8'b0, ss4};
                3'b101 : data_output = {8'b0, ss5};
                3'b110 : data_output = {8'b0, ss6};
                3'b111 : data_output = {8'b0, ss7};
            endcase
            ack = mem_read_en | mem_write_en;
        end else if (addr_is_gpio_interrupt_mask) begin
            if (mem_read_en) data_output = {8'b0, gpio_interrupt_mask};
            if (mem_write_en) gpio_interrupt_mask_driver = data_in[7:0];
            ack = mem_read_en | mem_write_en;
        end else if (addr_is_timer) begin
            if (mem_read_en) begin
                if (dbl_byte_en) case (address[2:0])
                    3'b000 : data_output = {15'b0, timer_enable};
                    3'b001 : data_output = timer_duration[15:0];
                    3'b010 : data_output = timer_duration[15:0];
                    3'b011 : data_output = timer_duration[31:16];
                    3'b100 : data_output = timer_duration[31:16];
                    default : ;
                endcase else case (address[3:0])
                    4'b0000 : data_output = {15'b0, timer_enable};
                    4'b0001 : data_output = {8'b0, timer_duration[7:0]};
                    4'b0010 : data_output = {8'b0, timer_duration[15:8]};
                    4'b0011 : data_output = {8'b0, timer_duration[23:16]};
                    4'b0100 : data_output = {8'b0, timer_duration[31:24]};
                    default : ;
                endcase
            end
            if (mem_write_en) begin
                if (dbl_byte_en) case (address[2:0])
                    3'b000 : timer_enable_driver = data_in[0];
                    3'b001 : timer_duration_driver[15:0] = data_in;
                    3'b010 : timer_duration_driver[15:0] = data_in;
                    3'b011 : timer_duration_driver[31:16] = data_in;
                    3'b100 : timer_duration_driver[31:16] = data_in;
                    default : ;
                endcase else case (address[2:0])
                    3'b000 : timer_enable_driver = data_in[0];
                    3'b001 : timer_duration_driver[7:0] = data_in[7:0];
                    3'b010 : timer_duration_driver[15:8] = data_in[7:0];
                    3'b011 : timer_duration_driver[23:16] = data_in[7:0];
                    3'b100 : timer_duration_driver[31:24] = data_in[7:0];
                    default : ;
                endcase
            end
            ack = mem_read_en | mem_write_en;
        end else begin
            ack = ack_t;
            data_output = data_t;
        end
    end

    // Drive GPIO interrupt pins
    always_comb begin
        gpio_interrupt_pins = programmable_gpio_in & ~programmable_gpio_wr;
    end

    always_ff @(posedge hwclk, negedge nrst) begin
        if (~nrst) begin
            programmable_gpio_wr <= 8'b0;
            programmable_gpio_out <= 8'b0;
            ss7 <= 8'b0;
            ss6 <= 8'b0;
            ss5 <= 8'b0;
            ss4 <= 8'b0;
            ss3 <= 8'b0;
            ss2 <= 8'b0;
            ss1 <= 8'b0;
            ss0 <= 8'b0;
            gpio_interrupt_mask <= 8'b0;
            timer_enable <= 1'b0;
            timer_duration <= `TIMER_DURATION_MAX;
            input_handler_enable <= 1'b0;
        end else begin
            if (addr_is_input_handler & mem_write_en)
                input_handler_enable <= ih_enable_driver;
            if (addr_is_gpio_control & mem_write_en)
                programmable_gpio_wr[address[2:0]] <= data_in[0];
            else if (addr_is_gpio_pin & mem_write_en)
                programmable_gpio_out <= programmable_gpio_out_driver;
            else if (addr_is_ss & mem_write_en)
                case (address[2:0])
                    3'b000 : ss0 <= ss0_driver;
                    3'b001 : ss1 <= ss1_driver;
                    3'b010 : ss2 <= ss2_driver;
                    3'b011 : ss3 <= ss3_driver;
                    3'b100 : ss4 <= ss4_driver;
                    3'b101 : ss5 <= ss5_driver;
                    3'b110 : ss6 <= ss6_driver;
                    3'b111 : ss7 <= ss7_driver;
                endcase
            else if (addr_is_gpio_interrupt_mask & mem_write_en)
                gpio_interrupt_mask <= gpio_interrupt_mask_driver;
            else if (addr_is_timer & mem_write_en) begin
                timer_enable <= timer_enable_driver;
                timer_duration <= timer_duration_driver;
            end
        end
    end
endmodule
