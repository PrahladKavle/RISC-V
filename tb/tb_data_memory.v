`timescale 1ns/1ps

module tb_data_memory;

    reg clk;
    reg [31:0] addr;
    reg [31:0] w_data;
    reg w_en;
    reg r_en;
    reg [1:0] mem_size;
    reg load_unsigned;

    wire [31:0] r_data;

    integer tests;
    integer failures;

    localparam [1:0]
        MEM_BYTE = 2'b00,
        MEM_HALF = 2'b01,
        MEM_WORD = 2'b10;

    data_memory dut (
        .clk(clk),
        .addr(addr),
        .w_data(w_data),
        .w_en(w_en),
        .r_en(r_en),
        .mem_size(mem_size),
        .load_unsigned(load_unsigned),
        .r_data(r_data)
    );

    always #5 clk = ~clk;

    task write_access;
        input [31:0] test_addr;
        input [31:0] test_data;
        input [1:0] test_size;

        begin
            addr = test_addr;
            w_data = test_data;
            mem_size = test_size;
            load_unsigned = 1'b0;
            w_en = 1'b1;
            r_en = 1'b0;

            @(posedge clk);
            #1;
            w_en = 1'b0;
        end
    endtask

    task check_read;
        input [127:0] test_name;
        input [31:0] test_addr;
        input [1:0] test_size;
        input test_unsigned;
        input [31:0] expected_data;

        begin
            addr = test_addr;
            mem_size = test_size;
            load_unsigned = test_unsigned;
            r_en = 1'b1;
            #1;

            tests = tests + 1;

            if (r_data !== expected_data) begin
                failures = failures + 1;
                $display(
                    "FAIL: %0s expected=%h actual=%h",
                    test_name,
                    expected_data,
                    r_data
                );
            end else begin
                $display("PASS: %0s = %h", test_name, r_data);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        addr = 32'd0;
        w_data = 32'd0;
        w_en = 1'b0;
        r_en = 1'b0;
        mem_size = MEM_WORD;
        load_unsigned = 1'b0;
        tests = 0;
        failures = 0;

        #1;
        tests = tests + 1;

        if (r_data !== 32'd0) begin
            failures = failures + 1;
            $display("FAIL: disabled read expected zero");
        end else begin
            $display("PASS: disabled read produces zero");
        end

        write_access(32'd0, 32'h80FF7F01, MEM_WORD);

        check_read("LW",  32'd0, MEM_WORD, 1'b0, 32'h80FF7F01);
        check_read("LB positive", 32'd0, MEM_BYTE, 1'b0, 32'h00000001);
        check_read("LB -1", 32'd2, MEM_BYTE, 1'b0, 32'hFFFFFFFF);
        check_read("LBU 0xFF", 32'd2, MEM_BYTE, 1'b1, 32'h000000FF);
        check_read("LB 0x80", 32'd3, MEM_BYTE, 1'b0, 32'hFFFFFF80);
        check_read("LBU 0x80", 32'd3, MEM_BYTE, 1'b1, 32'h00000080);
        check_read("LH positive", 32'd0, MEM_HALF, 1'b0, 32'h00007F01);
        check_read("LH negative", 32'd2, MEM_HALF, 1'b0, 32'hFFFF80FF);
        check_read("LHU", 32'd2, MEM_HALF, 1'b1, 32'h000080FF);

        write_access(32'd4, 32'hAABBCCDD, MEM_WORD);
        write_access(32'd5, 32'h00000011, MEM_BYTE);
        check_read("SB preserves lanes", 32'd4, MEM_WORD, 1'b0, 32'hAABB11DD);

        write_access(32'd6, 32'h00002233, MEM_HALF);
        check_read("SH preserves lanes", 32'd4, MEM_WORD, 1'b0, 32'h223311DD);

        addr = 32'd4;
        w_data = 32'hFFFFFFFF;
        mem_size = MEM_WORD;
        w_en = 1'b0;
        r_en = 1'b0;
        @(posedge clk);
        #1;
        check_read("disabled write", 32'd4, MEM_WORD, 1'b0, 32'h223311DD);

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
