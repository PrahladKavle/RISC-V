`timescale 1ns/1ps

module tb_control_unit;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire [3:0] alu_ctrl;
    wire reg_write;
    wire mem_write;
    wire mem_read;
    wire alu_src;
    wire mem_to_reg;
    wire branch;
    wire jump;
    wire [2:0] imm_sel;
    wire [1:0] mem_size;
    wire load_unsigned;
    wire jalr;
    wire lui;
    wire auipc;

    wire [19:0] actual_controls;

    integer tests;
    integer failures;

    localparam [6:0]
        OP_RTYPE  = 7'b0110011,
        OP_ITYPE  = 7'b0010011,
        OP_LOAD   = 7'b0000011,
        OP_STORE  = 7'b0100011,
        OP_BRANCH = 7'b1100011,
        OP_JAL    = 7'b1101111,
        OP_JALR   = 7'b1100111,
        OP_LUI    = 7'b0110111,
        OP_AUIPC  = 7'b0010111;

    localparam [3:0]
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_AND  = 4'b0010,
        ALU_OR   = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_SLT  = 4'b0101,
        ALU_SLL  = 4'b0110,
        ALU_SRL  = 4'b0111,
        ALU_SRA  = 4'b1000,
        ALU_SLTU = 4'b1001;

    localparam [2:0]
        IMM_I = 3'b000,
        IMM_S = 3'b001,
        IMM_B = 3'b010,
        IMM_J = 3'b011,
        IMM_U = 3'b100;

    localparam [1:0]
        MEM_BYTE = 2'b00,
        MEM_HALF = 2'b01,
        MEM_WORD = 2'b10;

    assign actual_controls = {
        alu_ctrl,
        reg_write,
        mem_write,
        mem_read,
        alu_src,
        mem_to_reg,
        branch,
        jump,
        imm_sel,
        mem_size,
        load_unsigned,
        jalr,
        lui,
        auipc
    };

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
        .imm_sel(imm_sel),
        .mem_size(mem_size),
        .load_unsigned(load_unsigned),
        .jalr(jalr),
        .lui(lui),
        .auipc(auipc)
    );

    task check_decode;
        input [159:0] test_name;
        input [6:0] test_opcode;
        input [2:0] test_funct3;
        input [6:0] test_funct7;
        input [19:0] expected_controls;

        begin
            opcode = test_opcode;
            funct3 = test_funct3;
            funct7 = test_funct7;
            #1;

            tests = tests + 1;

            if (actual_controls !== expected_controls) begin
                failures = failures + 1;
                $display("FAIL: %0s", test_name);
                $display("  expected=%b", expected_controls);
                $display("  actual  =%b", actual_controls);
            end else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    initial begin
        tests = 0;
        failures = 0;

        // R-type instructions
        check_decode("ADD",  OP_RTYPE, 3'b000, 7'b0000000, {ALU_ADD,  7'b1000000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SUB",  OP_RTYPE, 3'b000, 7'b0100000, {ALU_SUB,  7'b1000000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SLL",  OP_RTYPE, 3'b001, 7'b0000000, {ALU_SLL,  7'b1000000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SLT",  OP_RTYPE, 3'b010, 7'b0000000, {ALU_SLT,  7'b1000000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SLTU", OP_RTYPE, 3'b011, 7'b0000000, {ALU_SLTU, 7'b1000000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("XOR",  OP_RTYPE, 3'b100, 7'b0000000, {ALU_XOR,  7'b1000000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SRL",  OP_RTYPE, 3'b101, 7'b0000000, {ALU_SRL,  7'b1000000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SRA",  OP_RTYPE, 3'b101, 7'b0100000, {ALU_SRA,  7'b1000000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("OR",   OP_RTYPE, 3'b110, 7'b0000000, {ALU_OR,   7'b1000000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("AND",  OP_RTYPE, 3'b111, 7'b0000000, {ALU_AND,  7'b1000000, IMM_I, MEM_WORD, 4'b0000});

        // I-type ALU instructions
        check_decode("ADDI",  OP_ITYPE, 3'b000, 7'b0000000, {ALU_ADD,  7'b1001000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SLLI",  OP_ITYPE, 3'b001, 7'b0000000, {ALU_SLL,  7'b1001000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SLTI",  OP_ITYPE, 3'b010, 7'b0000000, {ALU_SLT,  7'b1001000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SLTIU", OP_ITYPE, 3'b011, 7'b0000000, {ALU_SLTU, 7'b1001000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("XORI",  OP_ITYPE, 3'b100, 7'b0000000, {ALU_XOR,  7'b1001000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SRLI",  OP_ITYPE, 3'b101, 7'b0000000, {ALU_SRL,  7'b1001000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("SRAI",  OP_ITYPE, 3'b101, 7'b0100000, {ALU_SRA,  7'b1001000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("ORI",   OP_ITYPE, 3'b110, 7'b0000000, {ALU_OR,   7'b1001000, IMM_I, MEM_WORD, 4'b0000});
        check_decode("ANDI",  OP_ITYPE, 3'b111, 7'b0000000, {ALU_AND,  7'b1001000, IMM_I, MEM_WORD, 4'b0000});

        // Loads and stores
        check_decode("LB",  OP_LOAD, 3'b000, 7'b0000000, {ALU_ADD, 7'b1011100, IMM_I, MEM_BYTE, 4'b0000});
        check_decode("LH",  OP_LOAD, 3'b001, 7'b0000000, {ALU_ADD, 7'b1011100, IMM_I, MEM_HALF, 4'b0000});
        check_decode("LW",  OP_LOAD, 3'b010, 7'b0000000, {ALU_ADD, 7'b1011100, IMM_I, MEM_WORD, 4'b0000});
        check_decode("LBU", OP_LOAD, 3'b100, 7'b0000000, {ALU_ADD, 7'b1011100, IMM_I, MEM_BYTE, 4'b1000});
        check_decode("LHU", OP_LOAD, 3'b101, 7'b0000000, {ALU_ADD, 7'b1011100, IMM_I, MEM_HALF, 4'b1000});
        check_decode("SB", OP_STORE, 3'b000, 7'b0000000, {ALU_ADD, 7'b0101000, IMM_S, MEM_BYTE, 4'b0000});
        check_decode("SH", OP_STORE, 3'b001, 7'b0000000, {ALU_ADD, 7'b0101000, IMM_S, MEM_HALF, 4'b0000});
        check_decode("SW", OP_STORE, 3'b010, 7'b0000000, {ALU_ADD, 7'b0101000, IMM_S, MEM_WORD, 4'b0000});

        // Branches
        check_decode("BEQ",  OP_BRANCH, 3'b000, 7'b0000000, {ALU_SUB,  7'b0000010, IMM_B, MEM_WORD, 4'b0000});
        check_decode("BNE",  OP_BRANCH, 3'b001, 7'b0000000, {ALU_SUB,  7'b0000010, IMM_B, MEM_WORD, 4'b0000});
        check_decode("BLT",  OP_BRANCH, 3'b100, 7'b0000000, {ALU_SLT,  7'b0000010, IMM_B, MEM_WORD, 4'b0000});
        check_decode("BGE",  OP_BRANCH, 3'b101, 7'b0000000, {ALU_SLT,  7'b0000010, IMM_B, MEM_WORD, 4'b0000});
        check_decode("BLTU", OP_BRANCH, 3'b110, 7'b0000000, {ALU_SLTU, 7'b0000010, IMM_B, MEM_WORD, 4'b0000});
        check_decode("BGEU", OP_BRANCH, 3'b111, 7'b0000000, {ALU_SLTU, 7'b0000010, IMM_B, MEM_WORD, 4'b0000});

        // Jumps and upper immediates
        check_decode("JAL",   OP_JAL,   3'b000, 7'b0000000, {ALU_ADD, 7'b1000001, IMM_J, MEM_WORD, 4'b0000});
        check_decode("JALR",  OP_JALR,  3'b000, 7'b0000000, {ALU_ADD, 7'b1001001, IMM_I, MEM_WORD, 4'b0100});
        check_decode("LUI",   OP_LUI,   3'b000, 7'b0000000, {ALU_ADD, 7'b1001000, IMM_U, MEM_WORD, 4'b0010});
        check_decode("AUIPC", OP_AUIPC, 3'b000, 7'b0000000, {ALU_ADD, 7'b1001000, IMM_U, MEM_WORD, 4'b0001});

        check_decode("INVALID OPCODE", 7'b0000000, 3'b000, 7'b0000000, {ALU_ADD, 7'b0000000, IMM_I, MEM_WORD, 4'b0000});

        $display("");
        $display("Tests: %0d, Failures: %0d", tests, failures);

        if (failures == 0)
            $display("ALL CONTROL-UNIT TESTS PASSED");
        else
            $display("CONTROL-UNIT TESTS FAILED");

        $finish;
    end

endmodule
