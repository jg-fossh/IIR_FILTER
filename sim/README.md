### Prerequisites:

These ar also found in the tools/ directory.
 - Verilator and/or Icarus Verilog. 
 - cocotb
 - cocotb-coverage
 - uvm-python

To install a simulator follow the instructions in the tools/README.md
For setting cocotb and uvm-python:

    sudo apt install python3-pip
    pip install cocotb
    pip install cocotb-coverage
    git clone https://github.com/tpoikela/uvm-python.git
    cd uvm-python
    python -m pip install --user .


It is recommend to run the simulation using verilator as such
   
    make

or 

    SIM=icarus make  # Use iverilog as a simulator

Verilator is more strict on code and sometimes it will catch things that synthesis tools would make assumptions on or optimize.