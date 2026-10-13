`timescale 1ns/1ps

module tb_control_unit;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire [2:0] alu_ctrl;
    wire reg_write;
    wire mem_write;
    wire mem_read;
    wire alu_src;
    wire mem_to_reg;
    wire branch;
    wire jump;
    wire [1:0] imm_sel;

    integer tests;
    integer failures;

    localparam [6:0]
        OP_RTYPE  = 7'b0110011,
        OP_ITYPE  = 7'b0010011,
        OP_LOAD   = 7'b0000011,
        OP_STORE  = 7'b0100011,
        OP_BRANCH = 7'b1100011,
        OP_JAL    = 7'b1101111;

    localparam [2:0]
        ALU_ADD = 3'b000,
        ALU_SUB = 3'b001,
        ALU_AND = 3'b010,
        ALU_OR  = 3'b011,
        ALU_XOR = 3'b100,
        ALU_SLT = 3'b101;

    localparam [1:0]
        IMM_I = 2'b00,
        IMM_S = 2'b01,
        IMM_B = 2'b10,
        IMM_J = 2'b11;

    control_unit dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_ctrl(alu_ctrl),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .imm_sel(imm_sel)
    );

    task check_control;
        input [127:0] test_name;
        input [6:0] test_opcode;
        input [2:0] test_funct3;
        input [6:0] test_funct7;
        input [2:0] expected_alu;
        input expected_reg_write;
        input expected_mem_write;
        input expected_mem_read;
        input expected_alu_src;
        input expected_mem_to_reg;
        input expected_branch;
        input expected_jump;
        input [1:0] expected_imm;

        begin
            opcode = test_opcode;
            funct3 = test_funct3;
            funct7 = test_funct7;

            #1;
            tests = tests + 1;

            if ((alu_ctrl   !== expected_alu)        ||
                (reg_write  !== expected_reg_write)  ||
                (mem_write  !== expected_mem_write)  ||
                (mem_read   !== expected_mem_read)   ||
                (alu_src    !== expected_alu_src)    ||
                (mem_to_reg !== expected_mem_to_reg) ||
                (branch     !== expected_branch)     ||
                (jump       !== expected_jump)       ||
                (imm_sel    !== expected_imm)) begin

                failures = failures + 1;

                $display("FAIL: %0s", test_name);
                $display("  alu_ctrl   expected=%b actual=%b",
                         expected_alu, alu_ctrl);
                $display("  reg_write  expected=%b actual=%b",
                         expected_reg_write, reg_write);
                $display("  mem_write  expected=%b actual=%b",
                         expected_mem_write, mem_write);
                $display("  mem_read   expected=%b actual=%b",
                         expected_mem_read, mem_read);
                $display("  alu_src    expected=%b actual=%b",
                         expected_alu_src, alu_src);
                $display("  mem_to_reg expected=%b actual=%b",
                         expected_mem_to_reg, mem_to_reg);
                $display("  branch     expected=%b actual=%b",
                         expected_branch, branch);
                $display("  jump       expected=%b actual=%b",
                         expected_jump, jump);
                $display("  imm_sel    expected=%b actual=%b",
                         expected_imm, imm_sel);
            end else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    initial begin
        tests = 0;
        failures = 0;

        // name, opcode, funct3, funct7, ALU,
        // reg_write, mem_write, mem_read, alu_src,
        // mem_to_reg, branch, jump, imm_sel

        check_control(
            "ADD", OP_RTYPE, 3'b000, 7'b0000000, ALU_ADD,
            1, 0, 0, 0, 0, 0, 0, IMM_I
        );

        check_control(
            "SUB", OP_RTYPE, 3'b000, 7'b0100000, ALU_SUB,
            1, 0, 0, 0, 0, 0, 0, IMM_I
        );

        check_control(
            "AND", OP_RTYPE, 3'b111, 7'b0000000, ALU_AND,
            1, 0, 0, 0, 0, 0, 0, IMM_I
        );

        check_control(
            "OR", OP_RTYPE, 3'b110, 7'b0000000, ALU_OR,
            1, 0, 0, 0, 0, 0, 0, IMM_I
        );

        check_control(
            "XOR", OP_RTYPE, 3'b100, 7'b0000000, ALU_XOR,
            1, 0, 0, 0, 0, 0, 0, IMM_I
        );

        check_control(
            "SLT", OP_RTYPE, 3'b010, 7'b0000000, ALU_SLT,
            1, 0, 0, 0, 0, 0, 0, IMM_I
        );

        check_control(
            "ADDI", OP_ITYPE, 3'b000, 7'b0000000, ALU_ADD,
            1, 0, 0, 1, 0, 0, 0, IMM_I
        );

        check_control(
            "ANDI", OP_ITYPE, 3'b111, 7'b0000000, ALU_AND,
            1, 0, 0, 1, 0, 0, 0, IMM_I
        );

        check_control(
            "ORI", OP_ITYPE, 3'b110, 7'b0000000, ALU_OR,
            1, 0, 0, 1, 0, 0, 0, IMM_I
        );

        check_control(
            "LW", OP_LOAD, 3'b010, 7'b0000000, ALU_ADD,
            1, 0, 1, 1, 1, 0, 0, IMM_I
        );

        check_control(
            "SW", OP_STORE, 3'b010, 7'b0000000, ALU_ADD,
            0, 1, 0, 1, 0, 0, 0, IMM_S
        );

        check_control(
            "BEQ", OP_BRANCH, 3'b000, 7'b0000000, ALU_SUB,
            0, 0, 0, 0, 0, 1, 0, IMM_B
        );

        check_control(
            "JAL", OP_JAL, 3'b000, 7'b0000000, ALU_ADD,
            1, 0, 0, 0, 0, 0, 1, IMM_J
        );

        check_control(
            "INVALID OPCODE", 7'b0000000, 3'b000, 7'b0000000,
            ALU_ADD,
            0, 0, 0, 0, 0, 0, 0, IMM_I
        );

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL CONTROL-UNIT TESTS PASSED");
        else
            $display("CONTROL-UNIT TESTS FAILED");

        $finish;
    end

endmodule