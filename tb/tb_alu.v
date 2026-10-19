`timescale 1ns/1ps

module tb_alu;

    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] ctrl;

    wire [31:0] result;
    wire zero;

    localparam [3:0]
        ADD = 4'b0000,
        SUB = 4'b0001,
        AND = 4'b0010,
        OR  = 4'b0011,
        XOR = 4'b0100,
        SLT = 4'b0101,
        SLL = 4'b0110,
        SRL = 4'b0111,
        SRA = 4'b1000,
        SLTU = 4'b1001;

    alu dut (
        .a(a),
        .b(b),
        .ctrl(ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        // ADD: 10 + 20 = 30
        a = 32'd10;
        b = 32'd20;
        ctrl = ADD;
        #1;

        if ((result !== 32'd30) || (zero !== 1'b0))
            $display("FAIL: ADD");
        else
            $display("PASS: ADD");

        // ADD resulting in zero
        a = 32'd0;
        b = 32'd0;
        ctrl = ADD;
        #1;

        if ((result !== 32'd0) || (zero !== 1'b1))
            $display("FAIL: ADD zero");
        else
            $display("PASS: ADD zero");

        // SUB: 20 - 5 = 15
        a = 32'd20;
        b = 32'd5;
        ctrl = SUB;
        #1;

        if ((result !== 32'd15) || (zero !== 1'b0))
            $display("FAIL: SUB");
        else
            $display("PASS: SUB");

        // SUB equal operands
        a = 32'd20;
        b = 32'd20;
        ctrl = SUB;
        #1;

        if ((result !== 32'd0) || (zero !== 1'b1))
            $display("FAIL: SUB zero");
        else
            $display("PASS: SUB zero");

        // AND
        a = 32'b1100;
        b = 32'b1010;
        ctrl = AND;
        #1;

        if (result !== 32'b1000)
            $display("FAIL: AND");
        else
            $display("PASS: AND");

        // OR
        a = 32'b1100;
        b = 32'b1010;
        ctrl = OR;
        #1;

        if (result !== 32'b1110)
            $display("FAIL: OR");
        else
            $display("PASS: OR");

        // XOR
        a = 32'b1100;
        b = 32'b1010;
        ctrl = XOR;
        #1;

        if (result !== 32'b0110)
            $display("FAIL: XOR");
        else
            $display("PASS: XOR");

        // Signed SLT: 5 < 10
        a = 32'd5;
        b = 32'd10;
        ctrl = SLT;
        #1;

        if (result !== 32'd1)
            $display("FAIL: SLT positive");
        else
            $display("PASS: SLT positive");

        // Signed SLT: 10 < 5 is false
        a = 32'd10;
        b = 32'd5;
        ctrl = SLT;
        #1;

        if (result !== 32'd0)
            $display("FAIL: SLT false");
        else
            $display("PASS: SLT false");

        // Signed SLT: -1 < 1
        a = 32'hFFFFFFFF;
        b = 32'd1;
        ctrl = SLT;
        #1;

        if (result !== 32'd1)
            $display("FAIL: SLT negative");
        else
            $display("PASS: SLT negative");

        // Signed SLT: 1 < -1 is false
        a = 32'd1;
        b = 32'hFFFFFFFF;
        ctrl = SLT;
        #1;

        if (result !== 32'd0)
            $display("FAIL: SLT positive vs negative");
        else
            $display("PASS: SLT positive vs negative");

        // SLL: 1 << 4 = 16
        a = 32'd1;
        b = 32'd4;
        ctrl = SLL;
        #1;

        if (result !== 32'd16)
            $display("FAIL: SLL");
        else
            $display("PASS: SLL");

        // SRL fills the upper bits with zeros
        a = 32'hFFFFFFF0;
        b = 32'd2;
        ctrl = SRL;
        #1;

        if (result !== 32'h3FFFFFFC)
            $display("FAIL: SRL");
        else
            $display("PASS: SRL");

        // SRA preserves the sign bit
        a = 32'hFFFFFFF0;
        b = 32'd2;
        ctrl = SRA;
        #1;

        if (result !== 32'hFFFFFFFC)
            $display("FAIL: SRA");
        else
            $display("PASS: SRA");

        // Unsigned comparison: 1 < 0xFFFFFFFF
        a = 32'd1;
        b = 32'hFFFFFFFF;
        ctrl = SLTU;
        #1;

        if (result !== 32'd1)
            $display("FAIL: SLTU");
        else
            $display("PASS: SLTU");

        // Unsupported control value
        a = 32'd10;
        b = 32'd20;
        ctrl = 4'b1111;
        #1;

        if ((result !== 32'd0) || (zero !== 1'b1))
            $display("FAIL: default control");
        else
            $display("PASS: default control");

        $display("ALU tests complete");
        $finish;
    end

endmodule
