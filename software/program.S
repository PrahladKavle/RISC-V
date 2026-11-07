.section .text.init
.globl _start

_start:
    lui  t0, 0x10          # t0 = 0x0001_0000 (data-memory base)
    lw   t1, 0(t0)         # t1 = first initialized data word

    lui  t2, 0x10000       # t2 = 0x1000_0000 (tohost address)
    sw   t1, 0(t2)         # send the loaded value to the testbench

halt:
    jal  x0, halt          # loop forever

.section .data
.word 1                    # first data-memory word: PASS value