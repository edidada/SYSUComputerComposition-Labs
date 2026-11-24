`timescale 1ns / 1ps

module tb_and_gate;

    reg  CLK = 0;
    reg  Data1 = 0;
    reg  Data2 = 0;
    wire Result;

    and_gate uut (
        .CLK(CLK),
        .Data1(Data1),
        .Data2(Data2),
        .Result(Result)
    );

    always #5 CLK = ~CLK;

    integer errors = 0;

    task automatic check(input a, input b, input expected);
        begin
            Data1 = a;
            Data2 = b;
            repeat (2) @(posedge CLK);
            #1;
            if (Result !== expected) begin
                $display("FAIL: a=%b b=%b, expect %b got %b", a, b, expected, Result);
                errors = errors + 1;
            end else begin
                $display("PASS case: a=%b b=%b -> %b", a, b, Result);
            end
        end
    endtask

    initial begin
        repeat (2) @(posedge CLK);
        check(1'b0, 1'b0, 1'b0);
        check(1'b1, 1'b0, 1'b0);
        check(1'b0, 1'b1, 1'b0);
        check(1'b1, 1'b1, 1'b1);

        if (errors == 0)
            $display("lab01 PASS: all 4 input combinations correct");
        else
            $display("lab01 FAIL: %0d error(s)", errors);
        $finish;
    end

endmodule
