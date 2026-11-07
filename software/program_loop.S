.section .text.init
.globl _start

_start:
    lui  t0, 0x10          # t0 = 0x0001_0000, data-memory base
    addi t1, x0, 5         # t1 = counter = 5
    addi t2, x0, 0         # t2 = accumulator = 0

loop:
    add  t2, t2, t1        # accumulator += counter
    addi t1, t1, -1        # counter--
    bne  t1, x0, loop      # repeat while counter != 0

    sw   t2, 0(t0)         # store 15 in data memory
    lw   t3, 0(t0)         # load it back into t3

    lui  t4, 0x10000       # t4 = 0x1000_0000, tohost
    sw   t3, 0(t4)         # send 15 to testbench

halt:
    jal  x0, halt          # loop forever

.section .data
.word 0                    # data-memory location reserved for the result