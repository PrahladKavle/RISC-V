#!/usr/bin/env python3
"""Run one ACT-generated ELF on the RV32I Icarus Verilog testbench."""

import argparse
import re
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
BUILD_DIR = PROJECT_ROOT / "build"
TEST_DIR = PROJECT_ROOT / "test"
CONVERTER = PROJECT_ROOT / "tools" / "bin_to_memh.py"

RTL_FILES = [
    "rv32i_core.v",
    "program_control.v",
    "instruction_mem.v",
    "data_memory.v",
    "control_unit.v",
    "register_file.v",
    "imm_gen.v",
    "alu.v",
]


def run(command):
    print("+", " ".join(str(part) for part in command))
    subprocess.run(command, cwd=PROJECT_ROOT, check=True)


def symbol_address(elf_path, symbol_name):
    command = ["riscv64-elf-nm", "-n", elf_path]
    print("+", " ".join(str(part) for part in command))
    result = subprocess.run(command, check=True, capture_output=True, text=True)
    pattern = re.compile(rf"^([0-9a-fA-F]+)\s+\S\s+{re.escape(symbol_name)}$")

    for line in result.stdout.splitlines():
        match = pattern.match(line.strip())
        if match:
            return int(match.group(1), 16)

    raise RuntimeError(f"ELF does not define required symbol: {symbol_name}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("elf", type=Path, help="ACT-generated ELF file")
    parser.add_argument("--vcd", action="store_true", help="write test/act_runner.vcd")
    arguments = parser.parse_args()

    elf_path = arguments.elf.resolve()
    if not elf_path.is_file():
        parser.error(f"ELF file not found: {elf_path}")

    end_signature_addr = symbol_address(elf_path, "end_signature")

    BUILD_DIR.mkdir(exist_ok=True)
    TEST_DIR.mkdir(exist_ok=True)

    text_bin = BUILD_DIR / "act_program_text.bin"
    data_bin = BUILD_DIR / "act_data.bin"
    text_hex = BUILD_DIR / "act_program.hex"
    data_hex = BUILD_DIR / "act_data.hex"
    simulation = TEST_DIR / "act_runner_test"

    run([
        "riscv64-elf-objcopy",
        "-O",
        "binary",
        "--only-section=.text",
        elf_path,
        text_bin,
    ])
    run([
        "riscv64-elf-objcopy",
        "-O",
        "binary",
        "--only-section=.data",
        elf_path,
        data_bin,
    ])
    run([sys.executable, CONVERTER, text_bin, text_hex])
    run([sys.executable, CONVERTER, data_bin, data_hex])
    run([
        "iverilog",
        "-g2012",
        "-s",
        "tb_act_runner",
        "-o",
        simulation,
        *[PROJECT_ROOT / source for source in RTL_FILES],
        PROJECT_ROOT / "tb" / "tb_act_runner.v",
    ])

    simulation_command = ["vvp", simulation, f"+end_signature={end_signature_addr:08x}"]
    if arguments.vcd:
        simulation_command.append("+vcd")
    run(simulation_command)


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        sys.exit(error.returncode)
