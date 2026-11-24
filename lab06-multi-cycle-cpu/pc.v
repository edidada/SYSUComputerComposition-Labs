// 程序计数器：复位清零；en 为 1 时每个时钟沿装载下一条地址。
// halt 时顶层把 en 拉低，PC 就停在停机指令上。
module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire [31:0] next,
    output reg  [31:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= 32'd0;
        else if (en)
            q <= next;
    end

endmodule
