###############################################################################
# Created by write_sdc
# Thu Sep  7 14:57:33 2023
###############################################################################
current_design pushing_pixels
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 100.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {cs}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {nrst}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {spi_clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {spi_data}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {spi_en}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[0]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[10]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[11]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[12]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[13]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[14]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[15]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[16]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[17]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[18]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[19]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[1]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[20]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[21]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[22]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[23]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[2]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[3]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[4]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[5]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[6]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[7]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[8]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {color[9]}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {is_mandelbrot}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {valid_out}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {is_mandelbrot}]
set_load -pin_load 0.0334 [get_ports {valid_out}]
set_load -pin_load 0.0334 [get_ports {color[23]}]
set_load -pin_load 0.0334 [get_ports {color[22]}]
set_load -pin_load 0.0334 [get_ports {color[21]}]
set_load -pin_load 0.0334 [get_ports {color[20]}]
set_load -pin_load 0.0334 [get_ports {color[19]}]
set_load -pin_load 0.0334 [get_ports {color[18]}]
set_load -pin_load 0.0334 [get_ports {color[17]}]
set_load -pin_load 0.0334 [get_ports {color[16]}]
set_load -pin_load 0.0334 [get_ports {color[15]}]
set_load -pin_load 0.0334 [get_ports {color[14]}]
set_load -pin_load 0.0334 [get_ports {color[13]}]
set_load -pin_load 0.0334 [get_ports {color[12]}]
set_load -pin_load 0.0334 [get_ports {color[11]}]
set_load -pin_load 0.0334 [get_ports {color[10]}]
set_load -pin_load 0.0334 [get_ports {color[9]}]
set_load -pin_load 0.0334 [get_ports {color[8]}]
set_load -pin_load 0.0334 [get_ports {color[7]}]
set_load -pin_load 0.0334 [get_ports {color[6]}]
set_load -pin_load 0.0334 [get_ports {color[5]}]
set_load -pin_load 0.0334 [get_ports {color[4]}]
set_load -pin_load 0.0334 [get_ports {color[3]}]
set_load -pin_load 0.0334 [get_ports {color[2]}]
set_load -pin_load 0.0334 [get_ports {color[1]}]
set_load -pin_load 0.0334 [get_ports {color[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cs}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {nrst}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {spi_clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {spi_data}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {spi_en}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 10.0000 [current_design]
