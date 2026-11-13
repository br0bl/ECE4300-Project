
# FPGA MAC Timing Analysis

## Overview
Post-route timing analysis of the 1-MAC, 2-MAC, and 4-MAC architectures targeting the Nexys A7-100T.

## Tools
- Vivado 2025.1
- FPGA: xc7a100tcsg324-1
- Target clock: 100 MHz (10 ns)
- Implementation: Out-of-context (OOC)

## Timing Results

| MACs | Setup Slack (ns) | Hold Slack (ns) | Critical Data Path (ns) |
|------|------------------|-----------------|-------------------------|
| 1    | 0.379            | 0.163           | 9.599                   |
| 2    | 0.506            | 0.229           | 9.472                   |
| 4    | 0.586            | 0.215           | 9.392                   |

All three configurations met the 10 ns timing target in the reported OOC analysis, with zero setup and hold violations.

## Simulation Latency

The measured simulation latencies are:

- 1 MAC: 17 cycles
- 2 MACs: 9 cycles
- 4 MACs: 5 cycles

These include one controller completion cycle beyond the ideal accumulation cycle counts.

## Methodology
Vivado was used to synthesize, optimize, place, and route each architecture with identical clock and interface-delay assumptions.

The run_timing.tcl script selects NUM_MACS = 1, 2, or 4 through the `n` variable.

## Limitations
The design was implemented out of context. Clock-source and boundary-routing information were incomplete (including HD.CLK_SRC and HD.PARTPIN_LOCS warnings).

Consequently, these reports are preliminary OOC timing benchmarks, not board-level timing signoff or validated maximum clock-frequency measurements.

No physical FPGA timing measurements were performed.
