// 显示扫描分频：DIV/2 个周期翻转一次，DIV 为偶数。
module clk_div #(
    parameter DIV = 4
) (
    input  wire       clk,
    input  wire       rst,
    output reg        clk_out
);
    reg [31:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt     <= 32'd0;
            clk_out <= 1'b0;
        end else if (cnt == DIV/2 - 1) begin
            cnt     <= 32'd0;
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule
