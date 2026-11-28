#ifndef _RVMODEL_MACROS_H
#define _RVMODEL_MACROS_H

/*
 * This core reports completion through fixed MMIO rather than a RAM-resident
 * tohost symbol.
 */
#define RVMODEL_DATA_SECTION

/*
 * No STANDARD_SM_SUPPORTED:
 * the core has no Zicsr or architectural machine-mode CSR implementation.
 */

/* PASS: write 1 to the fixed tohost address, 0x10000000. */
#define RVMODEL_HALT_PASS \
  lui  t0, 0x10000       ;\
  addi t1, x0, 1         ;\
  sw   t1, 0(t0)         ;\
1:                        \
  jal  x0, 1b            ;

/* FAIL: write 2 to the fixed tohost address, 0x10000000. */
#define RVMODEL_HALT_FAIL \
  lui  t0, 0x10000       ;\
  addi t1, x0, 2         ;\
  sw   t1, 0(t0)         ;\
1:                        \
  jal  x0, 1b            ;

/* No UART or console output is implemented yet. */
#define RVMODEL_IO_INIT(_R1, _R2, _R3)

#define RVMODEL_IO_WRITE_STR(_R1, _R2, _R3, _STR_PTR)

/* Outside both the instruction and data-memory ranges. */
#define RVMODEL_ACCESS_FAULT_ADDRESS 0x00020000

#endif