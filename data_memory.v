module data_memory #(
    parameter DEPTH = 16384,
    parameter ADDR_WIDTH = 14,
    parameter [31:0] BASE_ADDR = 32'h00010000,
    parameter TOHOST_ADDR = 32'h10000000
)(
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] w_data,
    input wire w_en,
    input wire r_en,
    input wire [1:0] mem_size,
    input wire load_unsigned,

    output reg [31:0] r_data,
    output reg tohost_write,
    output reg [31:0] tohost_data
);

    reg [31:0] memory [0:DEPTH-1]; 

    wire addr_in_range;
    wire [31:0] byte_offset;
    wire [ADDR_WIDTH-1:0] word_index;

    assign addr_in_range = (addr >= BASE_ADDR) &&
                           (addr < BASE_ADDR + (DEPTH * 4));
    assign byte_offset = addr - BASE_ADDR;
    assign word_index = byte_offset[ADDR_WIDTH+1:2];

    always @(posedge clk) begin
        tohost_write <= 1'b0;
        if (w_en && addr == TOHOST_ADDR) begin
            tohost_write <= 1'b1;
            tohost_data <= w_data;
        end else if (w_en && addr_in_range) begin
            case (mem_size)
                2'b00: begin // Byte
                    memory[word_index][(addr[1:0] * 8) +: 8] <= w_data[7:0];
                end
                2'b01: begin // Half-word
                    memory[word_index][(addr[1] * 16) +: 16] <= w_data[15:0];
                end
                2'b10: begin // Word
                    memory[word_index] <= w_data;
                end
                default: begin
                    // Do nothing for invalid mem_size
                end 
            endcase
        end
    end

    always @(*) begin
        if (r_en && addr_in_range) begin
            case (mem_size)
                2'b00: begin // Byte
                    r_data = load_unsigned
                        ? {24'b0, memory[word_index][(addr[1:0] * 8) +: 8]}
                        : {{24{memory[word_index][(addr[1:0] * 8) + 7]}},
                        memory[word_index][(addr[1:0] * 8) +: 8]};
                end
                2'b01: begin // Half-word
                    r_data = load_unsigned
                        ? {16'b0, memory[word_index][(addr[1] * 16) +: 16]}
                        : {{16{memory[word_index][(addr[1] * 16) + 15]}},
                            memory[word_index][(addr[1] * 16) +: 16]};
                end
                2'b10: begin // Word
                    r_data = memory[word_index];
                end
                default: begin
                    r_data = 32'b0; // Default to zero for invalid mem_size
                end
            endcase
        end else begin
            r_data = 32'b0; // 0 when not reading
        end
    end
    
endmodule