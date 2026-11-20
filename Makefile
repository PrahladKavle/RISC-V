RISCV_PREFIX ?= riscv64-elf-
CC           := $(RISCV_PREFIX)gcc
OBJCOPY      := $(RISCV_PREFIX)objcopy
OBJDUMP      := $(RISCV_PREFIX)objdump

PYTHON       ?= python3
IVERILOG     ?= iverilog
VVP          ?= vvp

BUILD_DIR    := build
TEST_DIR     := test
LINKER       := software/link.ld
CONVERTER    := tools/bin_to_memh.py

RTL := \
	rv32i_core.v \
	program_control.v \
	instruction_mem.v \
	data_memory.v \
	control_unit.v \
	register_file.v \
	imm_gen.v \
	alu.v

RV32I_FLAGS := \
	-march=rv32i \
	-mabi=ilp32 \
	-nostdlib \
	-nostartfiles \
	-Wl,-T,$(LINKER) \
	-Wl,--no-relax

PROGRAMS := program program_loop program_bss

.DEFAULT_GOAL := help
.SECONDARY:

.PHONY: help programs test-smoke test-loop test-bss test-all images-% disasm-%

help:
	@printf '%s\n' \
	  'Targets:' \
	  '  make programs       Build all assembly programs and memory images.' \
	  '  make test-smoke     Run the simple tohost smoke test.' \
	  '  make test-loop      Run the compiled loop program test.' \
	  '  make test-bss       Run the BSS startup-clear test.' \
	  '  make test-all       Run every compiled-program test.' \
	  '  make images-NAME    Build images for program, program_loop, or program_bss.' \
	  '  make disasm-NAME    Display the ELF disassembly for a program.'

programs: $(PROGRAMS:%=$(BUILD_DIR)/%.hex) $(PROGRAMS:%=$(BUILD_DIR)/%_data.hex)

$(BUILD_DIR)/%.elf: software/%.S $(LINKER)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(RV32I_FLAGS) -o $@ $<

$(BUILD_DIR)/%_text.bin: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -O binary --only-section=.text $< $@

$(BUILD_DIR)/%_data.bin: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -O binary --only-section=.data $< $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%_text.bin $(CONVERTER)
	$(PYTHON) $(CONVERTER) $< $@

$(BUILD_DIR)/%_data.hex: $(BUILD_DIR)/%_data.bin $(CONVERTER)
	$(PYTHON) $(CONVERTER) $< $@

images-%: $(BUILD_DIR)/%.hex $(BUILD_DIR)/%_data.hex

disasm-%: $(BUILD_DIR)/%.elf
	$(OBJDUMP) -d $<

$(TEST_DIR)/tohost_test: tb/tb_tohost.v $(RTL) $(BUILD_DIR)/program.hex $(BUILD_DIR)/program_data.hex
	@mkdir -p $(TEST_DIR)
	$(IVERILOG) -s tb_tohost -o $@ $(RTL) $<

$(TEST_DIR)/program_loop_test: tb/tb_program_loop.v $(RTL) $(BUILD_DIR)/program_loop.hex $(BUILD_DIR)/program_loop_data.hex
	@mkdir -p $(TEST_DIR)
	$(IVERILOG) -s tb_program_loop -o $@ $(RTL) $<

$(TEST_DIR)/program_bss_test: tb/tb_program_bss.v $(RTL) $(BUILD_DIR)/program_bss.hex $(BUILD_DIR)/program_bss_data.hex
	@mkdir -p $(TEST_DIR)
	$(IVERILOG) -s tb_program_bss -o $@ $(RTL) $<

test-smoke: $(TEST_DIR)/tohost_test
	$(VVP) $<

test-loop: $(TEST_DIR)/program_loop_test
	$(VVP) $<

test-bss: $(TEST_DIR)/program_bss_test
	$(VVP) $<

test-all: test-smoke test-loop test-bss
