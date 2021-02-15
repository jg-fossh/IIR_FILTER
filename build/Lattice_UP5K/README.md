# Results : Resources and Timing Estimates
_These results were generated using Yosys, NextPNR and the Icestorm tool chain targeting the Lattice UP5k breakout board. These result only account for this core being in the FPGA, as it gets integrated into a design with more components the overall max clock of the system will be lower since the more resources used in a FPGA the harder it is to meet timing._

## Synthesis 
 Yosys version: `Yosys 0.9+3755 (git sha1 442d19f6, gcc 10.2.0-13ubuntu1 -fPIC -Os)`

 Yosys script: `syn_ice40.ys`

### Synthesis Results
| Resource                  | Usage Count | 
| :------------------------ | ----------: |
| Number of  wire           |         1145|
| Number of wire bits       |         8399|
| Number of public wires    |         1145|
| Number of public wire bits|         8399|
| Number of memories        |            0|
| Number of memory bits     |            0|
| Number of processes       |            0|
| Number of cells<br> --- SB_CARRY <br> --- SB_DFF <br> --- SB_DFFESR <br> --- SB_DFFESS <br> --- SB_DFFSR <br> --- SB_DFFSS <br> --- SB_LUT4 <br> --- SB_MAC16 <br> --- SB_RAM40_4K |               3811<br>889<br>90<br>311<br>1<br>33<br>1<br>2467<br>15<br>4|

# Running

For a single run use
    make all

For running regression with multiple seeds
    make -j`nproc` rpt