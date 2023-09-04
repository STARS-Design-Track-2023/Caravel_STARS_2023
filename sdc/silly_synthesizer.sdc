###############################################################################
# Created by write_sdc
# Mon Sep  4 19:16:27 2023
###############################################################################
current_design silly_synthesizer
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 100.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {cs}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[0]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[10]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[11]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[12]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[13]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[14]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[15]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[16]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[1]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[2]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[3]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[4]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[5]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[6]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[7]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[8]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio[9]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {nrst}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pwm}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {pwm}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cs}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {nrst}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[16]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[15]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[14]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[13]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[12]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[11]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[10]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {gpio[0]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 10.0000 [current_design]
