# Single-Cycle RV32I CPU Core

A modular single-cycle RISC-V CPU core written in Verilog. This independent learning project focuses on digital logic, HDL design, CPU datapaths, instruction decoding, memory systems, and hardware verification.

The core uses separate instruction and data memories and is verified with self-checking Icarus Verilog testbenches.

## Implemented Instructions

### Register-register

`ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`

### Register-immediate

`ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`

### Loads and Stores

`LB`, `LH`, `LW`, `LBU`, `LHU`, `SB`, `SH`, `SW`

### Control Flow

`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`, `JAL`, `JALR`

### Upper-Immediate and System

`LUI`, `AUIPC`, `FENCE`, `ECALL`, `EBREAK`

`FENCE` currently behaves as a safe no-op. `ECALL` and `EBREAK` use a minimal halt-style internal trap: the PC holds at the system instruction. Full machine-mode trap handling and CSRs are future work.

## Architecture

Each supported instruction completes in one clock cycle:

```text
Program Counter
      ↓
Instruction Memory
      ↓
Control Unit / Register File / Immediate Generator
      ↓
ALU
      ↓
Data Memory
      ↓
Register Writeback