# Single-Cycle RV32I CPU Core

A modular single-cycle RISC-V CPU core written in Verilog. This independent learning project focuses on digital logic, HDL design, computer architecture, CPU datapaths, instruction decoding, and hardware verification.

The RV32I base integer instruction set is implemented and verified incrementally in simulation with standalone module tests and end-to-end programs.

## Current Instruction Support

### R-Type

- `ADD`
- `SUB`
- `AND`
- `OR`
- `XOR`
- `SLT`
- `SLTU`
- `SLL`
- `SRL`
- `SRA`

### I-Type

- `ADDI`
- `ANDI`
- `ORI`
- `XORI`
- `SLTI`
- `SLTIU`
- `SLLI`
- `SRLI`
- `SRAI`

### Memory

- `LW`
- `SW`
- `LB`
- `LH`
- `LBU`
- `LHU`
- `SB`
- `SH`

### Control Flow

- `BEQ`
- `JAL`
- `BNE`
- `BLT`
- `BGE`
- `BLTU`
- `BGEU`
- `JALR`
- `LUI`
- `AUIPC`
- `FENCE`
- `ECALL`
- `EBREAK`

`FENCE` behaves as a safe no-op because this core has no memory reordering. `ECALL` and `EBREAK` use a minimal halt-style trap: the PC remains at the system instruction. `EBREAK` also raises the internal `breakpoint` signal.

## Architecture

The processor uses a single-cycle architecture with separate instruction and data memories.

Each instruction completes the following path within one clock cycle:

```text
Program Counter
      ↓
Instruction Memory
      ↓
Instruction Decode / Control
      ↓
Register File
      ↓
Immediate Generator / ALU
      ↓
Data Memory
      ↓
Writeback
```

The program counter, register-file writes, and data-memory writes update on the rising clock edge. Instruction decoding, register reads, immediate generation, ALU operations, memory reads, and mux selection are combinational. The register file contains 32 32-bit registers, with `x0` hardwired to zero; data memory is byte-addressable.

## Modules

| File | Description |
|---|---|
| `rv32i_core.v` | Top-level CPU datapath and module integration |
| `program_control.v` | Program-counter register and reset behavior |
| `instruction_mem.v` | Combinational instruction memory loaded with `$readmemh` |
| `data_memory.v` | Byte-addressable data memory |
| `control_unit.v` | Opcode, `funct3`, `funct7`, and system-immediate decoder |
| `register_file.v` | 32 × 32-bit register file with two read ports and one write port |
| `imm_gen.v` | I-, S-, B-, U-, and J-type immediate reconstruction and sign extension |
| `alu.v` | Arithmetic, logical, shift, and comparison operations |

## Verification

Each major module has a standalone self-checking testbench under `tb/`.

The phase testbenches cover:

- Phase A: core arithmetic, `LW`/`SW`, `BEQ`, and `JAL`
- Phase B: remaining ALU and I-type arithmetic/shift instructions
- Phase C: byte and halfword loads/stores
- Phase D: remaining branches, `JALR`, `LUI`, and `AUIPC`
- Phase E: `FENCE`, `ECALL`, and `EBREAK`

Example: compile and run the Phase E test from the project root:

```sh
iverilog -s tb_phase_e -o test/phase_e_test \
  rv32i_core.v program_control.v instruction_mem.v data_memory.v \
  control_unit.v register_file.v imm_gen.v alu.v tb/tb_phase_e.v

vvp test/phase_e_test
```

## Project Structure

```text
RISC-V/
├── alu.v
├── control_unit.v
├── data_memory.v
├── imm_gen.v
├── instruction_mem.v
├── program_control.v
├── register_file.v
├── rv32i_core.v
├── README.md
├── tb/
│   ├── program_phaseA.hex ... program_phaseE.hex
│   ├── tb_alu.v
│   ├── tb_control_unit.v
│   ├── tb_data_memory.v
│   ├── tb_imm_gen.v
│   ├── tb_instruction_mem.v
│   ├── tb_phase_a.v ... tb_phase_e.v
│   ├── tb_program_control.v
│   ├── tb_register_file.v
│   └── tb_rv32i_core.v
└── test/
    └── generated simulation outputs
```

## Next Steps

- Run the full testbench regression after each change.
- Port the design to FPGA hardware.
- Memory-map a UART transmit register and run a program that prints through the UART.
- Use this single-cycle structure as the base for a pipelined implementation.
