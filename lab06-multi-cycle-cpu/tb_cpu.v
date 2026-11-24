`timescale 1ns / 1ps

module tb_cpu;

    reg  clk = 0;
    reg  rst = 1;
    reg  enable = 1;
    wire        halt;
    wire [4:0]  state;
    wire [31:0] pc, ir, aluout, micro, micro_ex;

    multi_cpu uut (
        .clk(clk), .rst(rst), .enable(enable),
        .halt(halt), .state(state), .pc(pc), .ir(ir),
        .aluout(aluout), .micro(micro), .micro_ex(micro_ex)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    integer cycle;

    task check_reg(input [4:0] n, input [31:0] exp);
        begin
            if (uut.u_rf.regs[n] !== exp) begin
                $display("FAIL: $%0d = %h, expect %h", n, uut.u_rf.regs[n], exp);
                errors = errors + 1;
            end else begin
                $display("PASS: $%0d = %0d", n, exp);
            end
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        #1;                 // 避开复位释放与时钟沿的竞争
        rst = 1'b0;

        for (cycle = 0; cycle < 120; cycle = cycle + 1) begin
            @(posedge clk);
            #1;
            if (cycle < 12)
                $display("cycle %3d: state=%b pc=%h ir=%h micro=%h halt=%b",
                         cycle, state, pc, ir, micro_ex, halt);
        end

        check_reg(5'd1,  32'd5);
        check_reg(5'd2,  32'd3);
        check_reg(5'd3,  32'd8);
        check_reg(5'd4,  32'd2);
        check_reg(5'd5,  32'd1);
        check_reg(5'd6,  32'd7);
        check_reg(5'd7,  32'd1);
        check_reg(5'd8,  32'd20);
        check_reg(5'd9,  32'd7);
        check_reg(5'd10, 32'd4);
        check_reg(5'd11, 32'd8);
        check_reg(5'd12, 32'd8);
        check_reg(5'd13, 32'd42);
        check_reg(5'd14, 32'd1);
        check_reg(5'd15, 32'd100);

        if (uut.u_dm.mem[0] !== 32'd8) begin
            $display("FAIL: mem[0]=%h expect 8", uut.u_dm.mem[0]);
            errors = errors + 1;
        end else begin
            $display("PASS: sw wrote 8 to mem[0]");
        end

        if (halt !== 1'b1 || state !== 5'b10000) begin
            $display("FAIL: not halted at IF (halt=%b state=%b pc=%h)", halt, state, pc);
            errors = errors + 1;
        end else begin
            $display("PASS: halted at IF, pc=%h", pc);
        end

        if (errors == 0)
            $display("lab06 PASS: multi-cycle CPU executed all 15 instructions");
        else
            $display("lab06 FAIL: %0d error(s)", errors);
        $finish;
    end

endmodule
