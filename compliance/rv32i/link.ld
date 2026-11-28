IMEM_ORIGIN = 0x00000000;
IMEM_LENGTH = 0x00040000;

DMEM_ORIGIN = 0x00040000;
DMEM_LENGTH = 0x00040000;

NUM_HARTS = 1;
STACK_SIZE = 0x00001000;

OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)

MEMORY
{
    imem (rx)  : ORIGIN = IMEM_ORIGIN, LENGTH = IMEM_LENGTH
    dmem (rwx) : ORIGIN = DMEM_ORIGIN, LENGTH = DMEM_LENGTH
}

PROVIDE(__stack_size = STACK_SIZE);
PROVIDE(__num_harts = NUM_HARTS);

SECTIONS
{
    .text IMEM_ORIGIN :
    {
        *(.text.init)
        *(.text.rvtest)
        *(.text.rvtest.*)
        *(.text.rvmodel)
        *(.text.rvmodel.*)
        *(.text)
        *(.text.*)
    } > imem

    __imem_end = .;

    .data DMEM_ORIGIN :
    {
        . = ALIGN(16);
        *(.rodata)
        *(.rodata.*)
        *(.srodata)
        *(.srodata.*)
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
        *(.tohost)
        *(.tohost.*)
        *(.signature)
        *(.signature.*)
    } > dmem

    .bss (NOLOAD) :
    {
        . = ALIGN(16);
        __bss_start = .;
        _bss_start = .;
        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(16);
        __bss_end = .;
        _bss_end = .;
    } > dmem

    . = ALIGN(16);
    __stack_bottom = .;
    . += STACK_SIZE * NUM_HARTS;
    __stack_top = .;

    _end = .;

    ASSERT(
        __imem_end <= ORIGIN(imem) + LENGTH(imem),
        "ACT test exceeds 64 KiB instruction memory"
    )

    ASSERT(
        _end <= ORIGIN(dmem) + LENGTH(dmem),
        "ACT test exceeds 64 KiB data memory"
    )
}