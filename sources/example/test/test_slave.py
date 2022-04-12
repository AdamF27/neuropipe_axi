import random

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from cocotb_bus.drivers.amba import AXI4LiteMaster, AXIProtocolError

# from cocotbext.axi
# import AxiBus, AxiMaster

@cocotb.test()
async def test_slave(dut):
	
	cocotb.start_soon(Clock(dut.clk_i, 10, units='ns').start())
	axil_master = AXI4LiteMaster(dut, 'axil', dut.clk_i)

	# await reset_dut(dut, 10)
	dut.rstn_i.value = 0
	for _ in range(10):
		await RisingEdge(dut.clk_i)
	dut.rstn_i.value = 1

	data0 = 0xABABABAB
	data1 = 0xCBCBCBCB

	addr0 = 0b0000
	addr1 = 0b0100
	addr2 = 0b1000
	addr3 = 0b1100

	await axil_master.write(addr0, data0)
	await axil_master.write(addr1, data1)
	await axil_master.write(addr2, data0)
	await axil_master.write(addr3, data1)

	assert dut.example_reg0.value == data0
	assert dut.example_reg1.value == data1
	assert dut.example_reg2.value == data0
	assert dut.example_reg3.value == data1

	actual_data0 = await axil_master.read(addr0)
	actual_data1 = await axil_master.read(addr1)
	actual_data2 = await axil_master.read(addr2)
	actual_data3 = await axil_master.read(addr3)

	assert actual_data0 == data0
	assert actual_data1 == data1
	assert actual_data2 == data0
	assert actual_data3 == data1

# async def reset_dut(dut, num_period: int):
# 	dut.rstn_i.value = 0
# 	for _ in range(num_period):
# 		await RisingEdge(dut.clk_i)
# 	dut.rstn_i.value = 1