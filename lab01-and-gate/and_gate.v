// 实验一：基础与门（时序版）
// 两个拨码开关同时为 1 时，时钟沿到来后 LED 点亮。
// 故意写成时序逻辑，为了练"时钟沿触发"这个概念。
module and_gate (
    input  wire       CLK,
    input  wire       Data1,
    input  wire       Data2,
    output reg        Result
);

    always @(posedge CLK) begin
        Result <= Data1 && Data2;
    end

endmodule
