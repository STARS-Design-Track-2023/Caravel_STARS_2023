###############################################################################
# Created by write_sdc
# Sat Sep  9 18:28:18 2023
###############################################################################
current_design reducedMacroMain
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 100.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[0]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[1]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[2]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[3]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[4]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[5]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[6]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[7]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[8]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {in[9]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {nrst}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[10]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[11]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[12]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[13]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[4]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[5]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[6]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[7]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[8]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {out[9]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {out[13]}]
set_load -pin_load 0.0334 [get_ports {out[12]}]
set_load -pin_load 0.0334 [get_ports {out[11]}]
set_load -pin_load 0.0334 [get_ports {out[10]}]
set_load -pin_load 0.0334 [get_ports {out[9]}]
set_load -pin_load 0.0334 [get_ports {out[8]}]
set_load -pin_load 0.0334 [get_ports {out[7]}]
set_load -pin_load 0.0334 [get_ports {out[6]}]
set_load -pin_load 0.0334 [get_ports {out[5]}]
set_load -pin_load 0.0334 [get_ports {out[4]}]
set_load -pin_load 0.0334 [get_ports {out[3]}]
set_load -pin_load 0.0334 [get_ports {out[2]}]
set_load -pin_load 0.0334 [get_ports {out[1]}]
set_load -pin_load 0.0334 [get_ports {out[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {nrst}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {in[0]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 20.0000 [current_design]
