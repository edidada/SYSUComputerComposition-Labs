`include "defs.vh"

// 实验六：多周期 MIPS CPU
// 一条指令拆成 IF -> ID -> EX -> MEM -> WB 五个周期，硬件部件（尤其 ALU）复用。
// 控制单元输出 32 位微指令字，硬件按位取用；状态机按需跳过不需要的周期。
module multi_cpu #(
    parameter IMEM_INIT = "program.hex"
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    output wire        halt,
    output wire [4:0]  state,
    output wire [31:0] pc,
    output wire [31:0] ir,
    output wire [31:0] aluout,
    output wire [31:0] micro,
    output wire [31:0] micro_ex
);
    wire [31:0] instr;                 // 当前 PC 取出的指令
    wire [31:0] pc_plus4 = pc + 32'd4;
    wire [31:0] next_pc;
    wire        pc_we;

    wire        halt_det = (instr[31:26] == `OP_HALT);
    assign halt = halt_det & (state == `S_IF);

    // 两组控制译码：一组看当前取到的指令（用于判断 halt），
    // 一组看指令寄存器里的指令（真正驱动本条指令的各个周期）
    wire [31:0] micro_if, micro_ir;
    control u_ctrl_if (.op(instr[31:26]), .funct(instr[5:0]), .micro(micro_if));
    control u_ctrl_ir (.op(ir[31:26]),    .funct(ir[5:0]),    .micro(micro_ir));
    assign micro = micro_ir;

    // ID 周期锁存的微指令字，供 EX/MEM/WB 使用
    reg [31:0] micro_reg;
    assign micro_ex = micro_reg;

    wire        need_mem  = micro_ex[`MIC_MEM];
    wire        need_wb   = micro_ex[`MIC_WB];
    wire [3:0]  alu_op_ex = micro_ex[`MIC_ALU_H:`MIC_ALU_L];
    wire [1:0]  a_src_ex  = micro_ex[`MIC_A_H:`MIC_A_L];
    wire [1:0]  b_src_ex  = micro_ex[`MIC_B_H:`MIC_B_L];
    wire        memw_ex   = micro_ex[`MIC_MEMW];
    wire        m2r_ex    = micro_ex[`MIC_M2R];
    wire [1:0]  br_ex     = micro_ex[`MIC_BR_H:`MIC_BR_L];
    wire        jump_ex   = micro_ex[`MIC_JUMP];

    // 周期之间传递的流水线寄存器（不是流水线 CPU，只是单条指令内部的分步锁存）
    reg [31:0] ir_reg;
    reg [31:0] A, B;
    reg [15:0] imm_reg;
    reg [31:0] aluout_reg;
    reg [31:0] mdr;
    reg [4:0]  dst_reg;

    assign ir     = ir_reg;
    assign aluout = aluout_reg;

    // 立即数扩展
    wire [31:0] sext_imm, zext_imm;
    sign_extend u_se (.imm(imm_reg), .sext(sext_imm), .zext(zext_imm));

    // 分支/跳转目标：ID 及以后 pc 已经是"本条指令地址 + 4"
    wire [31:0] branch_target = pc + (sext_imm << 2);
    wire [31:0] jump_target   = {pc[31:28], ir[25:0], 2'b00};

    // 寄存器堆：ID 组合读出，WB 周期上升沿写入
    wire [31:0] rd1, rd2;
    wire        rf_we = (state == `S_WB) && need_wb;
    wire [31:0] rf_wdata = m2r_ex ? mdr : aluout;
    regfile u_rf (
        .clk(clk), .rst(rst), .we(rf_we),
        .raddr1(ir[25:21]), .raddr2(ir[20:16]),
        .waddr(dst_reg), .wdata(rf_wdata),
        .rdata1(rd1), .rdata2(rd2)
    );

    // 同一个 ALU 在 EX 周期被所有指令复用
    wire [31:0] ex_a =
        (a_src_ex == `A_RT)    ? B :
        (a_src_ex == `A_SHAMT) ? {27'b0, ir[10:6]} : A;
    wire [31:0] ex_b =
        (b_src_ex == `B_SEXT)  ? sext_imm :
        (b_src_ex == `B_ZEXT)  ? zext_imm :
        (b_src_ex == `B_SHAMT) ? {27'b0, ir[10:6]} : B;
    wire [31:0] ex_result;
    wire        ex_zero, ex_gtz;
    alu u_alu (
        .op(alu_op_ex), .a(ex_a), .b(ex_b),
        .result(ex_result), .zero(ex_zero), .gtz(ex_gtz)
    );

    wire branch_taken =
        ((br_ex == `BR_BEQ)  && ex_zero) ||
        ((br_ex == `BR_BGTZ) && ex_gtz);

    // 数据存储器：MEM 周期读写，地址是 EX 算出的 aluout，写入数据是 B
    wire [31:0] mem_rdata;
    wire        mem_we = (state == `S_MEM) && memw_ex;
    data_mem u_dm (
        .clk(clk), .we(mem_we), .addr(aluout),
        .wdata(B), .rdata(mem_rdata)
    );

    // 状态机与 PC 写入控制
    stage u_stage (
        .clk(clk), .rst(rst), .halt_det(halt_det),
        .branch_taken(branch_taken), .jump(jump_ex),
        .need_mem(need_mem), .need_wb(need_wb),
        .state(state)
    );

    pc_writer u_pc_writer (
        .state(state), .halt_det(halt_det),
        .branch_taken(branch_taken), .jump(jump_ex),
        .pc_plus4(pc_plus4), .branch_target(branch_target),
        .jump_target(jump_target),
        .next_pc(next_pc), .we(pc_we)
    );

    pc u_pc (
        .clk(clk), .rst(rst), .en(pc_we & enable),
        .next(next_pc), .q(pc)
    );

    instr_mem #(.INIT_FILE(IMEM_INIT)) u_imem (
        .addr(pc), .instr(instr)
    );

    // 各周期需要锁存的东西
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ir_reg      <= 32'd0;
            A           <= 32'd0;
            B           <= 32'd0;
            imm_reg     <= 16'd0;
            aluout_reg  <= 32'd0;
            mdr         <= 32'd0;
            dst_reg     <= 5'd0;
            micro_reg   <= 32'd0;
        end else begin
            case (state)
                `S_IF: begin
                    if (!halt_det)
                        ir_reg <= instr;
                end
                `S_ID: begin
                    A         <= rd1;
                    B         <= rd2;
                    imm_reg   <= ir[15:0];
                    dst_reg   <= (ir[31:26] == `OP_R) ? ir[15:11] : ir[20:16];
                    micro_reg <= micro_ir;
                end
                `S_EX: begin
                    aluout_reg <= ex_result;
                end
                `S_MEM: begin
                    if (need_mem && !memw_ex)
                        mdr <= mem_rdata;
                end
                `S_WB: begin
                    // 写寄存器堆由 rf_we 在此时钟沿完成
                end
                default: begin end
            endcase
        end
    end

endmodule
