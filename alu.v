// ADD, SUB, AND, OR, XOR, SLT (Signed comparison)

module alu (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] ctrl,

    output reg [31:0] result,
    output reg zero
);
    localparam [3:0] ADD = 4'b0000, SUB = 4'b0001,
    AND = 4'b0010, OR = 4'b0011, XOR = 4'b0100, SLT = 4'b0101,
    SLL = 4'b0110, SRL = 4'b0111, SRA = 4'b1000, SLTU = 4'b1001;

    always @(*) begin
        case (ctrl)
            ADD:
                result = a + b;
            SUB:
                result = a - b;
            AND:
                result = a & b;
            OR:
                result = a | b;
            XOR:
                result = a ^ b;

            // Signed comparison for 32-bit integers
            SLT:
                result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;

            // Unsigned comparison for 32-bit integers
            SLTU:
                result = (a < b) ? 32'd1 : 32'd0;

            // Left shift by b[4:0]
            SLL:
                result = a << b[4:0];
            
            // Logical right shift by b[4:0]
            SRL:
                result = a >> b[4:0];

            // Arithmetic right shift by b[4:0]
            SRA:
                result = $signed(a) >>> b[4:0];

            default:
                result = 32'b0;
        endcase

        zero = (result == 0) ? 1'b1 : 1'b0;

        end
endmodule