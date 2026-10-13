module instruction_memory #(
    parameter DEPTH = 256,
    parameter ADDR_WIDTH = 8,
    parameter INIT_FILE = "program.hex"
) (
    input wire [31:0] addr, // Address input;

    output wire [31:0] instruction // Instruction output
);
    // Instruction memory array    
    reg [31:0] memory [0:DEPTH-1]; // 256 x 32-bit memory

    initial begin
        $readmemh(INIT_FILE, memory);
    end

    assign instruction = memory[addr[ADDR_WIDTH+1:2]];
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