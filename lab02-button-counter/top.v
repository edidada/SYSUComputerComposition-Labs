// 实验二顶层：按键计数 + 数码管显示
// 顶层本身是一张接线图，把分频、消抖、计数、显示四个零件连起来。
module button_counter_top #(
    parameter DISP_DIV = 4,     // 显示扫描分频，上板改大
    parameter DEB_CLK  = 1      // 消抖采样分频（仿真时 1）
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        btn,
    output wire [3:0]  digit,
    output wire [6:0]  seg,
    output wire [15:0] count
);
    wire slow_clk;
    wire btn_pulse;

    clk_div #(.DIV(DISP_DIV)) u_div (
        .clk(clk), .rst(rst), .clk_out(slow_clk)
    );

    button_debounce u_debounce (
        .clk(clk), .rst(rst), .btn_in(btn), .btn_pulse(btn_pulse)
    );

    counter #(.WIDTH(16)) u_counter (
        .clk(clk), .rst(rst), .en(btn_pulse), .q(count)
    );

    seven_seg u_display (
        .clk(slow_clk), .rst(rst), .data(count),
        .digit(digit), .seg(seg)
    );

endmodule
