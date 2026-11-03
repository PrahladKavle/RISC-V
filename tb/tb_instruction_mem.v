`timescale 1ns/1ps

module tb_instruction_memory;

    reg [31:0] addr;
    wire [31:0] instruction;
    wire instruction_valid;

    integer tests;
    integer failures;

    instruction_memory #(
        .INIT_FILE("tb/instruction_mem_test.hex")
    ) dut (
        .addr(addr),
        .instruction(instruction),
        .instruction_valid(instruction_valid)
    );

    task check_fetch;
        input [31:0] test_addr;
        input expected_valid;
        input [31:0] expected_instruction;

        begin
            addr = test_addr;
            #1;

            tests = tests + 1;

            if (instruction_valid !== expected_valid ||
                instruction !== expected_instruction) begin

                failures = failures + 1;
                $display(
                    "FAIL: addr=%h expected_valid=%b actual_valid=%b expected_instruction=%h actual_instruction=%h",
                    test_addr,
                    expected_valid,
                    instruction_valid,
                    expected_instruction,
                    instruction
                );
            end else begin
                $display(
                    "PASS: addr=%h valid=%b instruction=%h",
                    test_addr,
                    instruction_valid,
                    instruction
                );
            end
        end
    endtask

    initial begin
        addr = 32'd0;
        tests = 0;
        failures = 0;

        // The short hex file initializes words 0–3.
        // Set the final 64 KiB ROM word directly for this boundary test.
        dut.memory[16383] = 32'hDEADBEEF;

        // Normal in-range reads
        check_fetch(32'h00000000, 1'b1, 32'h11111111);
        check_fetch(32'h00000004, 1'b1, 32'h22222222);
        check_fetch(32'h00000008, 1'b1, 32'h33333333);
        check_fetch(32'h0000000C, 1'b1, 32'h44444444);

        // Final valid 32-bit instruction address in 64 KiB ROM
        check_fetch(32'h0000FFFC, 1'b1, 32'hDEADBEEF);

        // First invalid address: must not alias to memory word zero
        check_fetch(32'h00010000, 1'b0, 32'h00000000);

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL INSTRUCTION-MEMORY TESTS PASSED");
        else
            $display("INSTRUCTION-MEMORY TESTS FAILED");

        $finish;
    end

endmodule