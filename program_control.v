// It takes the next program counter value as input and 
// updates the current program counter on each clock cycle, 
// with an option to reset it to zero.

module program_control (
    input wire clk,
    input wire rst,
    input wire [31:0] next_pc,

    output reg [31:0] pc_out
);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'b0; // Reset PC to 0
        end else begin
            pc_out <= next_pc; // Update PC with next_pc value
        end
    end
endmodule