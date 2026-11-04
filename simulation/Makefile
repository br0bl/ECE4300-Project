SIM = icarus
TOPLEVEL_LANG = verilog 
VERILOG_SOURCES = $(PWD)/../sources/mac.sv $(PWD)/../sources/controller.sv
COCOTB_TOPLEVEL = controller
COCOTB_TEST_MODULES = mac_cocotb
WAVES = 1
include $(shell cocotb-config --makefiles)/Makefile.sim
