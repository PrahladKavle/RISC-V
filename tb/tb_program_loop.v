`timescale 1ns/1ps

module tb_program_loop;

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
        .INIT_FILE("build/program_loop.hex"),
        .DATA_INIT_FILE("build/program_loop_data.hex")
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

    task check_register;
        input [4:0] register_index;
        input [31:0] expected_value;
        begin
            if (dut.reg_file.registers[register_index] !== expected_value) begin
                failures = failures + 1;
                $display(
                    "FAIL: x%0d expected %h, got %h",
                    register_index,
                    expected_value,
                    dut.reg_file.registers[register_index]
                );
            end else begin
                $display(
                    "PASS: x%0d = %h",
                    register_index,
                    expected_value
                );
            end
        end
    endtask

    initial begin
        $dumpfile("test/program_loop.vcd");
        $dumpvars(0, tb_program_loop);

        clk = 1'b0;
        rst = 1'b1;
        cycle_count = 0;
        failures = 0;

        #12;
        rst = 1'b0;

        repeat (50) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;

            if (tohost_write) begin
                if (tohost_data !== 32'd15) begin
                    failures = failures + 1;
                    $display(
                        "FAIL: tohost expected 15, got %h",
                        tohost_data
                    );
                end else begin
                    $display(
                        "PASS: tohost received 15 after %0d cycles",
                        cycle_count
                    );
                end

                check_register(5'd5,  32'h00010000); // t0: data base
                check_register(5'd6,  32'd0);        // t1: final counter
                check_register(5'd7,  32'd15);       // t2: accumulator
                check_register(5'd28, 32'd15);       // t3: loaded result
                check_register(5'd29, 32'h10000000); // t4: tohost

                if (dut.data_mem.memory[0] !== 32'd15) begin
                    failures = failures + 1;
                    $display(
                        "FAIL: data memory[0] expected 15, got %h",
                        dut.data_mem.memory[0]
                    );
                end else begin
                    $display("PASS: data memory[0] = 0000000f");
                end

                if (failures == 0)
                    $display("ALL PROGRAM-LOOP TESTS PASSED");
                else
                    $display("PROGRAM-LOOP TESTS FAILED");

                $finish;
            end
        end

        $display("FAIL: timeout waiting for tohost write");
        $finish;
    end

endmodule