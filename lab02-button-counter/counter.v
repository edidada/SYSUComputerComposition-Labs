// 通用加法计数器：en 为 1 时每个时钟加一。
module counter #(
    parameter WIDTH = 16
) (
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    output reg  [WIDTH-1:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else if (en)
            q <= q + 1'b1;
    end

endmodule
