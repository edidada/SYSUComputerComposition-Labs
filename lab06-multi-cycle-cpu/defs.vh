// 与单周期版相同的 15 条指令编码
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

`define A_RS      2'd0
`define A_RT      2'd1
`define A_SHAMT   2'd2
`define B_RT      2'd0
`define B_SEXT    2'd1
`define B_ZEXT    2'd2
`define B_SHAMT   2'd3

`define BR_NONE   2'd0
`define BR_BEQ    2'd1
`define BR_BGTZ   2'd2

// 5 个周期的独热状态编码
`define S_IF      5'b10000
`define S_ID      5'b01000
`define S_EX      5'b00100
`define S_MEM     5'b00010
`define S_WB      5'b00001

// 32 位微指令字的字段位置
// [31] 需要访存周期   [30] 需要写回周期   [29] 停机
// [28:25] ALU 操作    [24:23] ALU 左操作数选择   [22:21] 右操作数选择
// [20] 写内存         [19] 写回选内存            [18:17] 分支类型
// [16] 跳转
`define MIC_MEM   31
`define MIC_WB    30
`define MIC_HALT  29
`define MIC_ALU_H 28
`define MIC_ALU_L 25
`define MIC_A_H   24
`define MIC_A_L   23
`define MIC_B_H   22
`define MIC_B_L   21
`define MIC_MEMW  20
`define MIC_M2R   19
`define MIC_BR_H  18
`define MIC_BR_L  17
`define MIC_JUMP  16
