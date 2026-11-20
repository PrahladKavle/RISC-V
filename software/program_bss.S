.section .text.init
.globl _start

_start:
    la   t0, _bss_start
    la   t1, _bss_end

clear_bss:
    bgeu t0, t1, main
    sw   x0, 0(t0)
    addi t0, t0, 4
    jal  x0, clear_bss

main:
    la   t2, bss_word
    lw   t3, 0(t2)

    lui  t4, 0x10000
    sw   t3, 0(t4)

halt:
    jal  x0, halt

.section .data
.word 0

.section .bss
.align 2
.globl bss_word
bss_word:
    .space 4
