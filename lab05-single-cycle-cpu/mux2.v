// 参数化二选一：本设计里所有多选器都是 32 位二路，复用同一个模块。
module mux2 #(
    parameter WIDTH = 32
) (
    input  wire             sel,
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    output wire [WIDTH-1:0] y
);
    assign y = sel ? d1 : d0;
endmodule
