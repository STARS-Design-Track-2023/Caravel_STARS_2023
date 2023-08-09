###############################################################################
# Created by write_sdc
# Wed Aug  9 02:51:37 2023
###############################################################################
current_design stopwatch
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 100.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {nrst}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb_0}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb_1}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_0[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_0[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_0[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_0[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_0[4]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_0[5]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_0[6]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_1[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_1[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_1[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_1[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_1[4]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_1[5]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_1[6]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_2[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_2[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_2[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_2[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_2[4]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_2[5]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_2[6]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_3[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_3[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_3[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_3[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_3[4]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_3[5]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out_3[6]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {time_done}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {time_done}]
set_load -pin_load 0.0334 [get_ports {out_0[6]}]
set_load -pin_load 0.0334 [get_ports {out_0[5]}]
set_load -pin_load 0.0334 [get_ports {out_0[4]}]
set_load -pin_load 0.0334 [get_ports {out_0[3]}]
set_load -pin_load 0.0334 [get_ports {out_0[2]}]
set_load -pin_load 0.0334 [get_ports {out_0[1]}]
set_load -pin_load 0.0334 [get_ports {out_0[0]}]
set_load -pin_load 0.0334 [get_ports {out_1[6]}]
set_load -pin_load 0.0334 [get_ports {out_1[5]}]
set_load -pin_load 0.0334 [get_ports {out_1[4]}]
set_load -pin_load 0.0334 [get_ports {out_1[3]}]
set_load -pin_load 0.0334 [get_ports {out_1[2]}]
set_load -pin_load 0.0334 [get_ports {out_1[1]}]
set_load -pin_load 0.0334 [get_ports {out_1[0]}]
set_load -pin_load 0.0334 [get_ports {out_2[6]}]
set_load -pin_load 0.0334 [get_ports {out_2[5]}]
set_load -pin_load 0.0334 [get_ports {out_2[4]}]
set_load -pin_load 0.0334 [get_ports {out_2[3]}]
set_load -pin_load 0.0334 [get_ports {out_2[2]}]
set_load -pin_load 0.0334 [get_ports {out_2[1]}]
set_load -pin_load 0.0334 [get_ports {out_2[0]}]
set_load -pin_load 0.0334 [get_ports {out_3[6]}]
set_load -pin_load 0.0334 [get_ports {out_3[5]}]
set_load -pin_load 0.0334 [get_ports {out_3[4]}]
set_load -pin_load 0.0334 [get_ports {out_3[3]}]
set_load -pin_load 0.0334 [get_ports {out_3[2]}]
set_load -pin_load 0.0334 [get_ports {out_3[1]}]
set_load -pin_load 0.0334 [get_ports {out_3[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {nrst}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb_0}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb_1}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 20.0000 [current_design]
