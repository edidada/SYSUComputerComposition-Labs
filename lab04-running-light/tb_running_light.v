`timescale 1ns / 1ps

module tb_running_light;

    reg  clk = 0;
    reg  rst = 0;
    reg  [1:0] speed = 2'd3;
    reg  left_sw = 0;
    reg  pause_sw = 0;
    reg  reset_sw = 0;
    wire [15:0] led;
    wire [3:0]  pos;

    running_light_top #(.BASE(32)) uut (
        .clk(clk), .rst(rst), .speed(speed),
        .left_sw(left_sw), .pause_sw(pause_sw), .reset_sw(reset_sw),
        .led(led), .pos(pos)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    reg [3:0] saved;

    task check_pos(input [3:0] exp, input [255:0] tag);
        begin
            if (pos !== exp) begin
                $display("FAIL: %s expect pos=%0d got %0d", tag, exp, pos);
                errors = errors + 1;
            end else begin
                $display("PASS: %s pos=%0d led=%b", tag, pos, led);
            end
        end
    endtask

    initial begin
        rst = 1'b1;
        repeat (4) @(posedge clk);
        rst = 1'b0;
        #1;
        check_pos(4'd0, "after reset");

        // 默认向右递增
        @(posedge uut.slow_clk); #1;
        check_pos(4'd1, "step right");

        // 暂停：位置不应变化
        pause_sw = 1'b1;
        @(posedge uut.slow_clk); #1;
        saved = pos;
        @(posedge uut.slow_clk); #1;
        if (pos !== saved) begin
            $display("FAIL: pause did not hold position (%0d -> %0d)", saved, pos);
            errors = errors + 1;
        end else begin
            $display("PASS: pause holds position %0d", pos);
        end

        // 向左递减，到达 0 后绕回 15
        pause_sw = 1'b0;
        left_sw  = 1'b1;
        @(posedge uut.slow_clk); #1;
        check_pos(4'd0, "step left to zero");
        @(posedge uut.slow_clk); #1;
        check_pos(4'd15, "step left wraps to 15");

        // 复位开关：回到最左
        left_sw  = 1'b0;
        reset_sw = 1'b1;
        @(posedge uut.slow_clk); #1;
        check_pos(4'd0, "reset switch");

        // 方向码编码
        reset_sw = 1'b0;
        pause_sw = 1'b1; #1;
        if (uut.dir !== 2'b00) begin errors = errors + 1; $display("FAIL: dir pause"); end
        pause_sw = 1'b0; left_sw = 1'b1; #1;
        if (uut.dir !== 2'b10) begin errors = errors + 1; $display("FAIL: dir left"); end
        left_sw = 1'b0; reset_sw = 1'b1; #1;
        if (uut.dir !== 2'b01) begin errors = errors + 1; $display("FAIL: dir reset"); end
        reset_sw = 1'b0; #1;
        if (uut.dir !== 2'b11) begin errors = errors + 1; $display("FAIL: dir right"); end
        if (errors == 0) $display("PASS: direction encoding 00/01/10/11");

        // 灯形必须是独热码
        if (led !== (16'b1 << pos)) begin
            $display("FAIL: led not one-hot at pos=%0d", pos);
            errors = errors + 1;
        end else begin
            $display("PASS: led is one-hot at pos=%0d", pos);
        end

        if (errors == 0)
            $display("lab04 PASS: running light controls OK");
        else
            $display("lab04 FAIL: %0d error(s)", errors);
        $finish;
    end

endmodule
