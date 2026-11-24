// 数据存储器：32 位字寻址，读组合、写同步。
module data_mem #(
    parameter DEPTH = 256
) (
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);
    reg [31:0] mem [0:DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 32'd0;
    end

    assign rdata = mem[addr[31:2]];

    always @(posedge clk) begin
        if (we)
            mem[addr[31:2]] <= wdata;
    end

endmodule
