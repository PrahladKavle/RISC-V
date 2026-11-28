`timescale 1ns/1ps

module tb_act_runner;

    parameter MAX_CYCLES = 200000;

    reg clk;
    reg rst;

    wire [31:0] pc_debug;
    wire [31:0] instruction_debug;
    wire [31:0] alu_result_debug;
    wire tohost_write;
    wire [31:0] tohost_data;
    wire data_mem_write_event;
    wire [31:0] data_mem_write_addr;
    wire [31:0] data_mem_write_data;

    integer cycle_count;
    reg [31:0] end_signature_addr;

    rv32i_core #(
        .INIT_FILE("build/act_program.hex"),
        .DATA_INIT_FILE("build/act_data.hex"),
        .IMEM_DEPTH(65536),
        .IMEM_ADDR_WIDTH(16),
        .DMEM_DEPTH(65536),
        .DMEM_ADDR_WIDTH(16),
        .DMEM_BASE_ADDR(32'h00040000)
    ) dut (
        .clk(clk),
        .rst(rst),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug),
        .alu_result_debug(alu_result_debug),
        .tohost_write(tohost_write),
        .tohost_data(tohost_data),
        .data_mem_write_event(data_mem_write_event),
        .data_mem_write_addr(data_mem_write_addr),
        .data_mem_write_data(data_mem_write_data)
    );

    always #5 clk = ~clk;

    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("test/act_runner.vcd");
            $dumpvars(0, tb_act_runner);
        end

        clk = 1'b0;
        rst = 1'b1;
        cycle_count = 0;

        if (!$value$plusargs("end_signature=%h", end_signature_addr))
            $fatal(1, "ACT_FAIL: missing +end_signature=<address>");

        #12;
        rst = 1'b0;

        repeat (MAX_CYCLES) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;

            if (tohost_write) begin
                if (tohost_data == 32'd1) begin
                    $display("ACT_PASS: completed after %0d cycles", cycle_count);
                    $finish;
                end

                $fatal(
                    1,
                    "ACT_FAIL: tohost value %h after %0d cycles",
                    tohost_data,
                    cycle_count
                );
            end

            if (data_mem_write_event && data_mem_write_addr == end_signature_addr) begin
                if (data_mem_write_data == 32'd1) begin
                    $display("ACT_PASS: end_signature written after %0d cycles", cycle_count);
                    $finish;
                end

                if (data_mem_write_data == 32'd2 || data_mem_write_data == 32'd3) begin
                    $fatal(
                        1,
                        "ACT_FAIL: end_signature value %h after %0d cycles",
                        data_mem_write_data,
                        cycle_count
                    );
                end
            end
        end

        $fatal(1, "ACT_FAIL: timeout after %0d cycles", MAX_CYCLES);
    end

endmodule
