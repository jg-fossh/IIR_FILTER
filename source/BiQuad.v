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
// File name    : BiQuad.v
// Author       : Jose R Garcia
// Create Date  : 18/05/2020 19:25:32
// Project Name : Synthesizesable Unit Library
// Unit Name    : BiQuad
// Description  : Scalable IIR filter Transposed Direct Form II.
//
// Additional Comments:
//   Parallel Implementation    
//    
///////////////////////////////////////////////////////////////////////////////

module BiQuad #(
  // Compile time configurable generic parameters
  parameter integer P_DATA_MSB   = 0, //
  parameter integer P_IS_ANLOGIC = 0  //
)(
  // Component's clocks and resets
  input i_clk,        // Main Clock
  input i_reset_sync, // Synchronous Reset
  // Sample In Wishbone(Standard) Master Read Interface
  input  [P_DATA_MSB:0] i_x_data,
  // FIR Out Wishbone(Standard) Master Read Interface
  output [P_DATA_MSB:0] o_y_data, // WB data
  // Coeff Interface
  input [P_DATA_MSB:0] i_coeff_00_data, // WB data
  input [P_DATA_MSB:0] i_coeff_01_data, // WB data
  input [P_DATA_MSB:0] i_coeff_10_data, // WB data
  input [P_DATA_MSB:0] i_coeff_11_data  // WB data
);

  /////////////////////////////////////////////////////////////////////////////
  // Internal Parameter Declarations
  /////////////////////////////////////////////////////////////////////////////
  localparam integer L_PRODUCT_MSB = ((P_DATA_MSB+1)*2)-1;
  /////////////////////////////////////////////////////////////////////////////
  // Internal Signal Declarations
  /////////////////////////////////////////////////////////////////////////////
  // Delay Process
  reg [P_DATA_MSB:0] r_z0;
  reg [P_DATA_MSB:0] r_z1;
  reg [P_DATA_MSB:0] r_z2;
  reg [P_DATA_MSB:0] r_z3;
  reg [P_DATA_MSB:0] r_z4;
  // Multiplier Products
  wire [L_PRODUCT_MSB:0] w_a_product;
  wire [L_PRODUCT_MSB:0] w_b_product;
  wire [L_PRODUCT_MSB:0] w_c_product;
  wire [L_PRODUCT_MSB:0] w_d_product;
  // Accumulators
  wire [P_DATA_MSB:0] w_xa_acc = i_x_data + r_z0;
  wire [P_DATA_MSB:0] w_a_acc  = r_z1 + w_a_product[P_DATA_MSB:0];
  wire [P_DATA_MSB:0] w_cd_acc = w_c_product[P_DATA_MSB:0] + w_d_product[P_DATA_MSB:0];


  /////////////////////////////////////////////////////////////////////////////
  //            ********      Architecture Declaration      ********
  /////////////////////////////////////////////////////////////////////////////

  // Result
  assign o_y_data = w_cd_acc;

  /////////////////////////////////////////////////////////////////////////////
  // Process     : Delay Process
  // Description : Accumulates the filtered samples.
  /////////////////////////////////////////////////////////////////////////////
  always @(negedge i_clk) begin
    if(i_reset_sync == 1'b1) begin
      // Synchronous Reset
      r_z0 <= 'h0;
      r_z1 <= 'h0;
      r_z2 <= 'h0;
      r_z3 <= 'h0;
      r_z4 <= 'h0;
    end
    else begin
      r_z0 <= w_a_acc[P_DATA_MSB:0];
      r_z1 <= w_b_product[P_DATA_MSB:0];
      r_z2 <= w_xa_acc[P_DATA_MSB:0];
      r_z3 <= r_z2;
      r_z4 <= r_z3;
    end
  end

  /////////////////////////////////////////////////////////////////////////////
  // Process     : Multiplier Instance
  // Description : Created Multiplier A
  /////////////////////////////////////////////////////////////////////////////
  //Instantiate the Multiplier (UUT)
  Multiplier #(
    P_DATA_MSB,
    P_IS_ANLOGIC
  ) multiplier_a (
    // Signals
    .i_clk(i_clk),
    .i_reset_sync(i_reset_sync),
    .i_multiplicand(r_z2),
    .i_multiplier(i_coeff_00_data),
    .o_product(w_a_product)
  );

  /////////////////////////////////////////////////////////////////////////////
  // Process     : Multiplier Instance
  // Description : Created Multiplier B
  /////////////////////////////////////////////////////////////////////////////
  Multiplier #(
    P_DATA_MSB,
    P_IS_ANLOGIC
  ) multiplier_b (
    // Signals
    .i_clk(i_clk),
    .i_reset_sync(i_reset_sync),
    .i_multiplicand(r_z2),
    .i_multiplier(i_coeff_01_data),
    .o_product(w_b_product)
  );

  /////////////////////////////////////////////////////////////////////////////
  // Process     : Multiplier Instance
  // Description : Creates Multiplier C
  /////////////////////////////////////////////////////////////////////////////
  //Instantiate the Multiplier (UUT)
  Multiplier #(
    P_DATA_MSB,
    P_IS_ANLOGIC
  ) multiplier_c (
    // Signals
    .i_clk(i_clk),
    .i_reset_sync(i_reset_sync),
    .i_multiplicand(r_z3),
    .i_multiplier(i_coeff_10_data),
    .o_product(w_c_product)
  );

  /////////////////////////////////////////////////////////////////////////////
  // Process     : Multiplier Instance
  // Description : Created Multiplier D
  /////////////////////////////////////////////////////////////////////////////
  Multiplier #(
    P_DATA_MSB,
    P_IS_ANLOGIC
  ) multiplier_d (
    // Signals
    .i_clk(i_clk),
    .i_reset_sync(i_reset_sync),
    .i_multiplicand(r_z4),
    .i_multiplier(i_coeff_11_data),
    .o_product(w_d_product)
  );


endmodule // BiQuad
