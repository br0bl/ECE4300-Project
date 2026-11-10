import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly

import mac_reference

VECTORS = mac_reference.make_vectors(signed=True, n_random=1000, seed=1234)
EDGE_VECTORS = {name: (a, b) for name, a, b in VECTORS if not name.startswith("rand_")}

async def reset_dut(dut):
    await FallingEdge(dut.clk)
    dut.start.value = 0
    dut.rst.value = 1

    for i in range(16):
        dut.a[i].value = 0
        dut.b[i].value = 0

    await FallingEdge(dut.clk)
    dut.rst.value = 0

async def run_vector(dut, name, a, b):
    await FallingEdge(dut.clk)

    num_macs = int(dut.NUM_MACS.value)
    expected_cycles = 16 // num_macs + 1

    for i in range(16):
        dut.a[i].value = a[i]
        dut.b[i].value = b[i]
    dut.start.value = 1

    await FallingEdge(dut.clk)
    dut.start.value = 0

    for cycles in range(1, 25):
        await RisingEdge(dut.clk)
        await ReadOnly()
        if dut.done.value == 1:
            assert cycles == expected_cycles, (f"{name}: expected latency {expected_cycles}, got {cycles}")
            return dut.result.value.to_signed()

    raise AssertionError(f"{name}: timed out waiting for done")

@cocotb.test()
async def test_reset(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start(start_high=False))

    await FallingEdge(dut.clk)
    dut.start.value = 0
    dut.rst.value = 1
    for i in range(16):
        dut.a[i].value = 0
        dut.b[i].value = 0

    for _ in range(4):
        await FallingEdge(dut.clk)      # a rising edge with rst=1 has passed
        assert dut.done.value == 0, f"done={dut.done.value} during reset"
        assert dut.result.value == 0, f"result={dut.result.value} during reset"

    dut.rst.value = 0

@cocotb.test()
async def test_reset_mid_operation(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start(start_high=False))
    await reset_dut(dut)

    name, a, b = VECTORS[100]
    expected = mac_reference.golden(a, b)

    await FallingEdge(dut.clk)
    for i in range(16):
        dut.a[i].value = a[i]
        dut.b[i].value = b[i]
    dut.start.value = 1
    await FallingEdge(dut.clk)
    dut.start.value = 0

    await FallingEdge(dut.clk)
    assert dut.done.value == 0, "operation finished before reset; test is not mid-operation"

    dut.rst.value = 1
    await FallingEdge(dut.clk)
    assert dut.done.value == 0, f"done={dut.done.value} after reset"
    assert dut.result.value == 0, f"result={dut.result.value} after reset"
    dut.rst.value = 0

    actual = await run_vector(dut, name, a, b)
    assert actual == expected, f"{name}: expected {expected}, got {actual}"

@cocotb.parametrize(vec_name=list(EDGE_VECTORS))
@cocotb.test()
async def test_mac_edge_cases(dut, vec_name):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start(start_high=False))

    a, b = EDGE_VECTORS[vec_name]
    expected = mac_reference.golden(a, b)

    await reset_dut(dut)
    actual = await run_vector(dut, vec_name, a, b)

    assert actual == expected, f"{vec_name}: expected {expected}, got {actual}"

@cocotb.test()
async def test_mac_regression(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start(start_high=False))
    await reset_dut(dut)          

    failures = []
    for name, a, b in VECTORS:
        expected = mac_reference.golden(a, b)
        actual = await run_vector(dut, name, a, b)

        if actual != expected:
            failures.append(f"{name}: expected {expected}, got {actual}")

    for f in failures:
        dut._log.error(f)
    assert not failures, f"{len(failures)}/{len(VECTORS)} vectors failed"

    num_macs = int(dut.NUM_MACS.value)
    expected_cycles = 16 // num_macs + 1

    dut._log.info("%d MAC(s): all vectors passed with expected latency of %d cycles", num_macs, expected_cycles)