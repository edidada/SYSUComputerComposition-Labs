// 实验三顶层：四位二进制加法 + 按键切换显示
module four_adder_top #(
    parameter DISP_DIV = 4
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  a,
    input  wire [3:0]  b,
    input  wire        btn_left,    // 显示两个输入
    input  wire        btn_right,   // 显示结果
    output wire [3:0]  digit,
    output wire [6:0]  seg,
    output wire        cf,
    output wire        of,
    output wire [3:0]  sum,
    output wire [7:0]  disp_data,   // 调试用：当前送数码管的数据
    output wire        disp_mode    // 0=显示输入，1=显示结果
);
    wire slow_clk;
    wire left_pulse, right_pulse;

    clk_div #(.DIV(DISP_DIV)) u_div (
        .clk(clk), .rst(rst), .clk_out(slow_clk)
    );

    button_debounce u_deb_l (.clk(clk), .rst(rst), .btn_in(btn_left),  .btn_pulse(left_pulse));
    button_debounce u_deb_r (.clk(clk), .rst(rst), .btn_in(btn_right), .btn_pulse(right_pulse));

    // 两个按钮分别把显示模式切到 0 / 1
    reg mode;
    always @(posedge clk) begin
        if (rst)
            mode <= 1'b0;
        else if (left_pulse)
            mode <= 1'b0;
        else if (right_pulse)
            mode <= 1'b1;
    end
    assign disp_mode = mode;

    adder4 u_adder (
        .a(a), .b(b), .sum(sum), .cf(cf), .of(of)
    );

    mux2 #(.WIDTH(8)) u_mux (
        .sel(mode),
        .d0({a, b}),
        .d1({4'b0000, sum}),
        .y(disp_data)
    );

    seven_seg u_display (
        .clk(slow_clk), .rst(rst), .data({8'b00000000, disp_data}),
        .digit(digit), .seg(seg)
    );

endmodule
