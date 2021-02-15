# IIR Filter Synthesizable Unit Specifications

| Document      | Metadata      |
|:------------- |:------------- |
| _Version_     | v0.0.1        |
| _Prepared by_ | Jose R Garcia |
| _Date_        | xx/xx/20XX    |

## Overview

Verilog code for a IIR filter. As new values are fed through the input the filtered result goes out the streaming output synchronous to the input clock.

## Table of Contents

<!-- TOC -->

- [IIR Filter Synthesizable Unit Specifications](#iir-filter-synthesizable-unit-specifications)
  
   - [Overview](#overview)
  
   - [Table of Contents](#table-of-contents)
  
   - [1 Syntax and Abbreviations](#1-syntax-and-abbreviations)
  
   - [2 Design](#2-design)
  
   - [3 Clocks and Resets](#3-clocks-and-resets)
  
   - [4 Interfaces](#4-interfaces)
     
      - [4.1 Streaming Interface](#41-streaming-interface)
      - [4.2 Asynchronous Memory Write Interface](#42-asynchronous-memory-write-interface)
  
   - [5 Generic Parameters](#5-generic-parameters)
  
   - [6 Memory Map](#6-memory-map)
     
      - [6.1 Coefficients Memory Address Space](#61-coefficients-memory-address-space)
        
         - [6.1.1 Coefficient[_N_] Register](#611-coefficient_n_-register)
  
   - [7 Directory Structure](#7-directory-structure)
  
   - [8 Simulation](#8-simulation)
  
   - [9 Synthesis](#9-synthesis)
  
   - [10 Build](#10-build)

<!-- /TOC -->

## 1 Syntax and Abbreviations

| Characters | Definition                    |
|:---------- |:----------------------------- |
| 0b0        | Binary number syntax          |
| 0x0        | Hexadecimal number syntax     |
| IIR        | Infinite Impulse Response     |
| FPGA       | Field Programmable Gate Array |

## 2 Design

The IIR_Filter has _N_ number of coefficients of _n_ length configured at compile time. This coefficients are use to create the filter's tabs. Each tab consist of a MACC. As data moves through the pipeline it fed to each MACC. Coefficients are populated through the Asynchronous Memory Write Interface. The data input is fed through the Streaming Input Interface. The _N^th^_ MACC output is connected directly to the Streaming Output Interface.

| ![Transposed Direct-Form II](TransposedDirectFormII.gif) |
|:--------------------------------------------------------:|
| Figure 2-1 : Transposed Direct-Form II                   |

## 3 Clocks and Resets

| Signals        | Initial State | Direction | Definition                                                            |
|:-------------- |:-------------:|:---------:|:--------------------------------------------------------------------- |
| `i_clk`        | N/A           | In        | Input clock. Streaming interface fall within the domain of this clock |
| `i_reset_sync` | 0b1           | In        | Top level synchronous reset. Use to reset the whole unit.             |

## 4 Interfaces

The IIR_Filter has a Streaming input/output interface and a Asynchronous Memory Write Interface. The Streaming interface is use for create the data path. The memory interface makes the coefficients accessible to be reconfigure on real time.

### 4.1 Streaming Interface

| Signals       | Initial State | Dimension        | Direction | Definition                    |
|:------------- |:-------------:|:----------------:|:---------:|:----------------------------- |
| `o_ready_in`  | 0b0           | 1-bit            | Out       | Ready signal for input data.  |
| `i_valid_in`  | N/A           | 1-bit            | In        | Valid signal for input data.  |
| `i_data_in`   | N/A           | `[P_DATA_MSB:0]` | In        | Input for streaming data.     |
| `i_ready_out` | N/A           | 1-bit            | In        | Ready signal for output data. |
| `o_valid_out` | 0b0           | 1-bit            | Out       | Valid signal for output data. |
| `o_data_out`  | 0x0           | `[P_DATA_MSB:0]` | Out       | Output for streaming data.    |

### 4.2 Asynchronous Memory Write Interface

| Signals              | Initial State | Dimension                 | Direction | Definition                                                                                                                                                           |
|:-------------------- |:-------------:|:-------------------------:|:---------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `i_slave_wselect`    | N/A           | 1-bit                     | In        | Input Select.                                                                                                                                                        |
| `i_slave_write`      | N/A           | 1-bit                     | In        | Write enable. Indicates the current write data is valid and it is to be written into memory. Also indicates write acknowledge(`o_slave_wack`) has not been detected. |
| `o_slave_wack`       | 0b0           | 1-bit                     | Out       | Write acknowledge. Indicate a write was performed. Stays high until write enable(`i_slave_write`) is detected to be low.                                             |
| `i_slave_write_data` | N/A           | `[P_COEFFICIENTS_MSB:0]`  | In        | Write Data. Data input to this addressable memory space.                                                                                                             |
| `i_slave_write_addr` | N/A           | `[P_WRITE_ADDRESS_MSB:0]` | In        | Write Address. Address input to this addressable memory space.                                                                                                       |

## 5 Generic Parameters

| Parameters            | Default | Description                                          |
|:--------------------- |:-------:|:---------------------------------------------------- |
| `P_COEFFICIENTS_MSB`  | 0       | Most significant bit of the FIR filter coefficients. |
| `P_NUM_COEFFICIENTS`  | 1       | Number of coefficients used to build the filter.     |
| `P_DATA_MSB`          | 0       | Most significant bit of the streaming data.          |
| `P_WRITE_ADDRESS_MSB` | 0       | Most significant bit of the memory address.          |

## 6 Memory Map

### 6.1 Coefficients Memory Address Space

| Address Range               | Description                 |
|:--------------------------- |:--------------------------- |
| 0x0 to P_NUM_COEFFICIENTS-1 | Coefficients address space. |

#### 6.1.1 Coefficient[_N_] Register

| Bits                 | Access | Reset | Description                                             |
|:-------------------- |:------:|:-----:|:------------------------------------------------------- |
| P_COEFFICIENTS_MSB:0 | W      | 0b0   | Signed coefficient value used in one tap of the filter. |

## 7 Directory Structure

- `build` _contains synthesis scripts and outputs, build scripts, build constraints, build outputs(reports) and flashable image_
- `octave` _contains math scripts used to generate artifacts that complement the synthesizable unit and/or its test bench_
- `sim` _contains simulation scripts and results_
- `source` _contains source code file (*.v)_
- `testbench` _contains test bench source files_

## 8 Simulation

Simulation scripts assumes _Icarus Verilog_ (iverilog) as the simulation tool. From the /sim directory run make. Options available are

| Command    | Description                                                           |
|:---------- |:--------------------------------------------------------------------- |
| make all   | cleans, compiles and runs the test bench, then it loads the waveform. |
| make test  | compiles the test bench and UUT                                       |
| make run   | runs the simulation                                                   |
| make wave  | loads the waveform in gtkwave                                         |
| make clean | cleans all the compile and simulation products                        |

## 9 Build

Synthesis scripts assume _Yosys_ as the tool for synthesizing code and _Lattice ICE HX-8K_ as the target FPGA device.

Build scripts are written for the Icestorm tool-chain. The target device is the hx8kboard sold by Lattice.

| Command    | Description                                                               |
|:---------- |:------------------------------------------------------------------------- |
| make all   | cleans, synthesizes and runs place and route and generates timing report. |
| make syn   | Runs Yosys synthesis script                                               |
| make pnr   | Runs place and route. (NextPnR)                                           |
| make bin   | create bin file                                                           |
| make rpt   | Output timing report                                                      |
| make clean | cleans all the compile and simulation products                            |

## 10 Generating Coefficients

To generate the coefficients use the Octave script. The first coefficient of the "A" side must always be "1".
