.DEFAULT_GOAL := sim

SIM = icarus
TOPLEVEL_LANG = verilog 
VERILOG_SOURCES = $(PWD)/../sources/mac.sv $(PWD)/../sources/controller.sv
COCOTB_TOPLEVEL = controller
COCOTB_TEST_MODULES = mac_cocotb
WAVES = 1

NUM_MACS ?= 1
COMPILE_ARGS += -Pcontroller.NUM_MACS=$(NUM_MACS)

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: all_macs
all_macs:
	@set -e; \
	for macs in 1 2 4; do \
		echo "=========================================================================== Running $$macs MAC(s) ==========================================================================="; \
		$(MAKE) sim NUM_MACS=$$macs \
			SIM_BUILD=sim_build/macs_$$macs \
			COCOTB_RESULTS_FILE=results_macs_$$macs.xml; \
	done; \
	echo "=========================================================================== All tests passed for NUM_MACS = 1, 2, 4 ==========================================================================="
