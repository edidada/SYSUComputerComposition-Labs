// 翻转开关：每来一个脉冲，输出取反一次（按一次切到 0，再按切到 1）。
module switch (
    input  wire       clk,
    input  wire       rst,
    input  wire       toggle,
    output reg        q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 1'b0;
        else if (toggle)
            q <= ~q;
    end
endmodule
