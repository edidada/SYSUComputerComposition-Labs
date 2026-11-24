// 8 x 8 移位相加乘法器（3 状态机）
// stage 00 (IDLE)：等待 start，装载被乘数/乘数
// stage 01 (RUN) ：8 个周期，看乘数最低位决定是否累加被乘数，然后右移乘数、左移被乘数
// stage 10 (DONE)：输出 16 位乘积，拉高 done 一个周期
module multiply (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [7:0]  multiplicand,
    input  wire [7:0]  multiplier,
    output reg  [15:0] product,
    output reg         done
);
    localparam IDLE = 2'd0;
    localparam RUN  = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0]  state;
    reg [15:0] result;
    reg [15:0] extend;
    reg [7:0]  temp;
    reg [2:0]  count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            product  <= 16'd0;
            done     <= 1'b0;
            result   <= 16'd0;
            extend   <= 16'd0;
            temp     <= 8'd0;
            count    <= 3'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        result <= 16'd0;
                        temp   <= multiplier;
                        extend <= {8'd0, multiplicand};
                        count  <= 3'd0;
                        state  <= RUN;
                    end
                end

                RUN: begin
                    if (temp[0])
                        result <= result + extend;
                    temp   <= {1'b0, temp[7:1]};
                    extend <= extend << 1;
                    count  <= count + 1'b1;
                    if (count == 3'd7)
                        state <= DONE;
                end

                DONE: begin
                    product <= result;
                    done    <= 1'b1;
                    state   <= IDLE;
                end

                default:
                    state <= IDLE;
            endcase
        end
    end

endmodule
