# FPGA MAC Accelerator – ECE 4300 Project

**Cal Poly Pomona – Computer Architecture**

**By Ben Robles and Christian Gomez**

## About the Project

For our ECE 4300 Computer Architecture project, we created a simple Multiply-Accumulate (MAC) accelerator using SystemVerilog.

The goal of this project is to compare how using multiple MAC units in parallel affects performance and FPGA resource usage.

We tested three different designs:
- **1 MAC:** Processes one multiplication at a time.
- **2 MACs:** Processes two multiplications at a time.
- **4 MACs:** Processes four multiplications at a time.

Each design processes 16 pairs of signed 8-bit numbers and accumulates the results.

## Tools Used

- SystemVerilog
- AMD Vivado
- Python
- Cocotb and Vivado XSim
- Nexys A7-100T FPGA (target board)

## Results

We used Python and simulations to verify that all three designs produced the correct results. We also used Vivado to compare FPGA resource usage and timing.

| Measurement | 1 MAC | 2 MACs | 4 MACs |
|---|---:|---:|---:|
| Clock cycles | 17 | 9 | 5 |
| LUTs | 175 | 295 | 453 |
| Flip-flops | 49 | 69 | 109 |
| DSP blocks | 0 | 0 | 0 |
| Setup slack (ns) | 0.379 | 0.506 | 0.586 |

All three designs passed simulation and met the 100 MHz timing target in our preliminary out-of-context Vivado analysis.

## What We Learned

Using more MAC units reduced the number of clock cycles needed to finish the same calculation, but required more FPGA resources.

The 4-MAC design completed the workload in 5 cycles compared to 17 cycles for the 1-MAC design, showing the trade-off between speed and hardware usage.

## Project Files

- `sources/` – SystemVerilog MAC and controller designs
- `simulation/` – Python, Cocotb, and Verilog testbenches
- `results/simulation/` – Simulation results
- `results/utilization/` – FPGA resource usage
- `results/timing/` – Vivado timing reports
- `scripts/` – Timing analysis scripts

**Note:** Timing results are preliminary estimates from Vivado, not measurements from running the physical FPGA board.