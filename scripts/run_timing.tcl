
# ECE 4300 - 1 MAC FPGA Timing Analysis
# Target: Nexys A7-100T (Artix-7)

set n 4
set part xc7a100tcsg324-1

# Locate project root
set root [file normalize [file join [file dirname [info script]] ..]]

set results "$root/results/timing"
set build "$root/build/timing_${n}mac"

file mkdir $results
file mkdir $build

puts "====================================="
puts "Starting $n MAC timing analysis"
puts "====================================="

# Load RTL source files
read_verilog -sv [list \
    "$root/sources/mac.sv" \
    "$root/sources/controller.sv" \
]

# Synthesize MAC core without physical I/O buffers
synth_design \
    -top controller \
    -part $part \
    -generic NUM_MACS=$n \
    -mode out_of_context

# Apply timing constraints
read_xdc "$root/scripts/timing_constraints.xdc"

# Save synthesis checkpoint
write_checkpoint -force "$build/post_synth.dcp"

# FPGA implementation
opt_design
place_design
route_design

# Generate timing reports
check_timing -verbose \
    -file "$results/check_timing_${n}mac.rpt"

report_timing_summary \
    -delay_type min_max \
    -file "$results/timing_${n}mac.rpt"

report_timing \
    -delay_type max \
    -max_paths 10 \
    -file "$results/critical_paths_${n}mac.rpt"

report_utilization \
    -file "$results/utilization_impl_${n}mac.rpt"

# Save implemented design
write_checkpoint -force "$build/post_route.dcp"

puts "====================================="
puts "Completed $n MAC timing analysis"
puts "====================================="
