`timescale 1ns / 1ps

module tb_cpu;

    reg  clk = 0;
    reg  rst = 1;
    reg  enable = 1;
    wire        halt;
    wire [31:0] pc, instr, alu_result, wb_data, mem_rdata;

    single_cpu uut (
        .clk(clk), .rst(rst), .enable(enable),
        .halt(halt), .pc(pc), .instr(instr),
        .alu_result(alu_result), .wb_data(wb_data), .mem_rdata(mem_rdata)
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
        rst = 1'b0;

        for (cycle = 0; cycle < 30; cycle = cycle + 1) begin
            @(posedge clk);
            #1;
            $display("cycle %2d: pc=%h instr=%h alu=%h halt=%b",
                     cycle, pc, instr, alu_result, halt);
        end

        // 加法、减法、逻辑、比较、左移
        check_reg(5'd1,  32'd5);
        check_reg(5'd2,  32'd3);
        check_reg(5'd3,  32'd8);    // add
        check_reg(5'd4,  32'd2);    // sub
        check_reg(5'd5,  32'd1);    // and
        check_reg(5'd6,  32'd7);    // or
        check_reg(5'd7,  32'd1);    // slt
        check_reg(5'd8,  32'd20);   // sll
        check_reg(5'd9,  32'd7);    // addi
        check_reg(5'd10, 32'd4);    // andi
        check_reg(5'd11, 32'd8);    // ori

        // 访存与分支
        check_reg(5'd12, 32'd8);    // lw
        check_reg(5'd13, 32'd42);   // beq 跳转成功，99 被跳过
        check_reg(5'd14, 32'd1);    // bgtz 跳转成功，77 被跳过

        // j 跳转后的指令
        check_reg(5'd15, 32'd100);

        if (uut.u_dmem.mem[0] !== 32'd8) begin
            $display("FAIL: mem[0]=%h expect 8", uut.u_dmem.mem[0]);
            errors = errors + 1;
        end else begin
            $display("PASS: sw wrote 8 to mem[0]");
        end

        if (halt !== 1'b1) begin
            $display("FAIL: halt not asserted at end (pc=%h)", pc);
            errors = errors + 1;
        end else begin
            $display("PASS: halt asserted, pc stopped at %h", pc);
        end

        if (errors == 0)
            $display("lab05 PASS: single-cycle CPU executed all 15 instructions");
        else
            $display("lab05 FAIL: %0d error(s)", errors);
        $finish;
    end

endmodule
