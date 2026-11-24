# 实验一：基础与门

## 实验目的

验证"两个开关同时为 1，灯才亮"，建立时钟沿触发的基本概念。

## 设计

`and_gate.v` 只有 10 行有效代码：

```verilog
always @(posedge CLK)
    Result <= Data1 && Data2;
```

注意这里用 `output reg` + `always@(posedge CLK)`，是**时序逻辑**——结果要等下一个时钟上升沿才更新。与门本身是纯组合逻辑（`assign Result = Data1 && Data2;` 即可），课程刻意写成时序版，是为了练习最基础的"时钟沿"概念。

## 验证

```bash
iverilog -g2012 -o sim.out *.v && vvp sim.out
```

测试台遍历 `00 / 10 / 01 / 11` 四种输入，检查下一个时钟沿后的输出。全部正确时打印 `lab01 PASS`。
