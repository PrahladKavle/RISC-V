`timescale 1ns/1ps

module tb_register_file;

    reg clk;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] ws;
    reg [31:0] w_data;
    reg w_en;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    register_file dut (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .ws(ws),
        .w_data(w_data),
        .w_en(w_en),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always #5 clk = ~clk; // Clock generation

    initial begin
        // Initial values
        clk    = 1'b0;
        rs1    = 5'd0;
        rs2    = 5'd0;
        ws     = 5'd0;
        w_data = 32'd0;
        w_en   = 1'b0;

        // Test 1: x0 should always read as zero
        #1;
        if ((rs1_data !== 32'd0) || (rs2_data !== 32'd0))
            $display("FAIL: x0 did not read as zero");
        else
            $display("PASS: x0 reads as zero");
        
        // Test 2: Write 25 into x5
        ws = 5'd5;
        w_data = 32'd25;
        w_en = 1'b1;

        @(posedge clk);
        #1;
        w_en = 1'b0; // Disable write

        rs1 = 5'd5;
        #1;

        if (rs1_data !== 32'd25)
            $display("FAIL: x5 did not read as 25");
        else
            $display("PASS: x5 reads as 25");
        
        // Test 3: Read two registers simultaneously
        ws     = 5'd10;
        w_data = 32'd100;
        w_en   = 1'b1;

        @(posedge clk);
        #1;
        w_en = 1'b0;
    
        rs1 = 5'd5;
        rs2 = 5'd10;
        #1;
    
        if ((rs1_data !== 32'd25) || (rs2_data !== 32'd100))
            $display("FAIL: simultaneous read incorrect");
        else
            $display("PASS: simultaneous read");


        // Test 4: Attempt to write with enable low
        ws     = 5'd5;
        w_data = 32'd999;
        w_en   = 1'b0; // Write enable low
        @(posedge clk);
        #1;

        rs1 = 5'd5;
        #1;

        if (rs1_data !== 32'd25)
            $display("FAIL: x5 changed while w_en was low");
        else
            $display("PASS: w_en blocks writes");
        
        // Test 5: Attempt to write to x0
        ws     = 5'd0;
        w_data = 32'd1234;
        w_en   = 1'b1; // Write enable high

        @(posedge clk);
        #1;
        w_en = 1'b0; // Disable write

        rs1 = 5'd0;
        #1;

        if (rs1_data !== 32'd0)
            $display("FAIL: x0 changed when written to");
        else
            $display("PASS: x0 remains zero when written to");
            
        $display("Register-file tests complete");
        $finish;
    end

endmodule