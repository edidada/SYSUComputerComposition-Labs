`include "defs.vh"

// 多周期控制单元：把一条指令翻译成 32 位微指令字。
// 微指令由硬件按位取用：访存/写回周期数、ALU 操作、源选择、分支跳转等。
module control (
    input  wire [5:0]  op,
    input  wire [5:0]  funct,
    output wire [31:0] micro
);
    reg        need_mem;
    reg        reg_write;
    reg        halt_det;
    reg [3:0]  alu_op;
    reg [1:0]  a_src;
    reg [1:0]  b_src;
    reg        mem_write;
    reg        mem_to_reg;
    reg [1:0]  branch;
    reg        jump;

    always @* begin
        need_mem   = 1'b0;
        reg_write  = 1'b0;
        halt_det   = 1'b0;
        alu_op     = `ALU_ADD;
        a_src      = `A_RS;
        b_src      = `B_RT;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = `BR_NONE;
        jump       = 1'b0;

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
                        a_src  = `A_RT;
                        b_src  = `B_SHAMT;
                    end
                    default: alu_op = `ALU_ADD;
                endcase
            end

            `OP_ADDI: begin reg_write = 1'b1; alu_op = `ALU_ADD; b_src = `B_SEXT; end
            `OP_ANDI: begin reg_write = 1'b1; alu_op = `ALU_AND; b_src = `B_ZEXT; end
            `OP_ORI:  begin reg_write = 1'b1; alu_op = `ALU_OR;  b_src = `B_ZEXT; end

            `OP_LW: begin
                need_mem   = 1'b1;
                reg_write  = 1'b1;
                mem_to_reg = 1'b1;
                b_src      = `B_SEXT;
            end

            `OP_SW: begin
                need_mem  = 1'b1;
                mem_write = 1'b1;
                b_src     = `B_SEXT;
            end

            `OP_BEQ:  begin branch = `BR_BEQ;  alu_op = `ALU_SUB; end
            `OP_BGTZ: begin branch = `BR_BGTZ; alu_op = `ALU_GTZ; end
            `OP_J:    jump = 1'b1;
            `OP_HALT: halt_det = 1'b1;
            default: begin end
        endcase
    end

    assign micro = {
        need_mem, reg_write, halt_det,
        alu_op, a_src, b_src,
        mem_write, mem_to_reg, branch, jump,
        16'b0
    };

endmodule
