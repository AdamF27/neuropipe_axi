import random

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer

@cocotb.test()
async def test_master(dut):
    cocotb.start_soon(Clock(dut.clk_i, 10, units='ns').start())
    await reset_dut(dut)
    addr0 = 0b0001
    data0 = 0xABABABAB
    await write_inst(dut, addr0, data0)

    for _ in range(5):
        await RisingEdge(dut.clk_i)

    dut.axil_awready.value = 1
    await RisingEdge(dut.clk_i)
    dut.axil_awready.value = 0
    await RisingEdge(dut.clk_i)
    assert dut.axil_awvalid.value == 0

    for _ in range(3):
        await RisingEdge(dut.clk_i)

    dut.axil_wready.value = 1
    await RisingEdge(dut.clk_i)
    dut.axil_wready.value = 0
    await RisingEdge(dut.clk_i)
    assert dut.axil_wready.value == 0

    for _ in range(3):
        await RisingEdge(dut.clk_i)

    dut.axil_bvalid.value = 1
    await RisingEdge(dut.clk_i)
    dut.axil_bvalid.value = 0
    await RisingEdge(dut.clk_i)
    assert dut.axil_bready.value == 0

    for _ in range(3):
        await RisingEdge(dut.clk_i)

async def write_inst(dut, addr, data):
    dut.inst_i.value = 1
    dut.addr_i.value = addr
    dut.data_i.value = data
    dut.inst_valid.value = 1
    await RisingEdge(dut.clk_i)
    dut.inst_valid.value = 0

async def read_inst(dut, addr, data):
    dut.inst_i.value = 0
    dut.addr_i.value = addr
    dut.data_i.value = data
    dut.inst_valid.value = 1
    await RisingEdge(dut.clk_i)
    dut.inst_valid.value = 0


async def reset_dut(dut):
    dut.rstn_i.value = 0
    for _ in range(10):
        await RisingEdge(dut.clk_i)
    dut.rstn_i.value = 1