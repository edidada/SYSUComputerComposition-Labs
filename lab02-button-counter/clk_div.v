// 时钟分频：每 DIV/2 个时钟周期翻转一次输出，得到 DIV 分频的方波。
// DIV 必须为偶数；仿真时用 4，上板可改成 100000 等大数值。
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
