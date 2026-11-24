`include "defs.vh"

// 决定 PC 何时更新、更新成什么。
// - IF 周期：PC <= PC + 4
// - EX 周期：分支/跳转成立时，PC <= 分支目标或跳转目标
module pc_writer (
    input  wire [4:0]  state,
    input  wire        halt_det,
    input  wire        branch_taken,
    input  wire        jump,
    input  wire [31:0] pc_plus4,
    input  wire [31:0] branch_target,
    input  wire [31:0] jump_target,
    output reg  [31:0] next_pc,
    output reg         we
);

    always @* begin
        next_pc = pc_plus4;
        we      = 1'b0;
        if (state == `S_IF && !halt_det) begin
            next_pc = pc_plus4;
            we      = 1'b1;
        end else if (state == `S_EX && (branch_taken || jump)) begin
            next_pc = jump ? jump_target : branch_target;
            we      = 1'b1;
        end
    end

endmodule
