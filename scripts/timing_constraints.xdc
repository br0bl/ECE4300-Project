
# ECE 4300 - Timing Constraints
# 100 MHz target clock

create_clock -name sys_clk -period 10.000 [get_ports clk]

# Assumed input arrival delay: 1 ns
set_input_delay 1.000 -clock sys_clk \
    [get_ports -filter {DIRECTION == IN && NAME != clk}]

# Assumed output delay: 1 ns
set_output_delay 1.000 -clock sys_clk \
    [get_ports -filter {DIRECTION == OUT}]
