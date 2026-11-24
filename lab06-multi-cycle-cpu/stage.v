`include "defs.vh"

// 5 状态独热码状态机。
// 根据微指令的 [31]（需访存）和 [30]（需写回）按需跳过某些周期：
//   R 型：IF -> ID -> EX -> WB
//   lw  ：IF -> ID -> EX -> MEM -> WB
//   beq ：IF -> ID -> EX
module stage (
    input  wire        clk,
    input  wire        rst,
    input  wire        halt_det,   // 当前取到的指令是 halt
    input  wire        branch_taken,
    input  wire        jump,
    input  wire        need_mem,
    input  wire        need_wb,
    output reg  [4:0]  state
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= `S_IF;
        else begin
            case (state)
                `S_IF:
                    state <= halt_det ? `S_IF : `S_ID;
                `S_ID:
                    state <= `S_EX;
                `S_EX: begin
                    if (branch_taken || jump)
                        state <= `S_IF;
                    else if (need_mem)
                        state <= `S_MEM;
                    else if (need_wb)
                        state <= `S_WB;
                    else
                        state <= `S_IF;
                end
                `S_MEM:
                    state <= need_wb ? `S_WB : `S_IF;
                `S_WB:
                    state <= `S_IF;
                default:
                    state <= `S_IF;
            endcase
        end
    end

endmodule
