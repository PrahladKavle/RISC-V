`timescale 1ns/1ps

module tb_rv32i_core;

    reg clk;
    reg rst;

    wire [31:0] pc_debug;
    wire [31:0] instruction_debug;
    wire [31:0] alu_result_debug;

    integer failures;

    rv32i_core #(
        .INIT_FILE("tb/program.hex")
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
            if (dut.reg_file.registers[register_number]
                !== expected_value) begin

                $display(
                    "FAIL: x%0d expected %0d, got %h",
                    register_number,
                    expected_value,
                    dut.reg_file.registers[register_number]
                );

                failures = failures + 1;
            end else begin
                $display(
                    "PASS: x%0d = %0d",
                    register_number,
                    expected_value
                );
            end
        end
    endtask

    initial begin
        $dumpfile("test/rv32i_core.vcd");
        $dumpvars(0, tb_rv32i_core);

        clk = 1'b0;
        rst = 1'b1;
        failures = 0;

        // Hold reset through the first rising edge
        #12;
        rst = 1'b0;

        // Five instructions actually execute.
        // Two instructions are skipped by JAL.
        repeat (5) begin
            @(posedge clk);
        end

        #1;

        // Prove skipped instructions did not change x1 or x2
        check_register(5'd1, 32'd1);
        check_register(5'd2, 32'd42);

        // Prove JAL wrote PC + 4 into rd
        check_register(5'd5, 32'd8);
        check_register(5'd6, 32'd20);

        // Prove the link values can be used normally
        check_register(5'd3, 32'd28);

        if (pc_debug !== 32'd28) begin
            $display(
                "FAIL: PC expected 28, got %0d",
                pc_debug
            );
            failures = failures + 1;
        end else begin
            $display("PASS: PC = 28");
        end

        if (failures == 0)
            $display("ALL JAL TESTS PASSED");
        else
            $display("JAL TESTS FAILED: %0d failure(s)", failures);

        $finish;
    end

endmodule