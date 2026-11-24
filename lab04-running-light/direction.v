// 把三个物理开关翻译成两位方向码。
// 00 = 保持（暂停）  01 = 复位到最左  10 = 向左递减  11 = 向右递增
module direction (
    input  wire       left_sw,
    input  wire       pause_sw,
    input  wire       reset_sw,
    output reg  [1:0] dir = 2'b11
);

    always @* begin
        if (reset_sw)
            dir = 2'b01;
        else if (pause_sw)
            dir = 2'b00;
        else if (left_sw)
            dir = 2'b10;
        else
            dir = 2'b11;
    end

endmodule
