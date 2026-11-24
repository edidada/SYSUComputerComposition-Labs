`include "defs.vh"

// 组合控制单元：直接由 opcode / funct 发出全部控制信号。
// 沿用课程做法：控制器直接输出寄存器编号选择所用的 a_src/b_src，
// 而不生成 ALUop 再二级译码，省掉一个 5 位多选器。
module control (
    input  wire [5:0]  op,
    input  wire [5:0]  funct,
    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,
    output reg         mem_to_reg,
    output reg         jump,
    output reg         halt,
    output reg  [1:0]  branch,
    output reg  [1:0]  a_src,
    output reg  [1:0]  b_src,
    output reg  [3:0]  alu_op
);

    always @* begin
        // 默认值：所有写使能关闭
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        jump       = 1'b0;
        halt       = 1'b0;
        branch     = `BR_NONE;
        a_src      = `A_RS;
        b_src      = `B_RT;
        alu_op     = `ALU_ADD;

        case (op)
            `OP_R: begin
                reg_write = 1'b1;
                case (funct)
                    `FUN_ADD: alu_op = `ALU_ADD;
                    `FUN_SUB: alu_op = `ALU_SUB;
                    `FUN_AND: alu_op = `ALU_AND;
                    `FUN_OR:  alu_op = `ALU_OR;
                    `FUN_SLT: alu_op = `ALU_SLT;
                    `FUN_SLL: begin
                        alu_op = `ALU_SLL;
                        a_src  = `A_RT;      // sll 的被移位数在 rt 字段
                        b_src  = `B_SHAMT;
                    end
                    default: alu_op = `ALU_ADD;
                endcase
            end

            `OP_ADDI: begin
                reg_write = 1'b1;
                alu_op    = `ALU_ADD;
                b_src     = `B_SEXT;
            end

            `OP_ANDI: begin
                reg_write = 1'b1;
                alu_op    = `ALU_AND;
                b_src     = `B_ZEXT;
            end

            `OP_ORI: begin
                reg_write = 1'b1;
                alu_op    = `ALU_OR;
                b_src     = `B_ZEXT;
            end

            `OP_LW: begin
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_op     = `ALU_ADD;
                b_src      = `B_SEXT;
            end

            `OP_SW: begin
                mem_write = 1'b1;
                alu_op    = `ALU_ADD;
                b_src     = `B_SEXT;
            end

            `OP_BEQ: begin
                branch = `BR_BEQ;
                alu_op = `ALU_SUB;     // 做减法，zero 为 1 即相等
            end

            `OP_BGTZ: begin
                branch = `BR_BGTZ;
                alu_op = `ALU_GTZ;     // a > 0 时结果为 1
            end

            `OP_J: begin
                jump = 1'b1;
            end

            `OP_HALT: begin
                halt = 1'b1;
            end

            default: begin
                // 未定义指令按空操作处理
            end
        endcase
    end

endmodule
