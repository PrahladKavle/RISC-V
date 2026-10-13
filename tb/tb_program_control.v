`timescale 1ns/1ps

module tb_program_control;

    reg clk;
    reg rst;
    reg [31:0] next_pc;

    wire [31:0] pc_out;

    integer failures;

    program_control dut (
        .clk(clk),
        .rst(rst),
        .next_pc(next_pc),
        .pc_out(pc_out)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        next_pc = 32'd0;
        failures = 0;

        // Test asynchronous reset
        #1;
        rst = 1'b1;
        #1;

        if (pc_out !== 32'd0) begin
            $display("FAIL: reset did not set PC to zero");
            failures = failures + 1;
        end else begin
            $display("PASS: asynchronous reset");
        end

        rst = 1'b0;

        // Test first PC update
        next_pc = 32'd4;

        @(posedge clk);
        #1;

        if (pc_out !== 32'd4) begin
            $display("FAIL: expected PC=4, got %d", pc_out);
            failures = failures + 1;
        end else begin
            $display("PASS: PC updated to 4");
        end

        // Change next_pc between clock edges
        next_pc = 32'd8;
        #2;

        if (pc_out !== 32'd4) begin
            $display("FAIL: PC changed without a rising edge");
            failures = failures + 1;
        end else begin
            $display("PASS: PC holds value between clock edges");
        end

        // Test second PC update
        @(posedge clk);
        #1;

        if (pc_out !== 32'd8) begin
            $display("FAIL: expected PC=8, got %d", pc_out);
            failures = failures + 1;
        end else begin
            $display("PASS: PC updated to 8");
        end

        // Confirm reset acts without waiting for another clock edge
        next_pc = 32'd12;
        #2;
        rst = 1'b1;
        #1;

        if (pc_out !== 32'd0) begin
            $display("FAIL: asynchronous reset was not immediate");
            failures = failures + 1;
        end else begin
            $display("PASS: asynchronous reset is immediate");
        end

        rst = 1'b0;
        next_pc = 32'd16;

        @(posedge clk);
        #1;

        if (pc_out !== 32'd16) begin
            $display("FAIL: PC did not resume after reset");
            failures = failures + 1;
        end else begin
            $display("PASS: PC resumed after reset");
        end

        if (failures == 0)
            $display("ALL PC TESTS PASSED");
        else
            $display("PC TESTS FAILED: %0d failure(s)", failures);

        $finish;
    end

endmodule