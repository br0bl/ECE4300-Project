# MACcelerator Simulation Summary

**Result: All 30 cocotb tests passed across the 1-, 2-, and 4-MAC configurations. No failures or skipped tests.**

## Verification

Each configuration passed:

- **Reset:** `done` and `result` remain zero during reset.
- **Reset during operation:** an active operation can be interrupted, followed by a correct new operation.
- **Directed edge cases:** seven individually reported cases passed.
- **Regression:** all reference vectors passed result comparisons and expected-latency checks during consecutive operations.

The four test functions expand to **10 reported tests per configuration** because the edge-case test runs seven times.

## Latency

Latency is measured from the rising edge that accepts `start` to the rising edge that asserts `done`:

```text
Latency = (16 / NUM_MACS) + 1 clock cycles
```

## Final Results

| MACs | Tests passed | Failed | Skipped | Accumulation cycles | Verified latency (cycles) | Latency at 100 MHz |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 10/10 | 0 | 0 | 16 | 17 | 170 ns |
| 2 | 10/10 | 0 | 0 | 8 | 9 | 90 ns |
| 4 | 10/10 | 0 | 0 | 4 | 5 | 50 ns |

