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
| Storage                | 256 × 32-bit words       |
| Capacity               | 1 KiB                    |
| Initialization         | `$readmemh`              |
| Intended address range | `0x00000000`–`0x000003FF`|

### Data Memory

| Property               | Value                     |
|------------------------|---------------------------|
| Type                   | Byte-addressable RAM      |
| Storage                | 1024 × 32-bit words       |
| Capacity               | 4 KiB                     |
| Reads                  | Combinational             |
| Writes                 | Rising clock edge         |
| Intended address range | `0x00000000`–`0x00000FFF` |

The current RTL indexes only low address bits. Therefore, addresses outside
the intended ranges may alias into implemented memory rather than raising an
access fault.

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

## Compliance-Test Integration Plan

Instruction memory: 0x0000_0000–0x0000_FFFF, 64 KiB
Data memory:        0x0001_0000–0x0001_FFFF, 64 KiB
Test MMIO tohost:   0x1000_0000
tohost data 1:      PASS
tohost data 2:      FAIL
