// This is a testbench for the RISC-V core that tests Phase A of the project. 
// It initializes the core with a specific program and checks the values of 
// registers and memory after execution.


`timescale 1ns/1ps

module tb_phase_a;

    reg clk;
    reg rst;

    wire [31:0] pc_debug;
    wire [31:0] instruction_debug;
    wire [31:0] alu_result_debug;

    integer failures;
    integer tests;

    rv32i_core #(
        .INIT_FILE("tb/program_phaseA.hex")
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
                    "FAIL: x%0d expected=%0d actual=%h",
                    register_number,
                    expected_value,
                    dut.reg_file.registers[register_number]
                );
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
        $dumpfile("test/phase_a.vcd");
        $dumpvars(0, tb_phase_a);

        clk = 1'b0;
        rst = 1'b1;
        failures = 0;
        tests = 0;

        // Hold reset through first clock edge
        #12;
        rst = 1'b0;

        // Twenty static instructions exist.
        // BEQ and JAL each skip one, so 18 execute.
        repeat (18) begin
            @(posedge clk);
        end

        #1;

        check_register(5'd1,  32'd12);
        check_register(5'd2,  32'd5);
        check_register(5'd3,  32'd17);
        check_register(5'd4,  32'd7);
        check_register(5'd5,  32'd4);
        check_register(5'd6,  32'd13);
        check_register(5'd7,  32'd9);
        check_register(5'd8,  32'd1);
        check_register(5'd9,  32'd8);
        check_register(5'd10, 32'd13);
        check_register(5'd11, 32'd17);
        check_register(5'd12, 32'd1);
        check_register(5'd13, 32'd64);
        check_register(5'd15, 32'd18);
        check_register(5'd16, 32'd22);

        tests = tests + 1;

        if (dut.data_mem.memory[0] !== 32'd17) begin
            failures = failures + 1;

            $display(
                "FAIL: memory[0] expected=17 actual=%h",
                dut.data_mem.memory[0]
            );
        end else begin
            $display("PASS: memory[0] = 17");
        end

        tests = tests + 1;

        if (pc_debug !== 32'd80) begin
            failures = failures + 1;
            $display("FAIL: PC expected=80 actual=%0d", pc_debug);
        end else begin
            $display("PASS: PC = 80");
        end

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL PHASE A TESTS PASSED");
        else
            $display("PHASE A TESTS FAILED");

        $finish;
    end

endmodule