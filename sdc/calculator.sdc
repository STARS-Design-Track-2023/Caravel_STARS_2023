###############################################################################
# Created by write_sdc
# Mon Sep  4 18:58:24 2023
###############################################################################
current_design calculator
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 100.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {nrst}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[0]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[1]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[2]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[3]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[4]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[5]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[6]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[7]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[8]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pb[9]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {blue}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {red}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[10]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[11]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[12]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[13]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[4]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[5]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[6]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[7]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[8]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {ss[9]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {blue}]
set_load -pin_load 0.0334 [get_ports {red}]
set_load -pin_load 0.0334 [get_ports {ss[13]}]
set_load -pin_load 0.0334 [get_ports {ss[12]}]
set_load -pin_load 0.0334 [get_ports {ss[11]}]
set_load -pin_load 0.0334 [get_ports {ss[10]}]
set_load -pin_load 0.0334 [get_ports {ss[9]}]
set_load -pin_load 0.0334 [get_ports {ss[8]}]
set_load -pin_load 0.0334 [get_ports {ss[7]}]
set_load -pin_load 0.0334 [get_ports {ss[6]}]
set_load -pin_load 0.0334 [get_ports {ss[5]}]
set_load -pin_load 0.0334 [get_ports {ss[4]}]
set_load -pin_load 0.0334 [get_ports {ss[3]}]
set_load -pin_load 0.0334 [get_ports {ss[2]}]
set_load -pin_load 0.0334 [get_ports {ss[1]}]
set_load -pin_load 0.0334 [get_ports {ss[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {nrst}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {pb[0]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 20.0000 [current_design]
