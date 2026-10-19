`timescale 1ns/1ps

module tb_phase_b;

    reg clk;
    reg rst;

    wire [31:0] pc_debug;
    wire [31:0] instruction_debug;
    wire [31:0] alu_result_debug;

    integer tests;
    integer failures;

    rv32i_core #(
        .INIT_FILE("tb/program_phaseB.hex")
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
        $dumpfile("test/phase_b.vcd");
        $dumpvars(0, tb_phase_b);

        clk = 1'b0;
        rst = 1'b1;
        tests = 0;
        failures = 0;

        #12;
        rst = 1'b0;

        // Phase B contains 19 sequential instructions.
        repeat (19) begin
            @(posedge clk);
        end

        #1;

        check_register(5'd1,  32'd1);
        check_register(5'd2,  32'd4);
        check_register(5'd3,  32'd16);
        check_register(5'd4,  32'hFFFFFFF0);
        check_register(5'd5,  32'd2);

        // R-type additions
        check_register(5'd6,  32'h3FFFFFFC);
        check_register(5'd7,  32'hFFFFFFFC);
        check_register(5'd10, 32'd0);
        check_register(5'd11, 32'd1);

        // I-type additions
        check_register(5'd12, 32'd32);
        check_register(5'd13, 32'h1FFFFFFE);
        check_register(5'd14, 32'hFFFFFFFE);
        check_register(5'd15, 32'd1);
        check_register(5'd16, 32'd0);
        check_register(5'd17, 32'd1);
        check_register(5'd18, 32'd0);
        check_register(5'd19, 32'd14);

        tests = tests + 1;

        if (pc_debug !== 32'd76) begin
            failures = failures + 1;
            $display(
                "FAIL: PC expected=76 actual=%0d",
                pc_debug
            );
        end else begin
            $display("PASS: PC = 76");
        end

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL PHASE B TESTS PASSED");
        else
            $display("PHASE B TESTS FAILED");

        $finish;
    end

endmodule
