// IMMEDIATE GENERATOR
// I-Type = ADDI, ANDI, ORI, LW
// S-Type = SW
// B-Type = BEQ
// J-Type = JAL

module imm_gen (
    input wire [31:0] instruction,
    input wire [2:0] imm_sel, // Ctrl

    output reg [31:0] imm_out
);
    localparam [2:0] Itype = 3'b000, Stype = 3'b001, 
    Btype = 3'b010, Jtype = 3'b011, Utype = 3'b100;

    always @(*) begin
        if (imm_sel == Itype) begin
            imm_out = {{20{instruction[31]}}, instruction[31:20]}; // I-Type
        end else if (imm_sel == Stype) begin
            imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S-Type
        end else if (imm_sel == Btype) begin
            imm_out = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // B-Type
        end else if (imm_sel == Jtype) begin
            imm_out = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}; // J-Type
        end else if (imm_sel == Utype) begin
            imm_out = {instruction[31:12], 12'b0}; // U-Type
        end else begin
            imm_out = 32'b0; // Default case
        end
    end

endmodule