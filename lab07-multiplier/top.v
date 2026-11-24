// 实验七顶层：8x8 乘法器 + 拨码输入 + 按键显示切换 + 数码管
module multiplier_top #(
    parameter DISP_DIV = 4
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        btn,
    input  wire [15:0] sw,          // [15:8] 被乘数，[7:0] 乘数
    output wire [15:0] light,       // 两盏灯指示当前显示输入还是结果
    output wire [3:0]  digit,
    output wire [6:0]  seg,
    output wire [15:0] product,
    output wire        done,
    output wire        disp_mode
);
    wire btn_pulse;
    wire slow_clk;

    button_debounce u_debounce (
        .clk(clk), .rst(rst), .btn_in(btn), .btn_pulse(btn_pulse)
    );

    switch u_switch (
        .clk(clk), .rst(rst), .toggle(btn_pulse), .q(disp_mode)
    );

    multiply u_multiply (
        .clk(clk), .rst(rst), .start(btn_pulse),
        .multiplicand(sw[15:8]), .multiplier(sw[7:0]),
        .product(product), .done(done)
    );

    // 显示输入时亮 LED0，显示结果时亮 LED1
    assign light = {14'b00000000000000, ~disp_mode, disp_mode};

    clk_div #(.DIV(DISP_DIV)) u_div (
        .clk(clk), .rst(rst), .clk_out(slow_clk)
    );

    seven_seg u_display (
        .clk(slow_clk), .rst(rst),
        .data(disp_mode ? product : sw),
        .digit(digit), .seg(seg)
    );

endmodule
