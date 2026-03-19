import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # active-low reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Biraz çalışsın
    await ClockCycles(dut.clk, 50)

    out_str = str(dut.uo_out.value).lower()
    assert "x" not in out_str, f"uo_out has unknown bits: {dut.uo_out.value}"
    assert "z" not in out_str, f"uo_out has high-Z bits: {dut.uo_out.value}"
