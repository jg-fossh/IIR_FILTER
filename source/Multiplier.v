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
// File name     : Multiplier.v
// Author        : Jose R Garcia
// Created       : 2020/12/06 15:51:57
// Last modified : 2021/02/11 17:45:23
// Project Name  : Multiplier
// Module Name   : Multiplier
// Description   : Inferable multiplier.
//
// Additional Comments:
//   .
/////////////////////////////////////////////////////////////////////////////////
module Multiplier #(
  parameter integer P_MUL_FACTORS_MSB = 7,
  parameter integer P_MUL_ANLOGIC_MUL = 0
)(
  input                                  i_clk,
  input                                  i_reset_sync,
  input  [P_MUL_FACTORS_MSB:0]           i_multiplier,
  input  [P_MUL_FACTORS_MSB:0]           i_multiplicand,
  output [((P_MUL_FACTORS_MSB+1)*2)-1:0] o_product
);

  ///////////////////////////////////////////////////////////////////////////////
  // Internal Parameter Declarations
  ///////////////////////////////////////////////////////////////////////////////
  localparam L_MUL_FACTORS_EXTENDED_MSB = ((P_MUL_FACTORS_MSB+1)*2)-1;
  ///////////////////////////////////////////////////////////////////////////////
  // Internal Signals Declarations
  ///////////////////////////////////////////////////////////////////////////////
  // MUL Processor to Memory_Backplane connecting wires.
  reg [L_MUL_FACTORS_EXTENDED_MSB:0] r_product;
  
  ///////////////////////////////////////////////////////////////////////////////
  //            ********      Architecture Declaration      ********           //
  ///////////////////////////////////////////////////////////////////////////////

  generate
    if (P_MUL_ANLOGIC_MUL == 0) begin
      /////////////////////////////////////////////////////////////////////////////
      // Process     : Multiplication Process
      // Description : Generic code that modern synthesizers infer as DSP blocks.
      /////////////////////////////////////////////////////////////////////////////
      always @(posedge i_clk) begin
        if (i_reset_sync == 1'b1) begin
          r_product <= 'h0;
        end
        else begin
          // Multiply any time the inputs changes.
          r_product <= $signed(i_multiplicand) * $signed(i_multiplier);
        end
      end
      assign o_product = r_product;
    end
  endgenerate

  generate
    if (P_MUL_ANLOGIC_MUL == 1) begin
      ///////////////////////////////////////////////////////////////////////////////
      // Instance    : Integer_Multiplier
      // Description : Anlogic IP EG_LOGIC_MULT, TD version 4.6.18154
      ///////////////////////////////////////////////////////////////////////////////
	    EG_LOGIC_MULT #(
        .INPUT_WIDTH_A(P_MUL_FACTORS_MSB+1),
	      .INPUT_WIDTH_B(P_MUL_FACTORS_MSB+1),
	      .OUTPUT_WIDTH(L_MUL_FACTORS_EXTENDED_MSB+1),
	      .INPUTFORMAT("SIGNED"),
	      .INPUTREGA("DISABLE"),
	      .INPUTREGB("DISABLE"),
	      .OUTPUTREG("ENABLE"),
	      .IMPLEMENT("DSP"),
	      .SRMODE("ASYNC")
	    ) Integer_Multiplier (
	      .a(i_multiplier),
	      .b(i_multiplicand),
	      .p(o_product),
	      .cea(1'b0),
	      .ceb(1'b0),
	      .cepd(1'b1),
	      .clk(i_clk),
	      .rstan(1'b0),
	      .rstbn(1'b0),
	      .rstpdn(~i_reset_sync)
	    );
    end
  endgenerate
endmodule // Multiplier
