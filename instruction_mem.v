module instruction_memory #(
    parameter DEPTH = 16384, // 16,384 x 4 bytes = 64KB
    parameter ADDR_WIDTH = 14,
    parameter INIT_FILE = "program.hex"
) (
    input wire [31:0] addr, // Address input;

    output wire [31:0] instruction, // Instruction output
    output wire instruction_valid
);
    // Instruction memory array    
    reg [31:0] memory [0:DEPTH-1]; // 256 x 32-bit memory

    wire addr_in_range;

    initial begin
        $readmemh(INIT_FILE, memory);
    end

    assign addr_in_range = (addr[31:16] == 16'h0000); // Check if the address is in the range of 0x00000000 to 0x0000FFFF
    assign instruction_valid = addr_in_range; // Instruction is valid if the address is in range

    assign instruction = addr_in_range
                   ? memory[addr[ADDR_WIDTH+1:2]]
                   : 32'h00000000; // If the address is out of range, return 0

    // It becomes memory[address[9:2]]
    // [1:0] is ignored because 
    // [1:0] -> 00 - byte 0 of the word
    // [1:0] -> 01 - byte 1 of the word
    // [1:0] -> 10 - byte 2 of the word
    // [1:0] -> 11 - byte 3 of the word
    // Therefore, by not considering [1:0], 
    // we are effectively accessing all 4 bytes of the word at once, 
    // which is what we want for a 32-bit instruction memory.

endmodule