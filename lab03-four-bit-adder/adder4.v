// 四位先行进位加法器（carry-lookahead）
// 每一位的进位用表达式"并行"算出来，不必等前一位逐级传递。
// CF = 最高位进位输出；OF = 次高位进位 xor 最高位进位（有符号溢出）。
module adder4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [3:0] sum,
    output wire       cf,
    output wire       of
);
    wire [3:0] p = a ^ b;   // P：进位传递
    wire [3:0] g = a & b;   // G：进位产生

    wire c1 = g[0];                       // 最低位无进位输入
    wire c2 = g[1] | (p[1] & c1);
    wire c3 = g[2] | (p[2] & c2);
    wire c4 = g[3] | (p[3] & c3);

    assign sum = p ^ {c3, c2, c1, 1'b0};
    assign cf  = c4;
    assign of  = c3 ^ c4;

endmodule
