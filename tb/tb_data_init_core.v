`timescale 1ns/1ps

module tb_data_init_core;

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
        .INIT_FILE("tb/program_data_init.hex"),
        .DATA_INIT_FILE("tb/data_memory_init.hex")
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
        $dumpfile("test/data_init_core.vcd");
        $dumpvars(0, tb_data_init_core);

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
                if (tohost_data !== 32'hDEADBEEF) begin
                    failures = failures + 1;
                    $display(
                        "FAIL: tohost expected DEADBEEF, got %h",
                        tohost_data
                    );
                end else begin
                    $display(
                        "PASS: loaded data reached tohost after %0d cycles",
                        cycle_count
                    );
                end

                if (dut.reg_file.registers[5'd1] !== 32'h00010000) begin
                    failures = failures + 1;
                    $display("FAIL: x1 = %h", dut.reg_file.registers[5'd1]);
                end else begin
                    $display("PASS: x1 = 00010000");
                end

                if (dut.reg_file.registers[5'd2] !== 32'hDEADBEEF) begin
                    failures = failures + 1;
                    $display("FAIL: x2 = %h", dut.reg_file.registers[5'd2]);
                end else begin
                    $display("PASS: x2 = DEADBEEF");
                end

                if (dut.reg_file.registers[5'd3] !== 32'h10000000) begin
                    failures = failures + 1;
                    $display("FAIL: x3 = %h", dut.reg_file.registers[5'd3]);
                end else begin
                    $display("PASS: x3 = 10000000");
                end

                if (failures == 0)
                    $display("ALL DATA-INIT CORE TESTS PASSED");
                else
                    $display("DATA-INIT CORE TESTS FAILED");

                $finish;
            end
        end

        $display("FAIL: timeout waiting for tohost write");
        $finish;
    end

endmodule