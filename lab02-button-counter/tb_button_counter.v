`timescale 1ns / 1ps

module tb_button_counter;

    reg  clk = 0;
    reg  rst = 1;
    reg  btn = 0;
    wire [3:0]  digit;
    wire [6:0]  seg;
    wire [15:0] count;

    button_counter_top uut (
        .clk(clk), .rst(rst), .btn(btn),
        .digit(digit), .seg(seg), .count(count)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    integer i, j, uniq;
    reg [3:0] seen [0:3];

    // 一次干净的按下：高 8 拍，低 4 拍
    task press_clean;
        begin
            repeat (3) @(posedge clk);
            btn = 1'b1;
            repeat (8) @(posedge clk);
            btn = 1'b0;
            repeat (4) @(posedge clk);
        end
    endtask

    // 一次带抖动的按下：中途有一个周期的毛刺，消抖电路应只认一次
    task press_bouncy;
        begin
            repeat (3) @(posedge clk);
            btn = 1'b1;
            repeat (4) @(posedge clk);
            btn = 1'b0;
            repeat (1) @(posedge clk);
            btn = 1'b1;
            repeat (6) @(posedge clk);
            btn = 1'b0;
            repeat (4) @(posedge clk);
        end
    endtask

    task expect_count(input [15:0] exp, input [255:0] tag);
        begin
            if (count !== exp) begin
                $display("FAIL: %s expect %0d got %0d", tag, exp, count);
                errors = errors + 1;
            end else begin
                $display("PASS: %s count=%0d", tag, count);
            end
        end
    endtask

    initial begin
        repeat (5) @(posedge clk);
        rst = 1'b0;
        repeat (2) @(posedge clk);
        expect_count(16'd0, "after reset");

        // 数码管动态扫描：位选应轮流点亮 4 位
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);
            #1;
            seen[i % 4] = digit;
        end
        uniq = 0;
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < i; j = j + 1)
                if (seen[i] == seen[j]) j = i + 1;
            if (j == i) uniq = uniq + 1;
        end
        if (uniq < 2) begin
            $display("FAIL: digit select not scanning (uniq=%0d)", uniq);
            errors = errors + 1;
        end else begin
            $display("PASS: digit select scans %0d distinct positions", uniq);
        end

        press_clean;
        expect_count(16'd1, "one clean press");

        press_bouncy;
        expect_count(16'd2, "one bouncy press counted once");

        press_clean;
        expect_count(16'd3, "third press");

        if (errors == 0)
            $display("lab02 PASS: debounce, counter and display OK");
        else
            $display("lab02 FAIL: %0d error(s)", errors);
        $finish;
    end

endmodule
