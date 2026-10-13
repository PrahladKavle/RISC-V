// ADD, SUB, AND, OR, XOR, SLT (Signed comparison)

module alu (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] ctrl,

    output reg [31:0] result,
    output reg zero
);
    localparam [2:0] ADD = 3'b000, SUB = 3'b001,
    AND = 3'b010, OR = 3'b011, XOR = 3'b100, SLT = 3'b101;

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
            SLT:
                result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            default:
                result = 32'b0;
        endcase

        zero = (result == 0) ? 1'b1 : 1'b0;

        end
endmodule