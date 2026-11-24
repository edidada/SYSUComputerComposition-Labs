// 参数化二选一多路选择器
module mux2 #(
    parameter WIDTH = 1
) (
    input  wire             sel,
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    output wire [WIDTH-1:0] y
);
    assign y = sel ? d1 : d0;
endmodule
