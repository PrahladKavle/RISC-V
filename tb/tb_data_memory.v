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
    wire tohost_write;
    wire [31:0] tohost_data;

    integer tests;
    integer failures;

    localparam [31:0] DATA_BASE = 32'h00010000;
    localparam [31:0] TOHOST_ADDR = 32'h10000000;

    localparam [1:0]
        MEM_BYTE = 2'b00,
        MEM_HALF = 2'b01,
        MEM_WORD = 2'b10;

    data_memory #(
        .DEPTH(16384),
        .ADDR_WIDTH(14),
        .BASE_ADDR(DATA_BASE),
        .TOHOST_ADDR(TOHOST_ADDR),
        .INIT_FILE("tb/data_memory_init.hex")
    ) dut (
        .clk(clk),
        .addr(addr),
        .w_data(w_data),
        .w_en(w_en),
        .r_en(r_en),
        .mem_size(mem_size),
        .load_unsigned(load_unsigned),
        .r_data(r_data),
        .tohost_write(tohost_write),
        .tohost_data(tohost_data)
    );

    always #5 clk = ~clk;

    task write_access;
        input [31:0] test_addr;
        input [31:0] test_data;
        input [1:0] test_size;

        begin
            @(negedge clk);

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
        input [8*32-1:0] test_name;
        input [31:0] test_addr;
        input [1:0] test_size;
        input test_unsigned;
        input [31:0] expected_data;

        begin
            addr = test_addr;
            mem_size = test_size;
            load_unsigned = test_unsigned;
            w_en = 1'b0;
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

    task check_tohost;
        input [31:0] expected_data;

        begin
            tests = tests + 1;

            if (tohost_write !== 1'b1 ||
                tohost_data !== expected_data) begin

                failures = failures + 1;
                $display(
                    "FAIL: tohost expected_write=1 actual_write=%b expected_data=%h actual_data=%h",
                    tohost_write,
                    expected_data,
                    tohost_data
                );
            end else begin
                $display("PASS: tohost data = %h", tohost_data);
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

        // Hex line 0 maps to DATA_BASE; line 1 maps to DATA_BASE + 4.
        check_read("initial word 0", DATA_BASE, MEM_WORD, 1'b0, 32'hDEADBEEF);
        check_read("initial word 1", DATA_BASE + 32'd4, MEM_WORD, 1'b0, 32'h01234567);

        write_access(DATA_BASE, 32'h80FF7F01, MEM_WORD);

        check_read("LW", DATA_BASE, MEM_WORD, 1'b0, 32'h80FF7F01);
        check_read("LB positive", DATA_BASE, MEM_BYTE, 1'b0, 32'h00000001);
        check_read("LB -1", DATA_BASE + 32'd2, MEM_BYTE, 1'b0, 32'hFFFFFFFF);
        check_read("LBU 0xFF", DATA_BASE + 32'd2, MEM_BYTE, 1'b1, 32'h000000FF);
        check_read("LB 0x80", DATA_BASE + 32'd3, MEM_BYTE, 1'b0, 32'hFFFFFF80);
        check_read("LBU 0x80", DATA_BASE + 32'd3, MEM_BYTE, 1'b1, 32'h00000080);
        check_read("LH positive", DATA_BASE, MEM_HALF, 1'b0, 32'h00007F01);
        check_read("LH negative", DATA_BASE + 32'd2, MEM_HALF, 1'b0, 32'hFFFF80FF);
        check_read("LHU", DATA_BASE + 32'd2, MEM_HALF, 1'b1, 32'h000080FF);

        write_access(DATA_BASE + 32'd4, 32'hAABBCCDD, MEM_WORD);
        write_access(DATA_BASE + 32'd5, 32'h00000011, MEM_BYTE);
        check_read("SB preserves lanes", DATA_BASE + 32'd4, MEM_WORD, 1'b0, 32'hAABB11DD);

        write_access(DATA_BASE + 32'd6, 32'h00002233, MEM_HALF);
        check_read("SH preserves lanes", DATA_BASE + 32'd4, MEM_WORD, 1'b0, 32'h223311DD);

        write_access(32'h00000000, 32'hDEADBEEF, MEM_WORD);
        check_read("invalid write blocked", DATA_BASE, MEM_WORD, 1'b0, 32'h80FF7F01);
        check_read("invalid read zero", 32'h00000000, MEM_WORD, 1'b0, 32'h00000000);

        write_access(TOHOST_ADDR, 32'd1, MEM_WORD);
        check_tohost(32'd1);

        check_read(
            "tohost does not modify RAM",
            DATA_BASE,
            MEM_WORD,
            1'b0,
            32'h80FF7F01
        );

        check_read(
            "tohost read zero",
            TOHOST_ADDR,
            MEM_WORD,
            1'b0,
            32'h00000000
        );

        @(posedge clk);
        #1;
        tests = tests + 1;

        if (tohost_write !== 1'b0) begin
            failures = failures + 1;
            $display("FAIL: tohost_write did not clear");
        end else begin
            $display("PASS: tohost_write clears after one clock");
        end

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