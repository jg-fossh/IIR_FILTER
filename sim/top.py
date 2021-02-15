import random
import cocotb
import sys
# insert at 1, 0 is the script path (or '' in REPL)
sys.path.append('externals/Wishbone_Standard_Master/')
from cocotb.triggers import Timer
from cocotb.clock import Clock
from uvm.base import run_test, UVMDebug
from uvm.base.uvm_phase import UVMPhase
from uvm.seq import UVMSequence
from externals.Wishbone_Standard_Master.wb_standard_master_if import *
from tb_env_config import *
from iir_filter_tb_env import *
from iir_filter_test_lib import *

async def initial_run_test(dut, vif, vif_read, vif_write):
    from uvm.base import UVMCoreService
    cs_ = UVMCoreService.get()
    UVMConfigDb.set(None, "*", "vif", vif)
    UVMConfigDb.set(None, "*", "vif_read", vif_read)
    UVMConfigDb.set(None, "*", "vif_write", vif_write)
    await run_test("iir_filter_reg_test")


async def initial_reset(vif, vif_read, vif_write, dut):
    await Timer(0, "NS")
    vif.rst_i <= 1
    await Timer(330, "NS") # clock*32 + 1 to clear all general register which are BRAM
    vif.rst_i <= 0
    cocotb.fork(initial_run_test(dut, vif, vif_read, vif_write))


@cocotb.test()
async def top(dut):
    """ IIR Filter Test Bench Top """

    # Map the signals in the DUT to the verification agents interfaces
    bus_map = {"clk_i": "i_clk", 
               "rst_i": "i_reset_sync",
               "adr_o": "adr_o", 
               "dat_i": "i_master_read_data",
               "dat_o": "dat_o", 
               "we_o": "we_o",
               "sel_o": "sel_o",
               "stb_o": "o_master_read_stb",
               "ack_i": "i_master_read_ack",
               "cyc_o": "cyc_o",
               "stall_i": "stall_i",
               "tga_o": "tga_o",
               "tgd_i": "tgd_i",
               "tgd_o": "tgd_o",
               "tgc_o": "tgc_o"}

    bus_map_read = {"clk_i": "i_clk", 
                    "rst_i": "i_reset_sync",
                    "adr_o": "adr_o", 
                    "dat_i": "o_slave_read_data",
                    "dat_o": "dat_o", 
                    "we_o": "we_o",
                    "sel_o": "sel_o",
                    "stb_o": "i_slave_read_stb",
                    "ack_i": "o_slave_read_ack",
                    "cyc_o": "cyc_o",
                    "stall_i": "stall_i",
                    "tga_o": "tga_o",
                    "tgd_i": "tgd_i",
                    "tgd_o": "tgd_o",
                    "tgc_o": "tgc_o"}

    bus_map_write = {"clk_i": "i_clk", 
                     "rst_i": "i_reset_sync",
                     "adr_o": "i_slave_write_addr", 
                     "dat_i": "i_slave_write_data",
                     "dat_o": "dat_o", 
                     "we_o": "we_o",
                     "sel_o": "o_master_write_sel",
                     "stb_o": "i_slave_write_stb",
                     "ack_i": "o_slave_write_ack",
                     "cyc_o": "cyc_o",
                     "stall_i": "stall_i",
                     "tga_o": "tga_o",
                     "tgd_i": "tgd_i",
                     "tgd_o": "tgd_o",
                     "tgc_o": "tgc_o"}
 
    vif = wb_standard_master_if(dut, bus_map)
    vif_read = wb_standard_master_if(dut, bus_map_read)
    vif_write = wb_standard_master_if(dut, bus_map_write)

    # Create a 1000Mhz clock
    clock = Clock(dut.i_clk, 1, units="ns") 
    cocotb.fork(clock.start())  # Start the clock
    cocotb.fork(initial_reset(vif, vif_read, vif_write, dut))
    #cocotb.fork(initial_run_test(dut, vif))

    await Timer(5, "US")