# Single-Cycle RV32I CPU Core

A modular single-cycle RISC-V CPU core written in Verilog. The project is being developed incrementally to learn digital logic, HDL design, computer architecture, CPU datapaths, instruction decoding, and hardware verification.

Phase A is complete and verified in simulation with standalone module tests and a combined end-to-end program.

## Current Instruction Support

### R-Type

- `ADD`
- `SUB`
- `AND`
- `OR`
- `XOR`
- `SLT`

### I-Type

- `ADDI`
- `ANDI`
- `ORI`

### Memory

- `LW`
- `SW`

### Control Flow

- `BEQ`
- `JAL`

## Architecture

The processor currently uses a single-cycle architecture with separate instruction and data memories.

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

The program counter, register-file writes, and data-memory writes update on the rising clock edge. Instruction decoding, register reads, immediate generation, ALU operations, memory reads, and mux selection are combinational.

## Modules

| File | Description |
|---|---|
| `rv32i_core.v` | Top-level CPU datapath and module integration |
| `program_control.v` | Program-counter register and reset behavior |
| `instruction_mem.v` | Combinational instruction memory loaded with `$readmemh` |
| `data_memory.v` | Word-addressable data memory |
| `control_unit.v` | Opcode, `funct3`, and `funct7` decoder |
| `register_file.v` | 32 × 32-bit register file with two read ports and one write port |
| `imm_gen.v` | I-, S-, B-, and J-type immediate reconstruction and sign extension |
| `alu.v` | Arithmetic, logical, and comparison operations |

## Verification

Each major module has a standalone self-checking testbench under `tb/`.

The combined Phase A test verifies:

- Arithmetic and logical operations
- Signed less-than comparison
- Immediate ALU operations
- Register-file writeback
- Word loads and stores
- Taken and not-taken branches
- Skipped instructions
- JAL target calculation
- JAL link-address writeback
- Sequential PC advancement

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
│   ├── program.hex
│   ├── program_phaseA.hex
│   ├── tb_alu.v
│   ├── tb_control_unit.v
│   ├── tb_data_memory.v
│   ├── tb_imm_gen.v
│   ├── tb_instruction_mem.v
│   ├── tb_phase_a.v
│   ├── tb_program_control.v
│   ├── tb_register_file.v
│   └── tb_rv32i_core.v
└── test/
    └── generated simulation outputs
```
