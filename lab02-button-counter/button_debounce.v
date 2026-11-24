// 按键消抖：三级触发器滤掉机械抖动，再取上升沿输出一个单周期脉冲。
// 按键必须连续 3 拍为高才认可为"按下"，连续 3 拍为低才认可为"松开"。
module button_debounce (
    input  wire       clk,
    input  wire       rst,
    input  wire       btn_in,
    output wire       btn_pulse
);
    reg [2:0] shift;
    reg       level;
    reg       prev_level;

    always @(posedge clk) begin
        if (rst) begin
            shift      <= 3'b000;
            level      <= 1'b0;
            prev_level <= 1'b0;
        end else begin
            shift <= {shift[1:0], btn_in};
            if (shift == 3'b111)
                level <= 1'b1;
            else if (shift == 3'b000)
                level <= 1'b0;
            prev_level <= level;
        end
    end

    assign btn_pulse = level & ~prev_level;

endmodule
