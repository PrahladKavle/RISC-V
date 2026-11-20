`timescale 1ns/1ps

module tb_program_bss;

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
        .INIT_FILE("build/program_bss.hex"),
        .DATA_INIT_FILE("build/program_bss_data.hex")
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
        $dumpfile("test/program_bss.vcd");
        $dumpvars(0, tb_program_bss);

        clk = 1'b0;
        rst = 1'b1;
        cycle_count = 0;
        failures = 0;

        #1;
        dut.data_mem.memory[1] = 32'hdeadbeef;

        #11;
        rst = 1'b0;

        repeat (60) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;

            if (tohost_write) begin
                if (tohost_data !== 32'd0) begin
                    failures = failures + 1;
                    $display("FAIL: tohost expected cleared BSS value 0, got %h", tohost_data);
                end else begin
                    $display("PASS: tohost received cleared BSS value after %0d cycles", cycle_count);
                end

                if (dut.data_mem.memory[1] !== 32'd0) begin
                    failures = failures + 1;
                    $display("FAIL: BSS word expected 0, got %h", dut.data_mem.memory[1]);
                end else begin
                    $display("PASS: BSS word cleared to 00000000");
                end

                if (dut.reg_file.registers[5'd28] !== 32'd0) begin
                    failures = failures + 1;
                    $display("FAIL: x28 expected 0, got %h", dut.reg_file.registers[5'd28]);
                end else begin
                    $display("PASS: x28 loaded 00000000");
                end

                if (failures == 0)
                    $display("ALL BSS STARTUP TESTS PASSED");
                else
                    $display("BSS STARTUP TESTS FAILED");

                $finish;
            end
        end

        $display("FAIL: timeout waiting for tohost write");
        $finish;
    end

endmodule
