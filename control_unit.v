// Generates control signals based on the opcode, funct3, and funct7 fields of the instruction.

module control_unit (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    output reg [2:0] alu_ctrl,
    output reg reg_write,
    output reg mem_write, // write en
    output reg mem_read, // read en
    output reg alu_src,
    output reg mem_to_reg,
    output reg branch,
    output reg jump,
    output reg [1:0] imm_sel
);
    // Opcodes
    localparam [6:0]
        OP_RTYPE  = 7'b0110011,
        OP_ITYPE  = 7'b0010011,
        OP_LOAD   = 7'b0000011,
        OP_STORE  = 7'b0100011,
        OP_BRANCH = 7'b1100011,
        OP_JAL    = 7'b1101111;

    // ALU Control Signals
    localparam [2:0]
        ALU_ADD = 3'b000,
        ALU_SUB = 3'b001,
        ALU_AND = 3'b010,
        ALU_OR  = 3'b011,
        ALU_XOR = 3'b100,
        ALU_SLT = 3'b101;
    
    // Imm formats
    localparam [1:0]
        IMM_ITYPE = 2'b00,
        IMM_STYPE = 2'b01,
        IMM_BTYPE = 2'b10,
        IMM_JTYPE = 2'b11;
    
    // funct3 values
    localparam [2:0]
        F3_ADD_SUB = 3'b000,
        F3_SLT     = 3'b010,
        F3_XOR     = 3'b100,
        F3_OR      = 3'b110,
        F3_AND     = 3'b111,
        F3_LW_SW   = 3'b010,
        F3_BEQ     = 3'b000;

    // Relevant funct7 values
    localparam [6:0]
        F7_ADD = 7'b0000000,
        F7_SUB    = 7'b0100000;

    always @(*) begin
        case (opcode)
            OP_RTYPE: begin
                reg_write = 1'b1;
                mem_write = 1'b0;
                mem_read = 1'b0;
                alu_src = 1'b0;
                mem_to_reg = 1'b0;
                branch = 1'b0;
                jump = 1'b0;
                imm_sel = IMM_ITYPE; // Not used for R-type
                case (funct3)
                    F3_ADD_SUB: alu_ctrl = (funct7 == F7_SUB) ? ALU_SUB : ALU_ADD;
                    F3_SLT:     alu_ctrl = ALU_SLT;
                    F3_XOR:     alu_ctrl = ALU_XOR;
                    F3_OR:      alu_ctrl = ALU_OR;
                    F3_AND:     alu_ctrl = ALU_AND;
                    default:    alu_ctrl = ALU_ADD; // Default to ADD
                endcase
            end

            OP_ITYPE: begin
                reg_write = 1'b1;
                mem_write = 1'b0;
                mem_read = 1'b0;
                alu_src = 1'b1;
                mem_to_reg = 1'b0;
                branch = 1'b0;
                jump = 1'b0;
                imm_sel = IMM_ITYPE;
                case (funct3)
                    F3_ADD_SUB: alu_ctrl = ALU_ADD; // ADDI
                    F3_SLT:     alu_ctrl = ALU_SLT; // SLTI
                    F3_XOR:     alu_ctrl = ALU_XOR; // XORI
                    F3_OR:      alu_ctrl = ALU_OR;  // ORI
                    F3_AND:     alu_ctrl = ALU_AND; // ANDI
                    default:    alu_ctrl = ALU_ADD; // Default to ADDI
                endcase
            end
 
            OP_LOAD: begin
                reg_write = 1'b1;
                mem_write = 1'b0;
                mem_read = 1'b1;
                alu_src = 1'b1;
                mem_to_reg = 1'b1;
                branch = 1'b0;
                jump = 1'b0;
                imm_sel = IMM_ITYPE;
                alu_ctrl = ALU_ADD; // Address calculation
            end

            OP_STORE: begin
                reg_write = 1'b0;
                mem_write = 1'b1;
                mem_read = 1'b0;
                alu_src = 1'b1;
                mem_to_reg = 1'b0; // Not used
                branch = 1'b0;
                jump = 1'b0;
                imm_sel = IMM_STYPE;
                alu_ctrl = ALU_ADD; // Address calculation
            end

            OP_BRANCH: begin
                reg_write = 1'b0;
                mem_write = 1'b0;
                mem_read = 1'b0;
                alu_src = 1'b0;
                mem_to_reg = 1'b0; // Not used
                branch = 1'b1;
                jump = 1'b0;
                imm_sel = IMM_BTYPE;
                alu_ctrl = ALU_SUB; // For BEQ, we check if rs1 - rs2 == 0
            end

            OP_JAL: begin
                reg_write = 1'b1;
                mem_write = 1'b0;
                mem_read = 1'b0;
                alu_src = 1'b0; // Not used
                mem_to_reg = 1'b0; // Not used
                branch = 1'b0;
                jump = 1'b1;
                imm_sel = IMM_JTYPE;
                alu_ctrl = ALU_ADD; // Not used
            end

            default: begin
                reg_write = 1'b0;
                mem_write = 1'b0;
                mem_read = 1'b0;
                alu_src = 1'b0;
                mem_to_reg = 1'b0;
                branch = 1'b0;
                jump = 1'b0;
                imm_sel = IMM_ITYPE; // Default to I-type
                alu_ctrl = ALU_ADD; // Default to ADD
            end

        endcase
    end

endmodule