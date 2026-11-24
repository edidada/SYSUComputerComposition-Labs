// 把一个 0~15 的位置编号译成 16 位独热灯形：pos 那一位亮。
module light_decode (
    input  wire [3:0]  num,
    output wire [15:0] led
);
    assign led = 16'b1 << num;
endmodule
