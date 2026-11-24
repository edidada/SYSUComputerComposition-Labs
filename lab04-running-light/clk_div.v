// 可调速分频器：BASE 为基准分频值，speed 越大分频越小（跑得越快）。
// 每 (BASE >> speed)/2 个时钟翻转一次输出。
module clk_div #(
    parameter BASE = 32
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  speed,
    output reg         clk_out
);
    reg [31:0] cnt;
    wire [31:0] half = (BASE >> speed) >> 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt     <= 32'd0;
            clk_out <= 1'b0;
        end else if (cnt >= half - 1) begin
            cnt     <= 32'd0;
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

endmodule
