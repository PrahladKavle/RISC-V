// Datapath and control logic

module rv32i_core #(
    parameter INIT_FILE = "program.hex"
) (
    input wire clk,
    input wire rst,

    output wire [31:0] pc_debug,
    output wire [31:0] instruction_debug,
    output wire [31:0] alu_result_debug
);

    // PC signals
    wire [31:0] pc;
    wire [31:0] next_pc;

    // Instruction signal
    wire [31:0] instruction;

    // Instruction fields
    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;

    // Control signals
    wire [3:0] alu_ctrl;
    wire reg_write;
    wire mem_write;
    wire mem_read;
    wire alu_src;
    wire mem_to_reg;
    wire branch;
    wire jump;
    wire [1:0] imm_sel;

    // Register-file signals
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire regfile_write_enable;

    // Immediate-generator signal
    wire [31:0] immediate;

    // ALU signals
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire alu_zero;

    // Data Memory
    wire [31:0] memory_read_data;
    wire [31:0] writeback_data;
    wire data_memory_write_enable;

    // BEQ
    wire [31:0] pc_plus_4; // pc_plus_4     = pc + 4
    wire [31:0] branch_target; // branch_target = pc + immediate
    wire branch_taken; // branch_taken  = branch && alu_zero

    // JAL
    wire [31:0] jal_target; // jal_target = pc + immediate 

    // Extract fields from the current instruction
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // Select either rs2 or the immediate for ALU operand B
    assign alu_operand_b = alu_src ? immediate : rs2_data;

    // Prevent register writes while reset is active
    assign regfile_write_enable = reg_write && !rst;

    // BEQ
    assign pc_plus_4 = pc + 32'd4;
    assign branch_target = pc + immediate;
    assign branch_taken = branch && alu_zero;

    // JAL
    assign jal_target = pc + immediate;

    assign writeback_data =
    jump       ? pc_plus_4 :
    mem_to_reg ? memory_read_data :
                 alu_result;

    assign next_pc =
    jump         ? jal_target :
    branch_taken ? branch_target :
                   pc_plus_4;

    // Program counter instance
    program_control pc_unit (
        .clk(clk),
        .rst(rst),
        .next_pc(next_pc),
        .pc_out(pc)
    );

    // Instruction memory instance
    instruction_memory #(
        .INIT_FILE(INIT_FILE)
    ) instruction_mem (
        .addr(pc),
        .instruction(instruction)
    );

    // Control-unit instance
    control_unit control (
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

    // Register-file instance
    register_file reg_file (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .ws(rd),
        .w_data(writeback_data),
        .w_en(regfile_write_enable),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Immediate-generator instance
    imm_gen immediate_generator (
        .instruction(instruction),
        .imm_sel(imm_sel),
        .imm_out(immediate)
    );

    // ALU instance
    alu execution_alu (
        .a(rs1_data),
        .b(alu_operand_b),
        .ctrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Data memory instance
    data_memory data_mem (
    .clk(clk),
    .addr(alu_result),
    .w_data(rs2_data),
    .w_en(data_memory_write_enable),
    .r_en(mem_read),
    .r_data(memory_read_data)
    );
    
    // Optional signals exposed for waveform debugging
    assign pc_debug = pc;
    assign instruction_debug = instruction;
    assign alu_result_debug = alu_result;
    assign data_memory_write_enable = mem_write && !rst;

endmodule