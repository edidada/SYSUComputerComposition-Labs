`include "defs.vh"

// 实验五：单周期 MIPS CPU
// 一条指令在一个时钟周期内走完：取指 -> 译码 -> 执行 -> 访存 -> 写回。
// 除 PC 与寄存器堆/数据存储器写入外，全部是组合逻辑。
module single_cpu #(
    parameter IMEM_INIT = "program.hex"
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    output wire        halt,
    output wire [31:0] pc,
    output wire [31:0] instr,
    output wire [31:0] alu_result,
    output wire [31:0] wb_data,
    output wire [31:0] mem_rdata
);
    wire [31:0] pc_plus4     = pc + 32'd4;
    wire [31:0] signext_imm;
    wire [31:0] zeroext_imm;
    wire [31:0] branch_target = pc_plus4 + (signext_imm << 2);
    wire [31:0] jump_target   = {pc_plus4[31:28], instr[25:0], 2'b00};

    wire        reg_write, mem_read, mem_write, mem_to_reg;
    wire        jump, halt_dec, alu_zero, alu_gtz;
    wire [1:0]  branch, a_src, b_src;
    wire [3:0]  alu_op;
    wire [31:0] rd1, rd2, alu_a, alu_b;
    wire [4:0]  dst;

    // halt 时停止取指
    pc u_pc (
        .clk(clk), .rst(rst), .en(enable & ~halt),
        .next(jump ? jump_target :
              (((branch == `BR_BEQ) && alu_zero) ||
               ((branch == `BR_BGTZ) && alu_gtz)) ? branch_target : pc_plus4),
        .q(pc)
    );

    instr_mem #(.INIT_FILE(IMEM_INIT)) u_imem (
        .addr(pc), .instr(instr)
    );

    control u_control (
        .op(instr[31:26]), .funct(instr[5:0]),
        .reg_write(reg_write), .mem_read(mem_read), .mem_write(mem_write),
        .mem_to_reg(mem_to_reg), .jump(jump), .halt(halt_dec),
        .branch(branch), .a_src(a_src), .b_src(b_src), .alu_op(alu_op)
    );

    // 沿用课程助记符：R 型目标在 [15:11]，I 型目标在 [20:16]
    assign dst = (instr[31:26] == `OP_R) ? instr[15:11] : instr[20:16];

    regfile u_rf (
        .clk(clk), .rst(rst), .we(reg_write),
        .raddr1(instr[25:21]), .raddr2(instr[20:16]), .waddr(dst),
        .wdata(wb_data), .rdata1(rd1), .rdata2(rd2)
    );

    sign_extend u_se (
        .imm(instr[15:0]), .sext(signext_imm), .zext(zeroext_imm)
    );

    assign alu_a = (a_src == `A_RT)    ? rd2 :
                   (a_src == `A_SHAMT) ? {27'b0, instr[10:6]} : rd1;
    assign alu_b = (b_src == `B_SEXT)  ? signext_imm :
                   (b_src == `B_ZEXT)  ? zeroext_imm :
                   (b_src == `B_SHAMT) ? {27'b0, instr[10:6]} : rd2;

    alu u_alu (
        .op(alu_op), .a(alu_a), .b(alu_b),
        .result(alu_result), .zero(alu_zero), .gtz(alu_gtz)
    );

    data_mem u_dmem (
        .clk(clk), .we(mem_write), .addr(alu_result),
        .wdata(rd2), .rdata(mem_rdata)
    );

    assign wb_data = mem_to_reg ? mem_rdata : alu_result;
    assign halt    = halt_dec;

endmodule
