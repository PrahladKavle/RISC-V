`timescale 1ns/1ps

module tb_alu;

    reg [31:0] a;
    reg [31:0] b;
    reg [2:0] ctrl;

    wire [31:0] result;
    wire zero;

    localparam [2:0]
        ADD = 3'b000,
        SUB = 3'b001,
        AND = 3'b010,
        OR  = 3'b011,
        XOR = 3'b100,
        SLT = 3'b101;

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

        // Unsupported control value
        a = 32'd10;
        b = 32'd20;
        ctrl = 3'b111;
        #1;

        if ((result !== 32'd0) || (zero !== 1'b1))
            $display("FAIL: default control");
        else
            $display("PASS: default control");

        $display("ALU tests complete");
        $finish;
    end

endmodule