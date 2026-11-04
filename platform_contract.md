# RV32I Single-Cycle Core — Platform Contract

## Status

This document describes the current simulated CPU platform.
It is the source of truth for the linker script, testbench, and
`riscv-arch-test` DUT configuration.

Some features needed for full architecture-test integration are marked
**Not implemented yet**.

## CPU Profile

| Property              | Value                                    |
|-----------------------|------------------------------------------|
| ISA width             | RV32                                     |
| Base ISA              | RV32I                                    |
| Harts                 | 1                                        |
| Register width        | 32 bits                                  |
| Register count        | 32 (`x0`–`x31`)                          |
| `x0` behavior         | Always reads as zero; writes are ignored |
| Endianness            | Little-endian                            |
| Compressed extension  | Not supported                            |
| Instruction alignment | 4 bytes (`IALIGN = 32`)                  |
| Reset vector          | `0x00000000`                             |
| Operating system      | None; bare-metal simulation              |

## Implemented Instruction Groups

- Integer register-register operations
- Integer register-immediate operations
- Loads and stores: byte, halfword, and word variants
- Conditional branches
- `JAL` and `JALR`
- `LUI` and `AUIPC`
- `FENCE`, as a no-op
- `ECALL` and `EBREAK`, as halt-style internal traps

## Unsupported ISA Extensions

The core does not implement:

- `M` — integer multiply/divide
- `A` — atomic instructions
- `F` / `D` — floating point
- `C` — compressed instructions
- `Zicsr` — control and status registers
- Privileged machine-mode behavior
- Interrupts

## Current Trap Behavior

| Condition                        | Current behavior                                   |
|----------------------------------|----------------------------------------------------|
| `ECALL`                          | Asserts internal `trap`; PC holds                  |
| `EBREAK`                         | Asserts internal `trap` and `breakpoint`; PC holds |
| Illegal instruction              | Not trapped                                        |
| Instruction-address misalignment | Not trapped                                        |
| Load-address misalignment        | Not trapped                                        |
| Store-address misalignment       | Not trapped                                        |
| Access fault                     | Not trapped                                        |

This is not yet full architectural trap behavior. There are currently no
`mtvec`, `mepc`, `mcause`, `mstatus`, or `mret` implementations.

## Current Memory Implementation

### Instruction Memory

| Property               | Value                    |
|------------------------|--------------------------|
| Type                   | Combinational ROM        |
| Storage                | 16384 × 32-bit words     |
| Capacity               | 64 KiB                   |
| Initialization         | `$readmemh`              |
| Intended address range | `0x00000000–0x0000FFFF`  |

### Data Memory

| Property               | Value                     |
|------------------------|---------------------------|
| Type                   | Byte-addressable RAM      |
| Storage                | 16384 × 32-bit words      |
| Capacity               | 64 KiB                    |
| Reads                  | Combinational             |
| Writes                 | Rising clock edge         |
| Intended address range | `0x00010000–0x0001FFFF`   |

### Test MMIO (`tohost`)

| Property       | Value                                     |
|----------------|-------------------------------------------|
| Address        | `0x10000000`                              |
| Write behavior | Pulses `tohost_write` for one clock       |
| Data capture   | Stores the written value in `tohost_data` |
| Value `1`      | PASS                                      |
| Value `2`      | FAIL                                      |

A `tohost` write does not modify data RAM. Reads from this address return zero.

Instruction fetches and data-memory accesses are range-checked. Out-of-range
data reads return zero and out-of-range writes are ignored. They do not yet
raise architectural access-fault traps.

## Alignment Requirements

| Access              | Required alignment | Current misaligned behavior |
|---------------------|--------------------|-----------------------------|
| Instruction fetch   | 4 bytes            | Not detected                |
| `LB` / `SB`         | 1 byte             | Always aligned              |
| `LH` / `LHU` / `SH` | 2 bytes            | Not detected                |
| `LW` / `SW`         | 4 bytes            | Not detected                |

Only naturally aligned memory accesses are supported by the current core.

## Interfaces

- Instruction and data memories are separate.
- There is no external bus protocol.
- There are no `valid`, `ready`, wait-state, or error-response signals.
- Every supported instruction completes in one clock cycle.

## Compliance-Test Integration Status

Implemented:

- 64 KiB mapped instruction memory
- 64 KiB mapped data memory
- Instruction and data hex-image loading with `$readmemh`
- Data-memory zero initialization before image loading
- `tohost` MMIO completion interface

Remaining:

1. Linker script matching this memory map.
2. ELF-to-instruction/data-hex conversion tool.
3. `riscv-arch-test` DUT configuration and model macros.
4. Architectural trap and exception behavior.
