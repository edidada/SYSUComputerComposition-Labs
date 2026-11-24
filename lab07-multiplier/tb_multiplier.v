`timescale 1ns / 1ps

module tb_multiplier;

    reg  clk = 0;
    reg  rst = 1;

    // 直接测乘法器核心
    reg         start = 0;
    reg  [7:0]  a = 0;
    reg  [7:0]  b = 0;
    wire [15:0] product;
    wire        done;

    multiply uut (
        .clk(clk), .rst(rst), .start(start),
        .multiplicand(a), .multiplier(b),
        .product(product), .done(done)
    );

    // 顶层外设也顺带验一下：按键切换显示 + 启动乘法
    reg         top_btn = 0;
    reg  [15:0] top_sw = 16'h0000;
    wire [15:0] top_light;
    wire [3:0]  top_digit;
    wire [6:0]  top_seg;
    wire [15:0] top_product;
    wire        top_done;
    wire        top_mode;

    multiplier_top u_top (
        .clk(clk), .rst(rst), .btn(top_btn), .sw(top_sw),
        .light(top_light), .digit(top_digit), .seg(top_seg),
        .product(top_product), .done(top_done), .disp_mode(top_mode)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    integer i, k;
    reg [15:0] exp;

    task run_mul(input [7:0] aa, input [7:0] bb);
        begin
            @(posedge clk);
            #1;
            a = aa;
            b = bb;
            start = 1'b1;
            @(posedge clk);
            #1;
            start = 1'b0;
            k = 0;
            while (!done && k < 20) begin
                @(posedge clk);
                #1;
                k = k + 1;
            end
            if (!done) begin
                $display("FAIL: %0d * %0d timeout", aa, bb);
                errors = errors + 1;
            end else begin
                exp = {8'd0, aa} * {8'd0, bb};   // 先扩到 16 位再乘
                if (product !== exp) begin
                    $display("FAIL: %0d * %0d = %0d, expect %0d", aa, bb, product, exp);
                    errors = errors + 1;
                end else begin
                    $display("PASS: %0d * %0d = %0d", aa, bb, exp);
                end
            end
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        #1;
        rst = 1'b0;
        repeat (2) @(posedge clk);

        run_mul(8'd0,   8'd0);
        run_mul(8'd1,   8'd1);
        run_mul(8'd255, 8'd255);
        run_mul(8'd12,  8'd34);
        run_mul(8'd200, 8'd3);
        run_mul(8'd7,   8'd9);

        for (i = 0; i < 40; i = i + 1)
            run_mul($random % 256, $random % 256);

        if (errors == 0)
            $display("PASS: multiplier core 46 cases OK");

        // 顶层：按一下键，切换显示模式并启动一次乘法
        top_sw = {8'd12, 8'd34};
        repeat (3) @(posedge clk);
        top_btn = 1'b1;
        repeat (6) @(posedge clk);
        top_btn = 1'b0;
        k = 0;
        while (!top_done && k < 20) begin
            @(posedge clk);
            #1;
            k = k + 1;
        end
        if (top_product !== 16'd408 || top_mode !== 1'b1) begin
            $display("FAIL: top product=%0d mode=%b (expect 408 / 1)", top_product, top_mode);
            errors = errors + 1;
        end else begin
            $display("PASS: top button starts multiply and toggles display: %0d", top_product);
        end

        if (errors == 0)
            $display("lab07 PASS: 8x8 shift-add multiplier correct");
        else
            $display("lab07 FAIL: %0d error(s)", errors);
        $finish;
    end

endmodule
