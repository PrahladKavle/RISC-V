`timescale 1ns/1ps

module tb_instruction_memory;

    reg [31:0] addr;
    wire [31:0] instruction;

    integer tests;
    integer failures;

    instruction_memory #(
        .DEPTH(256),
        .ADDR_WIDTH(8),
        .INIT_FILE("tb/instruction_mem_test.hex")
    ) dut (
        .addr(addr),
        .instruction(instruction)
    );

    task check_instruction;
        input [31:0] test_addr;
        input [31:0] expected_instruction;

        begin
            addr = test_addr;
            #1;

            tests = tests + 1;

            if (instruction !== expected_instruction) begin
                failures = failures + 1;
                $display(
                    "FAIL: addr=%0d expected=%h actual=%h",
                    test_addr,
                    expected_instruction,
                    instruction
                );
            end else begin
                $display(
                    "PASS: addr=%0d instruction=%h",
                    test_addr,
                    instruction
                );
            end
        end
    endtask

    initial begin
        addr = 32'd0;
        tests = 0;
        failures = 0;

        // Aligned instruction addresses
        check_instruction(32'd0,  32'h11111111);
        check_instruction(32'd4,  32'h22222222);
        check_instruction(32'd8,  32'h33333333);
        check_instruction(32'd12, 32'h44444444);

        // Bottom two address bits are ignored
        check_instruction(32'd1, 32'h11111111);
        check_instruction(32'd2, 32'h11111111);
        check_instruction(32'd3, 32'h11111111);

        check_instruction(32'd5, 32'h22222222);
        check_instruction(32'd6, 32'h22222222);
        check_instruction(32'd7, 32'h22222222);

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL INSTRUCTION-MEMORY TESTS PASSED");
        else
            $display("INSTRUCTION-MEMORY TESTS FAILED");

        $finish;
    end

endmodule
