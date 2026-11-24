// 32 x 32 寄存器堆。0 号寄存器恒为 0。
// 组合读出 + 同一时钟上升沿非阻塞写入：读到的仍是写之前的旧值，
// 正好是单周期 CPU 需要的语义（不能用下降沿写，否则那时 PC 已指向下一条指令）。
module regfile #(
    parameter WIDTH = 32
) (
    input  wire             clk,
    input  wire             rst,
    input  wire             we,
    input  wire [4:0]       raddr1,
    input  wire [4:0]       raddr2,
    input  wire [4:0]       waddr,
    input  wire [WIDTH-1:0] wdata,
    output wire [WIDTH-1:0] rdata1,
    output wire [WIDTH-1:0] rdata2
);
    reg [WIDTH-1:0] regs [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = {WIDTH{1'b0}};
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= {WIDTH{1'b0}};
        end else if (we && (waddr != 5'd0)) begin
            regs[waddr] <= wdata;
        end
    end

    assign rdata1 = (raddr1 == 5'd0) ? {WIDTH{1'b0}} : regs[raddr1];
    assign rdata2 = (raddr2 == 5'd0) ? {WIDTH{1'b0}} : regs[raddr2];

endmodule
