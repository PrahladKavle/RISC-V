`timescale 1ns/1ps

module tb_phase_d;

    reg clk;
    reg rst;

    wire [31:0] pc_debug;
    wire [31:0] instruction_debug;
    wire [31:0] alu_result_debug;

    integer tests;
    integer failures;

    rv32i_core #(
        .INIT_FILE("tb/program_phaseD.hex")
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

    initial begin
        $dumpfile("test/phase_d.vcd");
        $dumpvars(0, tb_phase_d);

        clk = 1'b0;
        rst = 1'b1;
        tests = 0;
        failures = 0;

        #12;
        rst = 1'b0;

        /*
         * The hex file contains 41 instruction positions.
         * Six taken branches skip one instruction each, so the
         * processor executes 35 instructions before reaching PC 164.
         */
        repeat (35) begin
            @(posedge clk);
        end

        #1;

        // BEQ: taken and not taken
        check_register(5'd10, 32'd0);
        check_register(5'd11, 32'd1);

        // BNE: taken and not taken
        check_register(5'd12, 32'd0);
        check_register(5'd13, 32'd1);

        // BLT: taken and not taken
        check_register(5'd14, 32'd0);
        check_register(5'd15, 32'd1);

        // BGE: taken because of equality, then not taken
        check_register(5'd16, 32'd0);
        check_register(5'd17, 32'd1);

        // BLTU: taken and not taken
        check_register(5'd18, 32'd0);
        check_register(5'd19, 32'd1);

        // BGEU: taken and not taken
        check_register(5'd20, 32'd0);
        check_register(5'd21, 32'd1);

        tests = tests + 1;

        if (pc_debug !== 32'd164) begin
            failures = failures + 1;
            $display(
                "FAIL: PC expected=164 actual=%0d",
                pc_debug
            );
        end else begin
            $display("PASS: PC = 164");
        end

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL BRANCH TESTS PASSED");
        else
            $display("BRANCH TESTS FAILED");

        $finish;
    end

endmodule