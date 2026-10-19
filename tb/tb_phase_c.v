`timescale 1ns/1ps

module tb_memory_instructions;

    reg clk;
    reg rst;

    wire [31:0] pc_debug;
    wire [31:0] instruction_debug;
    wire [31:0] alu_result_debug;

    integer tests;
    integer failures;

    rv32i_core #(
        .INIT_FILE("tb/program_phaseC.hex")
    ) dut (
        .clk(clk),
        .rst(rst),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug),
        .alu_result_debug(alu_result_debug)
    );

    always #5 clk = ~clk;

    task check_register;
        input [4:0] register_number;
        input [31:0] expected_value;

        begin
            tests = tests + 1;

            if (dut.reg_file.registers[register_number]
                !== expected_value) begin

                failures = failures + 1;

                $display(
                    "FAIL: x%0d expected=%h actual=%h",
                    register_number,
                    expected_value,
                    dut.reg_file.registers[register_number]
                );
            end else begin
                $display(
                    "PASS: x%0d = %h",
                    register_number,
                    expected_value
                );
            end
        end
    endtask

    task check_memory;
        input [9:0] word_address;
        input [31:0] expected_value;

        begin
            tests = tests + 1;

            if (dut.data_mem.memory[word_address]
                !== expected_value) begin

                failures = failures + 1;

                $display(
                    "FAIL: memory[%0d] expected=%h actual=%h",
                    word_address,
                    expected_value,
                    dut.data_mem.memory[word_address]
                );
            end else begin
                $display(
                    "PASS: memory[%0d] = %h",
                    word_address,
                    expected_value
                );
            end
        end
    endtask

    initial begin
        $dumpfile("test/phase_c.vcd");
        $dumpvars(0, tb_memory_instructions);

        clk = 1'b0;
        rst = 1'b1;
        tests = 0;
        failures = 0;

        #12;
        rst = 1'b0;

        // Execute all 23 instructions
        repeat (23) begin
            @(posedge clk);
        end

        #1;

        // Byte loads
        check_register(5'd2,  32'h80332211);
        check_register(5'd3,  32'hFFFFFF80);
        check_register(5'd4,  32'h00000080);
        check_register(5'd12, 32'h00000033);

        // Halfword loads
        check_register(5'd5, 32'hFFFFFF80);
        check_register(5'd6, 32'h0000FF80);
        check_register(5'd8, 32'h0123FF80);
        check_register(5'd9, 32'h00000123);

        // Word load/store
        check_register(5'd10, 32'h0000005A);
        check_register(5'd11, 32'h0000005A);

        // Final memory contents
        check_memory(10'd0, 32'h80332211);
        check_memory(10'd1, 32'h0123FF80);
        check_memory(10'd2, 32'h0000005A);

        tests = tests + 1;

        if (pc_debug !== 32'd92) begin
            failures = failures + 1;
            $display(
                "FAIL: PC expected=92 actual=%0d",
                pc_debug
            );
        end else begin
            $display("PASS: PC = 92");
        end

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL MEMORY INSTRUCTION TESTS PASSED");
        else
            $display("MEMORY INSTRUCTION TESTS FAILED");

        $finish;
    end

endmodule