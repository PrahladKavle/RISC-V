`timescale 1ns/1ps

module tb_phase_e;

    reg clk;
    reg rst;

    wire [31:0] pc_debug;
    wire [31:0] instruction_debug;
    wire [31:0] alu_result_debug;

    integer tests;
    integer failures;

    rv32i_core #(
        .INIT_FILE("tb/program_phaseE.hex")
    ) dut (
        .clk(clk),
        .rst(rst),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug),
        .alu_result_debug(alu_result_debug)
    );

    always #5 clk = ~clk;

    task check_value;
        input [8*24-1:0] name;
        input [31:0] actual_value;
        input [31:0] expected_value;
        begin
            tests = tests + 1;
            if (actual_value !== expected_value) begin
                failures = failures + 1;
                $display("FAIL: %0s expected=%h actual=%h", name, expected_value, actual_value);
            end else begin
                $display("PASS: %0s = %h", name, expected_value);
            end
        end
    endtask

    task run_to_system_instruction;
        begin
            repeat (4) @(posedge clk);
            #1;
        end
    endtask

    initial begin
        $dumpfile("test/phase_e.vcd");
        $dumpvars(0, tb_phase_e);

        clk = 1'b0;
        rst = 1'b1;
        tests = 0;
        failures = 0;

        #12;
        rst = 1'b0;

        // FENCE advances normally, then ECALL holds the PC at address 12.
        run_to_system_instruction;
        check_value("x1 after FENCE", dut.reg_file.registers[5'd1], 32'd5);
        check_value("x2 before ECALL", dut.reg_file.registers[5'd2], 32'd0);
        check_value("ECALL PC", pc_debug, 32'd12);
        check_value("ECALL trap", {31'd0, dut.trap}, 32'd1);
        check_value("ECALL breakpoint", {31'd0, dut.breakpoint}, 32'd0);

        // Replace the halted ECALL with EBREAK, reset the PC, and rerun.
        dut.instruction_mem.memory[3] = 32'h00100073;
        rst = 1'b1;
        @(posedge clk);
        #1;
        rst = 1'b0;

        run_to_system_instruction;
        check_value("EBREAK PC", pc_debug, 32'd12);
        check_value("EBREAK trap", {31'd0, dut.trap}, 32'd1);
        check_value("EBREAK breakpoint", {31'd0, dut.breakpoint}, 32'd1);
        check_value("x2 remains zero", dut.reg_file.registers[5'd2], 32'd0);

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL PHASE E TESTS PASSED");
        else
            $display("PHASE E TESTS FAILED");

        $finish;
    end

endmodule
