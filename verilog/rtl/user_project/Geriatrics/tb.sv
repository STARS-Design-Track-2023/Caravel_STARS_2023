`default_nettype none
`define NUM_TESTS 9

module tb();
    integer tests_complete;
    alu_tb alu_tb();
    instruction_decoder_tb id_tb();
    instruction_register_tb ir_tb();
    register_file_tb rf_tb();
    program_counter_tb pc_tb();
    control_unit_tb cu_tb();
    memory_controller_tb mc_tb();
    read_write_tb rw_tb();
    z23_tb z23_tb();

    assign tests_complete = alu_tb.tb_done +
        id_tb.tb_done +
        ir_tb.tb_done +
        rf_tb.tb_done +
        pc_tb.tb_done +
        cu_tb.tb_done +
        mc_tb.tb_done +
        rw_tb.tb_done +
        z23_tb.tb_done;

    initial begin
        wait(tests_complete == `NUM_TESTS);
        $finish;
    end
endmodule
