`include "defs.vh"

// 32 位 ALU：加减逻辑、小于置 1、左移，以及 bgtz 用的"大于 0 置 1"。
module alu (
    input  wire [3:0]  op,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] result,
    output wire        zero,
    output wire        gtz
);

    always @* begin
        case (op)
            `ALU_ADD: result = a + b;
            `ALU_SUB: result = a - b;
            `ALU_AND: result = a & b;
            `ALU_OR:  result = a | b;
            `ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            `ALU_SLL: result = a << b[4:0];
            `ALU_GTZ: result = ($signed(a) > 32'sd0) ? 32'd1 : 32'd0;
            default:  result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);
    assign gtz  = result[0];   // ALU_GTZ 时 result 非 0 即 a > 0

endmodule
