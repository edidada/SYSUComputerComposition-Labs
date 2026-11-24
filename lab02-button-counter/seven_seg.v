// 四位七段数码管动态扫描显示。
// digit 低电平有效（选中某一位），seg 低电平有效（{g,f,e,d,c,b,a}）。
module seven_seg (
    input  wire        clk,       // 已经分频过的扫描时钟
    input  wire        rst,
    input  wire [15:0] data,
    output reg  [3:0]  digit,
    output reg  [6:0]  seg
);
    reg [1:0] pos;

    // 共阴极段码（高电平有效），输出时取反变成低电平有效
    function [6:0] encode;
        input [3:0] n;
        begin
            case (n)
                4'h0: encode = 7'h3f;
                4'h1: encode = 7'h06;
                4'h2: encode = 7'h5b;
                4'h3: encode = 7'h4f;
                4'h4: encode = 7'h66;
                4'h5: encode = 7'h6d;
                4'h6: encode = 7'h7d;
                4'h7: encode = 7'h07;
                4'h8: encode = 7'h7f;
                4'h9: encode = 7'h6f;
                4'ha: encode = 7'h77;
                4'hb: encode = 7'h7c;
                4'hc: encode = 7'h39;
                4'hd: encode = 7'h5e;
                4'he: encode = 7'h79;
                4'hf: encode = 7'h71;
                default: encode = 7'h00;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            pos   <= 2'd0;
            digit <= 4'hf;
            seg   <= 7'h7f;
        end else begin
            case (pos)
                2'd0: begin digit <= 4'b1110; seg <= ~encode(data[3:0]);  end
                2'd1: begin digit <= 4'b1101; seg <= ~encode(data[7:4]);  end
                2'd2: begin digit <= 4'b1011; seg <= ~encode(data[11:8]); end
                2'd3: begin digit <= 4'b0111; seg <= ~encode(data[15:12]); end
            endcase
            pos <= pos + 1'b1;
        end
    end

endmodule
