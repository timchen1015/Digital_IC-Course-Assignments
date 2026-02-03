set cycle 22.0
create_clock -name clk -period $cycle [get_ports clk]
set_input_delay 1 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1 -clock clk [all_outputs]