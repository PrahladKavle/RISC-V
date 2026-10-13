`timescale 1ns/1ps

module tb_data_memory;

    reg clk;
    reg [31:0] addr;
    reg [31:0] w_data;
    reg w_en;
    reg r_en;

    wire [31:0] r_data;

    integer tests;
    integer failures;

    data_memory dut (
        .clk(clk),
        .addr(addr),
        .w_data(w_data),
        .w_en(w_en),
        .r_en(r_en),
        .r_data(r_data)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    task write_word;
        input [31:0] test_addr;
        input [31:0] test_data;

        begin
            addr = test_addr;
            w_data = test_data;
            w_en = 1'b1;
            r_en = 1'b0;

            @(posedge clk);
            #1;

            w_en = 1'b0;
        end
    endtask

    task check_read;
        input [31:0] test_addr;
        input [31:0] expected_data;

        begin
            addr = test_addr;
            r_en = 1'b1;
            #1;

            tests = tests + 1;

            if (r_data !== expected_data) begin
                failures = failures + 1;
                $display(
                    "FAIL: addr=%0d expected=%h actual=%h",
                    test_addr,
                    expected_data,
                    r_data
                );
            end else begin
                $display(
                    "PASS: addr=%0d data=%h",
                    test_addr,
                    r_data
                );
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        addr = 32'd0;
        w_data = 32'd0;
        w_en = 1'b0;
        r_en = 1'b0;

        tests = 0;
        failures = 0;

        // Read disabled should produce zero
        #1;
        tests = tests + 1;

        if (r_data !== 32'd0) begin
            failures = failures + 1;
            $display("FAIL: disabled read expected zero");
        end else begin
            $display("PASS: disabled read produces zero");
        end

        // Write three distinct memory words
        write_word(32'd0, 32'hDEADBEEF);
        write_word(32'd4, 32'hCAFEBABE);
        write_word(32'd8, 32'h12345678);

        // Read them back
        check_read(32'd0, 32'hDEADBEEF);
        check_read(32'd4, 32'hCAFEBABE);
        check_read(32'd8, 32'h12345678);

        // Attempt to overwrite address 4 with writing disabled
        addr = 32'd4;
        w_data = 32'hFFFFFFFF;
        w_en = 1'b0;
        r_en = 1'b0;

        @(posedge clk);
        #1;

        check_read(32'd4, 32'hCAFEBABE);

        // Verify write does not occur before the rising edge
        addr = 32'd0;
        w_data = 32'hAAAAAAAA;
        w_en = 1'b1;
        r_en = 1'b1;

        #2;
        tests = tests + 1;

        if (r_data !== 32'hDEADBEEF) begin
            failures = failures + 1;
            $display("FAIL: memory changed before rising edge");
        end else begin
            $display("PASS: write waits for rising edge");
        end

        @(posedge clk);
        #1;
        w_en = 1'b0;

        check_read(32'd0, 32'hAAAAAAAA);

        // Addresses 0-3 select the same word for Phase A
        check_read(32'd1, 32'hAAAAAAAA);
        check_read(32'd2, 32'hAAAAAAAA);
        check_read(32'd3, 32'hAAAAAAAA);

        // Disable reading again
        r_en = 1'b0;
        #1;

        tests = tests + 1;

        if (r_data !== 32'd0) begin
            failures = failures + 1;
            $display("FAIL: r_en=0 did not produce zero");
        end else begin
            $display("PASS: r_en disables read output");
        end

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL DATA-MEMORY TESTS PASSED");
        else
            $display("DATA-MEMORY TESTS FAILED");

        $finish;
    end

endmodule