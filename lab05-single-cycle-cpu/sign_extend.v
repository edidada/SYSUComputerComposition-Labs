// 16 位立即数扩展：符号扩展供 addi/lw/sw/分支使用，
// 零扩展供 andi/ori 使用。
module sign_extend (
    input  wire [15:0] imm,
    output wire [31:0] sext,
    output wire [31:0] zext
);
    assign sext = {{16{imm[15]}}, imm};
    assign zext = {16'b0, imm};
endmodule
