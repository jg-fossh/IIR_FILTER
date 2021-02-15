/////////////////////////////////////////////////////////////////////////////////
// BSD 3-Clause License
// 
// Copyright (c) 2020, Jose R. Garcia
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
/////////////////////////////////////////////////////////////////////////////////
// File name     : IIR_Filter_TOP.v
// Author        : Jose R Garcia
// Created       : 2020/11/04 23:20:43
// Last modified : 2021/02/14 16:45:06
// Project Name  : IIR Filter
// Module Name   : IIR_Filter_TOP
// Description   : The IIR_Filter_TOP is a wrapper to include the missing signals
//                 required by the verification agents.
//
// Additional Comments:
//   
/////////////////////////////////////////////////////////////////////////////////
module IIR_Filter_TOP #(
  // Compile time configurable generic parameters
  parameter integer P_NUM_COEFFICIENTS = 13, // Number of filter coefficient
  parameter integer P_ADDR_MSB         = 3,  //
  parameter integer P_DATA_MSB         = 15, //
  parameter integer P_IS_ANLOGIC       = 0   //
)(
  // Component's clocks and resets
  input i_clk,        // Main Clock
  input i_reset_sync, // Synchronous Reset
  // Sample In Wishbone(Standard) Master Read Interface
  output                o_master_read_stb,  // WB read enable
  input                 i_master_read_ack,  // WB acknowledge 
  input  [P_DATA_MSB:0] i_master_read_data, // WB data
  // FIR Out Wishbone(Standard) Master Read Interface
  input                 i_slave_read_stb,  // WB read enable
  output                o_slave_read_ack,  // WB acknowledge 
  output [P_DATA_MSB:0] o_slave_read_data, // WB data
  // Coeffs Wishbone(Standard) Write Slave Interface
  input                          i_slave_write_stb,  // WB write enable
  input [P_ADDR_MSB:0] i_slave_write_addr, // WB address
  input [P_DATA_MSB:0]           i_slave_write_data, // WB data
  output                         o_slave_write_ack,  // WB acknowledge 
  // Stubs
  output [15:0] adr_o,   // Added to stub connections
  output [15:0] dat_o,   // Added to stub connections
  output        we_o,    // Added to stub connections
  output        sel_o,   // Added to stub connections
  output        cyc_o,   // Added to stub connections
  input         stall_i, // Added to stub connections
  output        tga_o,   // Added to stub connections
  input         tgd_i,   // Added to stub connections
  output        tgd_o,   // Added to stub connections
  output        tgc_o    // Added to stub connections
);
  ///////////////////////////////////////////////////////////////////////////////
  // Internal Parameter Declarations
  ///////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Signals Declarations
  ///////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  //            ********      Architecture Declaration      ********           //
  ///////////////////////////////////////////////////////////////////////////////

  IIR_Filter #(
    // Compile time configurable generic parameters
    P_NUM_COEFFICIENTS, // Number of filter coefficient
    P_ADDR_MSB,         // 
    P_DATA_MSB ,        //
    P_IS_ANLOGIC        //
  ) iir_filter (
    // Component's clocks and resets
    .i_clk(i_clk),               // Main Clock
    .i_reset_sync(i_reset_sync), // Synchronous Reset
    // Sample In Wishbone(Standard) Master Read Interface
    .o_master_read_stb(o_master_read_stb),   // WB read enable
    .i_master_read_ack(i_master_read_ack),   // WB acknowledge 
    .i_master_read_data(i_master_read_data), // WB data
    // FIR Out Wishbone(Standard) Master Read Interface
    .i_slave_read_stb(i_slave_read_stb),   // WB read enable
    .o_slave_read_ack(o_slave_read_ack),   // WB acknowledge 
    .o_slave_read_data(o_slave_read_data), // WB data
    // Coeffs Wishbone(Standard) Write Slave Interface
    .i_slave_write_stb(i_slave_write_stb),   // WB write enable
    .i_slave_write_addr(i_slave_write_addr), // WB address
    .i_slave_write_data(i_slave_write_data), // WB data
    .o_slave_write_ack(o_slave_write_ack)    // WB acknowledge
  );

assign adr_o = 0;
assign we_o  = 0;
assign sel_o = 0;
assign cyc_o = 0;
assign tga_o = 0;
assign tgd_o = 0;
assign tgc_o = 0;   

endmodule
