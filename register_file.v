// It contains 32 registers, each 32 bits wide. 
// The register file supports reading from two registers and 
// writing to one register on the rising edge of the clock signal.

module register_file (
    input wire clk,
    input wire [4:0] rs1, // Read Address 1
    input wire [4:0] rs2, // Read Address 2
    input wire [4:0] ws, // Write Address
    input wire [31:0] w_data, //  Write Data
    input wire w_en, // Write Enable

    output reg [31:0] rs1_data, // Read Data 1
    output reg [31:0] rs2_data // Read Data 2
);
    reg [31:0] registers [31:0]; // 32 registers of 32 bits

    always @(posedge clk) begin
        if (w_en && ws != 5'b0) begin // Write to register if write enable is high and not writing to x0
            registers[ws] <= w_data;
        end
    end

    always @(*) begin
        // Read data from registers
        rs1_data = (rs1 == 5'b0) ? 32'b0 : registers[rs1]; // x0 is always 0
        rs2_data = (rs2 == 5'b0) ? 32'b0 : registers[rs2]; // x0 is always 0
    end

endmodule