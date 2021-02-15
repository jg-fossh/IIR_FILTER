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
// File name    : IIR_Filter.v
// Author       : Jose R Garcia
// Create Date  : 18/05/2020 19:25:32
// Project Name : Synthesizesable Unit Library
// Unit Name    : IIR_Filter
// Description  : Scalable IIR filter Transposed Direct Form II.
//
// Additional Comments:
//   Parallel Implementation    
//    
///////////////////////////////////////////////////////////////////////////////
module IIR_Filter #(
  // Compile time configurable generic parameters
  parameter integer P_NUM_COEFFICIENTS = 13, // Number of filter coefficient
  parameter integer P_ADDR_MSB         = 3, //
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
  input                i_slave_write_stb,  // WB write enable
  input [P_ADDR_MSB:0] i_slave_write_addr, // WB address
  input [P_DATA_MSB:0] i_slave_write_data, // WB data
  output               o_slave_write_ack   // WB acknowledge 
);

  /////////////////////////////////////////////////////////////////////////////
  // Internal Parameter Declarations
  /////////////////////////////////////////////////////////////////////////////
  localparam integer L_PRODUCT_MSB = ((P_DATA_MSB+1)*2)-1;
  localparam integer L_NUM_BIQUADS = (P_NUM_COEFFICIENTS-1)/4;
  /////////////////////////////////////////////////////////////////////////////
  // Internal Signal Declarations
  /////////////////////////////////////////////////////////////////////////////
  // WB Master
  reg r_master_read_stb;
  reg r_master_read_ack;
  // WB Slave
  reg r_slave_read_ack;
  // Biquads
  wire [P_DATA_MSB:0] w_y [0:L_NUM_BIQUADS-1];
  // Multiplier A Process
  reg  [P_DATA_MSB:0]    r_multiplier0;
  reg  [P_DATA_MSB:0]    r_multiplier1;
  wire [L_PRODUCT_MSB:0] w_product; // Array of Multiplication products.
  // Memory Write interface Signals
  reg [P_DATA_MSB:0] r_coefficients[0:P_NUM_COEFFICIENTS-1]; //
  // Accumulators
  reg  [P_DATA_MSB:0] r_y [0:L_NUM_BIQUADS-1];
  wire [P_DATA_MSB:0] w_accumulator [0:L_NUM_BIQUADS-1]; //
  reg  [P_DATA_MSB:0] r_accumulator; //
  // Coeff Write Interface
  reg r_slave_write_ack;
  // Misc.
  integer ii;
  integer jj;

  /////////////////////////////////////////////////////////////////////////////
  //            ********      Architecture Declaration      ********
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
  // Process     : WB Master Read Process
  // Description : Controls the WB interface.
  /////////////////////////////////////////////////////////////////////////////
  always @(negedge i_clk) begin
    if(i_reset_sync == 1'b1) begin
      // Synchronous Reset
      r_master_read_stb <= 1'b0;
      r_master_read_ack <= 1'b0;
    end
    else begin
      // Pipeline the valid and ready.
      r_master_read_ack <= i_master_read_ack;

      if (i_slave_read_stb == 1'b1 && r_master_read_stb == 1'b0) begin
        r_master_read_stb <= 1'b1;
      end
      else begin
        r_master_read_stb <= 1'b0;
      end
    end
  end
  assign o_master_read_stb = r_master_read_stb;

  genvar i;
  generate
    for (i=0; i<L_NUM_BIQUADS; i=i+1) begin
        ///////////////////////////////////////////////////////////////////////////////
        // Instance    : biquad(i)
        // Description : BiQuad
        ///////////////////////////////////////////////////////////////////////////////
        BiQuad #(
          P_DATA_MSB, // P_DATA_MSB
          P_IS_ANLOGIC
        ) biquad (
          // Component's clocks and resets
          .i_clk(i_clk),               // Main Clock
          .i_reset_sync(i_reset_sync), // Synchronous Reset
          // Sample In Interface
          .i_x_data(i_master_read_data),
          // FIR Out Interface
          .o_y_data(w_y[i]),
          // Coeff Interface
          .i_coeff_00_data(r_coefficients[i]),
          .i_coeff_01_data(r_coefficients[i+1]),
          .i_coeff_10_data(r_coefficients[i+2]),
          .i_coeff_11_data(r_coefficients[i+3])
        );
    end 
  endgenerate
  
  /////////////////////////////////////////////////////////////////////////////
  // Instance    : multiplier
  // Description : Creates a multiplier
  /////////////////////////////////////////////////////////////////////////////
  //Instantiate the Multiplier (UUT)
  Multiplier #(
    P_DATA_MSB,
    P_IS_ANLOGIC
  ) multiplier (
    // Signals
    .i_clk(i_clk),
    .i_reset_sync(i_reset_sync),
    .i_multiplicand(i_master_read_data),
    .i_multiplier(r_coefficients[P_NUM_COEFFICIENTS-1]),
    .o_product(w_product)
  );

  genvar j;
  generate
    for (j=0; j<L_NUM_BIQUADS; j=j+1) begin
      // Accumulator
      if (j == 0) begin
        assign w_accumulator[j] = r_y[j];
      end
      else begin
        assign w_accumulator[j] = r_y[j] + w_accumulator[j-1];
      end
    end
  endgenerate

  /////////////////////////////////////////////////////////////////////////////
  // Process     : Delay Process
  // Description : Pipelines the biquads results
  /////////////////////////////////////////////////////////////////////////////
  always @(negedge i_clk) begin
    if(i_reset_sync == 1'b1) begin
      // Synchronous Reset
      for (ii=0; ii<L_NUM_BIQUADS; ii=ii+1) begin
        r_y[ii] <= 'h0;
      end
      r_multiplier0 <= 'h0;
      r_multiplier1 <= 'h0;
      r_accumulator <= 'h0;
    end
    else begin
      //
      for (ii=0; ii<L_NUM_BIQUADS; ii=ii+1) begin
        r_y[ii] <= w_y[ii];
      end
      //
      r_multiplier0 <= w_product[P_DATA_MSB:0];
      r_multiplier1 <= r_multiplier0;
      //
      r_accumulator <= w_accumulator[L_NUM_BIQUADS-1] + r_multiplier1;
    end
  end

  /////////////////////////////////////////////////////////////////////////////
  // Process     : WB Slave Read Process
  // Description : Controls the WB interface.
  /////////////////////////////////////////////////////////////////////////////
  always @(negedge i_clk) begin
    if(i_reset_sync == 1'b1) begin
      // Synchronous Reset
      r_slave_read_ack <= 1'b0;
    end
    else if (i_slave_read_stb == 1'b1 && r_slave_read_ack == 1'b0) begin
      r_slave_read_ack <= 1'b1;
    end
    else begin
      r_slave_read_ack <= 1'b0;
    end
  end
  //
  assign o_slave_read_ack  = r_slave_read_ack;
  assign o_slave_read_data = r_accumulator[P_DATA_MSB:0];    

  ///////////////////////////////////////////////////////////////////////////////
  // Instance    : Register Space Write Controls
  // Description : 
  ///////////////////////////////////////////////////////////////////////////////
  always@(posedge i_clk) begin
    if (i_reset_sync == 1'b1) begin
      r_slave_write_ack <= 1'b0;
      for (jj=0; jj<P_NUM_COEFFICIENTS; jj=jj+1) begin
        r_coefficients[jj] <= 'h0;
      end
    end
    else if(i_slave_write_stb == 1'b1 && r_slave_write_ack == 1'b0) begin
      // Write Valid Data
      r_coefficients[i_slave_write_addr] <= i_slave_write_data;
      r_slave_write_ack                  <= 1'b1;
    end
    else begin
      r_slave_write_ack <= 1'b0;
    end
  end
  // Read Controls
  assign o_slave_write_ack = r_slave_write_ack;

endmodule // IIR_Filter
