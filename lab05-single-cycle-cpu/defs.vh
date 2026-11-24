// 15 条裁剪 MIPS 指令的编码定义（与课程实验报告一致）
`define OP_R      6'h00
`define OP_ADDI   6'h08
`define OP_ANDI   6'h0c
`define OP_ORI    6'h0d
`define OP_LW     6'h23
`define OP_SW     6'h2b
`define OP_BEQ    6'h04
`define OP_BGTZ   6'h07
`define OP_J      6'h02
`define OP_HALT   6'h3f

`define FUN_ADD   6'h20
`define FUN_SUB   6'h22
`define FUN_AND   6'h24
`define FUN_OR    6'h25
`define FUN_SLT   6'h2a
`define FUN_SLL   6'h00

`define ALU_ADD   4'd0
`define ALU_SUB   4'd1
`define ALU_AND   4'd2
`define ALU_OR    4'd3
`define ALU_SLT   4'd4
`define ALU_SLL   4'd5
`define ALU_GTZ   4'd6

`define A_RS      2'd0   // ALU 左操作数取 rs 寄存器
`define A_RT      2'd1   // ALU 左操作数取 rt 寄存器（sll）
`define A_SHAMT   2'd2   // ALU 左操作数取 shamt（备用）

`define B_RT      2'd0   // ALU 右操作数取 rt 寄存器
`define B_SEXT    2'd1   // 符号扩展立即数
`define B_ZEXT    2'd2   // 零扩展立即数（andi/ori）
`define B_SHAMT   2'd3   // 取 shamt（sll）

`define BR_NONE   2'd0
`define BR_BEQ    2'd1
`define BR_BGTZ   2'd2
