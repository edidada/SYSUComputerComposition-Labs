`timescale 1ns / 1ps

module tb_four_adder;

    reg  clk = 0;
    reg  rst = 1;
    reg  [3:0] a = 4'd0;
    reg  [3:0] b = 4'd0;
    reg  btn_left = 0;
    reg  btn_right = 0;

    wire [3:0] digit;
    wire [6:0] seg;
    wire       cf;
    wire       of;
    wire [3:0] sum;
    wire [7:0] disp_data;
    wire       disp_mode;

    four_adder_top uut (
        .clk(clk), .rst(rst), .a(a), .b(b),
        .btn_left(btn_left), .btn_right(btn_right),
        .digit(digit), .seg(seg), .cf(cf), .of(of),
        .sum(sum), .disp_data(disp_data), .disp_mode(disp_mode)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    integer i, j, exp_sum, exp_cf, sa, sb, ss, exp_of;

    // which: 0 = 左键（显示输入），1 = 右键（显示结果）
    task press(input which);
        begin
            repeat (3) @(posedge clk);
            if (which == 0) btn_left = 1'b1;
            else            btn_right = 1'b1;
            repeat (6) @(posedge clk);
            if (which == 0) btn_left = 1'b0;
            else            btn_right = 1'b0;
            repeat (4) @(posedge clk);
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        rst = 1'b0;
        repeat (2) @(posedge clk);

        // 穷举 16 x 16 种输入，逐项比对和、进位、溢出
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i % 16;
                b = j % 16;
                #1;
                exp_sum = (i + j) % 16;
                exp_cf  = (i + j) / 16;
                sa = (i >= 8) ? i - 16 : i;
                sb = (j >= 8) ? j - 16 : j;
                ss = sa + sb;
                exp_of = (ss > 7 || ss < -8) ? 1 : 0;

                if (sum !== exp_sum[3:0] || cf !== exp_cf[0] || of !== exp_of[0]) begin
                    $display("FAIL: a=%0d b=%0d sum=%b(exp %b) cf=%b(exp %b) of=%b(exp %b)",
                             i, j, sum, exp_sum[3:0], cf, exp_cf[0], of, exp_of[0]);
                    errors = errors + 1;
                end
            end
        end
        if (errors == 0)
            $display("PASS: adder4 exhaustive 256 cases OK");

        // 几个报告里出现的典型例子
        a = 4'd12; b = 4'd4;  #1;
        $display("12+4=%0d cf=%b of=%b", sum, cf, of);
        a = 4'd12; b = 4'd8;  #1;
        $display("12+8=%0d cf=%b of=%b", sum, cf, of);

        // 按钮切换显示
        a = 4'b1100; b = 4'b0100;
        press(1);
        #1;
        if (disp_mode !== 1'b1 || disp_data !== {4'b0000, sum}) begin
            $display("FAIL: right button mode=%b data=%b", disp_mode, disp_data);
            errors = errors + 1;
        end else begin
            $display("PASS: right button shows result %b", disp_data);
        end

        press(0);
        #1;
        if (disp_mode !== 1'b0 || disp_data !== {a, b}) begin
            $display("FAIL: left button mode=%b data=%b", disp_mode, disp_data);
            errors = errors + 1;
        end else begin
            $display("PASS: left button shows inputs %b", disp_data);
        end

        if (errors == 0)
            $display("lab03 PASS: adder and display mux correct");
        else
            $display("lab03 FAIL: %0d error(s)", errors);
        $finish;
    end

endmodule
