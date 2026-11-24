// 指令存储器：按字节地址寻址，实际取出 mem[addr/4] 的一条 32 位指令。
// 程序用 $readmemh 从 program.hex 装载（每行一条 32 位十六进制指令）。
module instr_mem #(
    parameter DEPTH      = 1024,
    parameter PROG_WORDS = 22,
    parameter INIT_FILE  = "program.hex"
) (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:DEPTH-1];

    initial begin
        $readmemh(INIT_FILE, mem, 0, PROG_WORDS-1);
    end

    assign instr = mem[addr[31:2]];

endmodule
