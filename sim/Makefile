SIM = verilator
TOPLEVEL_LANG = verilog
EXTRA_ARGS += --trace --trace-structs
VERILOG_SOURCES = $(shell pwd)/../source/Multiplier.v ../source/BiQuad.v ../source/IIR_Filter.v ./IIR_Filter_TOP.v
TOPLEVEL = IIR_Filter_TOP
MODULE = top

include $(shell cocotb-config --makefiles)/Makefile.sim
