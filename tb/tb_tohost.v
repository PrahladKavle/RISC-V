`timescale 1ns/1ps

/*
lui  x1, 0x10000     # x1 = 0x10000000, the tohost address
addi x2, x0, 1       # x2 = 1, your PASS value
sw   x2, 0(x1)       # write PASS to tohost
*/

module tb_tohost;

    reg clk;
    reg rst;

    wire [31:0] pc_debug;
    wire [31:0] instruction_debug;
    wire [31:0] alu_result_debug;
    wire tohost_write;
    wire [31:0] tohost_data;

    integer cycle_count;
    integer failures;

    rv32i_core #(
        .INIT_FILE("build/program.hex"),
        .DATA_INIT_FILE("build/program_data.hex")
    ) dut (
        .clk(clk),
        .rst(rst),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug),
        .alu_result_debug(alu_result_debug),
        .tohost_write(tohost_write),
        .tohost_data(tohost_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("test/tohost.vcd");
        $dumpvars(0, tb_tohost);

        clk = 1'b0;
        rst = 1'b1;
        cycle_count = 0;
        failures = 0;

        #12;
        rst = 1'b0;

        repeat (20) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;

            if (tohost_write) begin
                if (tohost_data !== 32'd1) begin
                    failures = failures + 1;
                    $display(
                        "FAIL: tohost expected PASS value 1, got %h",
                        tohost_data
                    );
                end else begin
                    $display(
                        "PASS: tohost received PASS value 1 after %0d cycles",
                        cycle_count
                    );
                end

                if (dut.reg_file.registers[5'd5] !== 32'h00010000) begin
                    failures = failures + 1;
                    $display(
                        "FAIL: x5 expected 00010000, got %h",
                        dut.reg_file.registers[5'd5]
                    );
                end else begin
                    $display("PASS: x5 = 00010000");
                end

                if (dut.reg_file.registers[5'd6] !== 32'h00000001) begin
                    failures = failures + 1;
                    $display(
                        "FAIL: x6 expected 00000001, got %h",
                        dut.reg_file.registers[5'd6]
                    );
                end else begin
                    $display("PASS: x6 = 00000001");
                end

                if (dut.reg_file.registers[5'd7] !== 32'h10000000) begin
                    failures = failures + 1;
                    $display(
                        "FAIL: x7 expected 10000000, got %h",
                        dut.reg_file.registers[5'd7]
                    );
                end else begin
                    $display("PASS: x7 = 10000000");
                end

                if (failures == 0)
                    $display("ALL TOHOST TESTS PASSED");
                else
                    $display("TOHOST TESTS FAILED");

                $finish;
            end
        end

        $display("FAIL: timeout waiting for tohost write");
        $finish;
    end

endmodule