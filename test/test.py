import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def test_alu(dut):
    dut._log.info("Starting ALU Test")

    # 1. Generate a 50 MHz clock (20ns period)
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # 2. Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0 # Opcode 000 (ADD)
    dut.rst_n.value = 0  # Assert reset

    # 3. Apply reset
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1  # Release reset
    await ClockCycles(dut.clk, 2)
    dut._log.info("Reset complete")

    # 4. Test LOAD (Opcode 101 / 5)
    dut._log.info("Testing LOAD operation")
    dut.uio_in.value = 5      # Opcode = LOAD
    dut.ui_in.value = 10      # Data = 10
    await ClockCycles(dut.clk, 1)
    assert int(dut.uo_out.value) == 10, f"Expected 10, got {int(dut.uo_out.value)}"

    # 5. Test ADD (Opcode 000 / 0)
    dut._log.info("Testing ADD operation")
    dut.uio_in.value = 0      # Opcode = ADD
    dut.ui_in.value = 15      # Data = 15
    await ClockCycles(dut.clk, 1)
    assert int(dut.uo_out.value) == 25, f"Expected 25, got {int(dut.uo_out.value)}"

    # 6. Test SUB (Opcode 001 / 1)
    dut._log.info("Testing SUB operation")
    dut.uio_in.value = 1      # Opcode = SUB
    dut.ui_in.value = 5       # Data = 5
    await ClockCycles(dut.clk, 1)
    assert int(dut.uo_out.value) == 20, f"Expected 20, got {int(dut.uo_out.value)}"

    dut._log.info("All tests passed successfully!")
