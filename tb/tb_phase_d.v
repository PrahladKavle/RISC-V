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
         * The program contains 55 instruction positions.
         * Taken branches and JALR instructions skip nine positions,
         * so 46 instructions are actually executed.
         */
        repeat (46) begin
            @(posedge clk);
        end

        #1;

        // BEQ
        check_register(5'd10, 32'd0); // Taken
        check_register(5'd11, 32'd1); // Not taken

        // BNE
        check_register(5'd12, 32'd0); // Taken
        check_register(5'd13, 32'd1); // Not taken

        // BLT
        check_register(5'd14, 32'd0); // Taken
        check_register(5'd15, 32'd1); // Not taken

        // BGE
        check_register(5'd16, 32'd0); // Taken on equality
        check_register(5'd17, 32'd1); // Not taken

        // BLTU
        check_register(5'd18, 32'd0); // Taken
        check_register(5'd19, 32'd1); // Not taken

        // BGEU
        check_register(5'd20, 32'd0); // Taken
        check_register(5'd21, 32'd1); // Not taken

        // LUI
        check_register(5'd22, 32'h12345000);
        check_register(5'd27, 32'hABCDE000);

        // AUIPC
        check_register(5'd23, 32'h000010A8);
        check_register(5'd28, 32'h000000C4);

        // First JALR
        check_register(5'd25, 32'd193);
        check_register(5'd26, 32'd184);
        check_register(5'd24, 32'd0);

        // Second JALR
        check_register(5'd30, 32'd217);
        check_register(5'd31, 32'd212);
        check_register(5'd29, 32'd0);

        // Program reached its final instruction
        check_register(5'd9, 32'd9);

        tests = tests + 1;

        if (pc_debug !== 32'd220) begin
            failures = failures + 1;
            $display(
                "FAIL: PC expected=220 actual=%0d",
                pc_debug
            );
        end else begin
            $display("PASS: PC = 220");
        end

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL PHASE D TESTS PASSED");
        else
            $display("PHASE D TESTS FAILED");

        $finish;
    end

endmodule