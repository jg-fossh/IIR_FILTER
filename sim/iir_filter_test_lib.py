#################################################################################
# BSD 3-Clause License
# 
# Copyright (c) 2020, Jose R. Garcia
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#################################################################################
# File name     : iir_filter_test_lib.py
# Author        : Jose R Garcia
# Created       : 2020/11/05 19:26:21
# Last modified : 2021/02/14 21:14:33
# Project Name  : ORCs
# Module Name   : iir_filter_test_lib
# Description   : ORC_R32I Test Library
#
# Additional Comments:
#   Contains the test base and tests.
#################################################################################
import cocotb
from cocotb.triggers import Timer

from uvm import *
from externals.Wishbone_Standard_Master.wb_standard_master_seq import *
from externals.Wishbone_Standard_Master.wb_standard_master_agent import *
from externals.Wishbone_Standard_Master.wb_standard_master_config import *
from tb_env_config import *
from iir_filter_tb_env import *
from iir_filter_predictor import *

class iir_filter_test_base(UVMTest):
    """         
       Class: IIR Filter Test Base
        
       Definition: Contains functions, tasks and methods.
    """

    def __init__(self, name="iir_filter_test_base", parent=None):
        super().__init__(name, parent)
        self.test_pass = True
        self.tb_env = None
        self.tb_env_config = None
        self.inst_agent_cfg = None
        self.reg_block = None
        self.printer = None

    def build_phase(self, phase):
        super().build_phase(phase)
        # Enable transaction recording for everything
        UVMConfigDb.set(self, "*", "recording_detail", UVM_FULL)
        # Create the reg block
        # self.reg_block = reg_block.type_id.create("reg_block", self)
        # self.reg_block.build()
        # create this test test bench environment config
        self.tb_env_config = tb_env_config.type_id.create("tb_env_config", self)
        # self.tb_env_config.reg_block = self.reg_block
        self.tb_env_config.has_scoreboard = True
        self.tb_env_config.has_predictor = True
        self.tb_env_config.has_functional_coverage = False
        # Create the instruction agent
        self.inst_agent_cfg = wb_standard_master_config.type_id.create("inst_agent_cfg", self)
        arr = []
        # Get the instruction interface created at top
        if UVMConfigDb.get(None, "*", "vif", arr) is True:
            UVMConfigDb.set(self, "*", "vif", arr[0])
            # Make this agent's interface the interface connected at top
            self.inst_agent_cfg.vif         = arr[0]
            self.inst_agent_cfg.has_driver  = 1
            self.inst_agent_cfg.has_monitor = 1
        else:
            uvm_fatal("NOVIF", "Could not get vif from config DB")

        # Create the Mem Read agent
        self.mem_read_agent_cfg = wb_standard_master_config.type_id.create("mem_read_agent_cfg", self)
        arr = []
        # Get the instruction interface created at top
        if UVMConfigDb.get(None, "*", "vif_read", arr) is True:
            UVMConfigDb.set(self, "*", "vif_read", arr[0])
            # Make this agent's interface the interface connected at top
            self.mem_read_agent_cfg.vif         = arr[0]
            self.mem_read_agent_cfg.has_driver  = 1
            self.mem_read_agent_cfg.has_monitor = 1
        else:
            uvm_fatal("NOVIF", "Could not get vif_read from config DB")

        # Create the Mem Write agent
        self.mem_write_agent_cfg = wb_standard_master_config.type_id.create("mem_write_agent_cfg", self)
        arr = []
        # Get the instruction interface created at top
        if UVMConfigDb.get(None, "*", "vif_write", arr) is True:
            UVMConfigDb.set(self, "*", "vif_write", arr[0])
            # Make this agent's interface the interface connected at top
            self.mem_write_agent_cfg.vif         = arr[0]
            self.mem_write_agent_cfg.has_driver  = 1
            self.mem_write_agent_cfg.has_monitor = 1
        else:
            uvm_fatal("NOVIF", "Could not get vif_write from config DB")

        # Make this instruction agent the test bench config agent
        self.tb_env_config.inst_agent_cfg = self.inst_agent_cfg
        self.tb_env_config.mem_read_agent_cfg = self.mem_read_agent_cfg
        self.tb_env_config.mem_write_agent_cfg = self.mem_write_agent_cfg
        UVMConfigDb.set(self, "*", "tb_env_config", self.tb_env_config)
        # Create the test bench environment 
        self.tb_env = iir_filter_tb_env.type_id.create("tb_env", self)
        # Create a specific depth printer for printing the created topology
        self.printer = UVMTablePrinter()
        self.printer.knobs.depth = 4


    def end_of_elaboration_phase(self, phase):
        # Print topology
        uvm_info(self.get_type_name(),
            sv.sformatf("Printing the test topology :\n%s", self.sprint(self.printer)), UVM_LOW)


    def report_phase(self, phase):
        if self.test_pass:
            uvm_info(self.get_type_name(), "** UVM TEST PASSED **", UVM_NONE)
        else:
            uvm_fatal(self.get_type_name(), "** UVM TEST FAIL **\n" +
                self.err_msg)


uvm_component_utils(iir_filter_test_base)


class iir_filter_reg_test(iir_filter_test_base):


    def __init__(self, name="iir_filter_reg_test", parent=None):
        super().__init__(name, parent)
        self.hex_instructions = []
        self.fetched_instruction = None
        self.count = 0


    async def run_phase(self, phase):
        cocotb.fork(self.stimulate_inst_intfc())
        cocotb.fork(self.stimulate_read_intfc())
        cocotb.fork(self.stimulate_write_intfc())

    
    async def stimulate_read_intfc(self):
        mem_read_sqr = self.tb_env.mem_read_agent.sqr
        
        #  Create seq0
        mem_read_seq0 = read_single_sequence("mem_read_seq0")
        mem_read_seq0.data = 0 #
        #
        while True:
            await mem_read_seq0.start(mem_read_sqr)


    async def stimulate_write_intfc(self):
        mem_write_sqr = self.tb_env.mem_write_agent.sqr
        
        #  Create seq0
        mem_write_seq0 = write_single_sequence("mem_write_seq0")
        #
        while True:
            await mem_write_seq0.start(mem_write_sqr)


    async def stimulate_inst_intfc(self):
        # Initial setup
        self.read_hex()
        slave_sqr = self.tb_env.inst_agent.sqr
        
        while (self.count < 7600):
            # Fetch instruction
            self.fetch_instruction(self.count)
            #  Create seq0
            slave_seq0 = read_single_sequence("slave_seq0")
            slave_seq0.data = self.fetched_instruction
            # Call the sequencer
            await slave_seq0.start(slave_sqr)
            self.count = self.count + 1


    def read_hex(self):
        f = open('dhry.hex', 'r+')
        hex_inst_list = [line.split(' ') for line in f.readlines()]
        #f'{6:08b}'
        self.hex_instructions = []
        for i,s in enumerate(hex_inst_list):
            self.hex_instructions.append([i.strip() for i in s])

    def fetch_instruction(self, count):
        hex_string = self.hex_instructions[count][3] + self.hex_instructions[count][2] + self.hex_instructions[count][1] + self.hex_instructions[count][0]
        self.fetched_instruction = int(hex_string, 16)

uvm_component_utils(iir_filter_reg_test)