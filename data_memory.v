module data_memory (
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] w_data,
    input wire w_en,
    input wire r_en,
    input wire [1:0] mem_size,
    input wire load_unsigned,

    output reg [31:0] r_data
);

    reg [31:0] memory [0:1023]; // 1K x 32-bit memory

    always @(posedge clk) begin
        if (w_en) begin
            case (mem_size)
                2'b00: begin // Byte
                    memory[addr[11:2]][(addr[1:0] * 8) +: 8] <= w_data[7:0];
                end
                2'b01: begin // Half-word
                    memory[addr[11:2]][(addr[1] * 16) +: 16] <= w_data[15:0];
                end
                2'b10: begin // Word
                    memory[addr[11:2]] <= w_data;
                end
                default: begin
                    // Do nothing for invalid mem_size
                end 
            endcase
        end
    end

    always @(*) begin
        if (r_en) begin
            case (mem_size)
                2'b00: begin // Byte
                    r_data = load_unsigned
                        ? {24'b0, memory[addr[11:2]][(addr[1:0] * 8) +: 8]}
                        : {{24{memory[addr[11:2]][(addr[1:0] * 8) + 7]}},
                        memory[addr[11:2]][(addr[1:0] * 8) +: 8]};
                end
                2'b01: begin // Half-word
                    r_data = load_unsigned
                        ? {16'b0, memory[addr[11:2]][(addr[1] * 16) +: 16]}
                        : {{16{memory[addr[11:2]][(addr[1] * 16) + 15]}},
                            memory[addr[11:2]][(addr[1] * 16) +: 16]};
                end
                2'b10: begin // Word
                    r_data = memory[addr[11:2]];
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