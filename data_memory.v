module data_memory (
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] w_data,
    input wire w_en,
    input wire r_en,

    output reg [31:0] r_data
);

    reg [31:0] memory [0:1023]; // 1K x 32-bit memory

    always @(posedge clk) begin
        if (w_en) begin
            memory[addr[11:2]] <= w_data; // Write data to memory
        end
    end

    always @(*) begin
        if (r_en) begin
            r_data = memory[addr[11:2]]; // Read data from memory
        end else begin
            r_data = 32'b0; // 0 when not reading
        end
    end
    
endmodule