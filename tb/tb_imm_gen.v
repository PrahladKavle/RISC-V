`timescale 1ns/1ps

module tb_imm_gen;

    reg [31:0] instruction;
    reg [1:0] imm_sel;

    wire [31:0] imm_out;

    localparam [1:0]
        Itype = 2'b00,
        Stype = 2'b01,
        Btype = 2'b10,
        Jtype = 2'b11;

    imm_gen dut (
        .instruction(instruction),
        .imm_sel(imm_sel),
        .imm_out(imm_out)
    );

    initial begin
        // I-type: immediate = +5
        instruction = 32'b0;
        instruction[31:20] = 12'd5;
        imm_sel = Itype;
        #1;

        if (imm_out !== 32'd5)
            $display("FAIL: I-type +5, got %h", imm_out);
        else
            $display("PASS: I-type +5");

        // I-type: immediate = -1
        instruction = 32'b0;
        instruction[31:20] = 12'hFFF;
        imm_sel = Itype;
        #1;

        if (imm_out !== 32'hFFFFFFFF)
            $display("FAIL: I-type -1, got %h", imm_out);
        else
            $display("PASS: I-type -1");

        // S-type: immediate = +12
        instruction = 32'b0;
        instruction[31:25] = 7'b0000000;
        instruction[11:7]  = 5'b01100;
        imm_sel = Stype;
        #1;

        if (imm_out !== 32'd12)
            $display("FAIL: S-type +12, got %h", imm_out);
        else
            $display("PASS: S-type +12");

        // S-type: immediate = -4
        // 12-bit representation of -4 = 111111111100
        instruction = 32'b0;
        instruction[31:25] = 7'b1111111;
        instruction[11:7]  = 5'b11100;
        imm_sel = Stype;
        #1;

        if (imm_out !== 32'hFFFFFFFC)
            $display("FAIL: S-type -4, got %h", imm_out);
        else
            $display("PASS: S-type -4");

        // B-type: branch offset = +16
        // imm[12|11|10:5|4:1|0] = 0|0|000000|1000|0
        instruction = 32'b0;
        instruction[31]    = 1'b0;
        instruction[7]     = 1'b0;
        instruction[30:25] = 6'b000000;
        instruction[11:8]  = 4'b1000;
        imm_sel = Btype;
        #1;

        if (imm_out !== 32'd16)
            $display("FAIL: B-type +16, got %h", imm_out);
        else
            $display("PASS: B-type +16");

        // B-type: branch offset = -4
        instruction = 32'b0;
        instruction[31]    = 1'b1;
        instruction[7]     = 1'b1;
        instruction[30:25] = 6'b111111;
        instruction[11:8]  = 4'b1110;
        imm_sel = Btype;
        #1;

        if (imm_out !== 32'hFFFFFFFC)
            $display("FAIL: B-type -4, got %h", imm_out);
        else
            $display("PASS: B-type -4");

        // J-type: jump offset = +2048
        // Only imm[11] is set
        instruction = 32'b0;
        instruction[31]    = 1'b0;
        instruction[19:12] = 8'b00000000;
        instruction[20]    = 1'b1;
        instruction[30:21] = 10'b0000000000;
        imm_sel = Jtype;
        #1;

        if (imm_out !== 32'd2048)
            $display("FAIL: J-type +2048, got %h", imm_out);
        else
            $display("PASS: J-type +2048");

        // J-type: jump offset = -4
        instruction = 32'b0;
        instruction[31]    = 1'b1;
        instruction[19:12] = 8'b11111111;
        instruction[20]    = 1'b1;
        instruction[30:21] = 10'b1111111110;
        imm_sel = Jtype;
        #1;

        if (imm_out !== 32'hFFFFFFFC)
            $display("FAIL: J-type -4, got %h", imm_out);
        else
            $display("PASS: J-type -4");

        $display("Immediate-generator tests complete");
        $finish;
    end

endmodule