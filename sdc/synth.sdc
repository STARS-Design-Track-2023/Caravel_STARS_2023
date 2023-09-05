###############################################################################
# Created by write_sdc
# Tue Sep  5 16:37:52 2023
###############################################################################
current_design synth
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 100.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {en}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[0]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[10]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[11]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[12]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[13]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[14]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[1]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[2]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[3]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[4]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[5]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[6]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[7]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[8]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {keypad_i[9]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {n_rst}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {pwm_o}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {sound_series[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {sound_series[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {sound_series[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {sound_series[3]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {pwm_o}]
set_load -pin_load 0.0334 [get_ports {sound_series[3]}]
set_load -pin_load 0.0334 [get_ports {sound_series[2]}]
set_load -pin_load 0.0334 [get_ports {sound_series[1]}]
set_load -pin_load 0.0334 [get_ports {sound_series[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {en}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {n_rst}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[14]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[13]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[12]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[11]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[10]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {keypad_i[0]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 18.0000 [current_design]
