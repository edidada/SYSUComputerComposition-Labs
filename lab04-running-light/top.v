// 实验四顶层：可调速、可换向、可暂停、可复位的 16 位流水灯
module running_light_top #(
    parameter BASE = 32
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  speed,
    input  wire        left_sw,
    input  wire        pause_sw,
    input  wire        reset_sw,
    output wire [15:0] led,
    output wire [3:0]  pos
);
    wire       slow_clk;
    wire [1:0] dir;

    clk_div #(.BASE(BASE)) u_div (
        .clk(clk), .rst(rst), .speed(speed), .clk_out(slow_clk)
    );

    direction u_direction (
        .left_sw(left_sw), .pause_sw(pause_sw), .reset_sw(reset_sw),
        .dir(dir)
    );

    reg [3:0] position;
    // 复位用异步方式，保证分频器还没翻转时位置也已经初始化
    always @(posedge slow_clk or posedge rst) begin
        if (rst)
            position <= 4'd0;
        else begin
            case (dir)
                2'b00: position <= position;                       // 暂停
                2'b01: position <= 4'd0;                           // 复位到最左
                2'b10: position <= (position == 0) ? 4'd15 : position - 1'd1;
                2'b11: position <= (position == 15) ? 4'd0  : position + 1'd1;
                default: position <= position;
            endcase
        end
    end

    assign pos = position;

    light_decode u_decode (
        .num(position), .led(led)
    );

endmodule
