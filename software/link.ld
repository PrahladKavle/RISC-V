OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
    DMEM (rwx) : ORIGIN = 0x00010000, LENGTH = 64K
}

SECTIONS
{
    .text :
    {
        KEEP(*(.text.init))
        *(.text .text.*)
    } > IMEM

    .data :
    {
        *(.data .data.*)
    } > DMEM

    .bss (NOLOAD) :
    {
        *(.bss .bss.*)
        *(COMMON)
    } > DMEM
}