# 计算机组成原理实验（中山大学 2022 级 · 从零实现版）

这是 `SYSUComputerComposition`（课程资料归档库）的配套实验仓库。**归档库保存原始报告与历史工程，本仓库从头重写 7 个实验**，每个实验都带可自动比对的 testbench，用 Icarus Verilog 一键验证。

课程选用的是裁剪过的 MIPS 指令集： Patterson & Hennessy 前几版教材、讲义、板卡配套和题库形成了一整套成熟的教学供应链——老师选的是"能让学生做完"的教学路线，不是在 ISA 之间做技术评测。那句"请坐和放宽，认真完成实验就好"，配合这份 15 条指令的裁剪集，气质就是**让大家能做完、能理解**。

## 目录

| 目录 | 实验 | 核心内容 |
| --- | --- | --- |
| `lab01-and-gate/` | 基础实验 | 时序版与门：理解时钟沿 |
| `lab02-button-counter/` | 基础外设 | 分频 + 三级消抖 + 计数 + 数码管 |
| `lab03-four-bit-adder/` | 实验三 | 四位先行进位加法器，CF / OF，按键切换显示 |
| `lab04-running-light/` | 实验四 | 16 位流水灯：调速 / 换向 / 暂停 / 复位 |
| `lab05-single-cycle-cpu/` | 实验五 | 单周期 MIPS CPU，15 条指令 |
| `lab06-multi-cycle-cpu/` | 实验六 | 多周期 MIPS CPU，5 状态 + 微指令字 + 硬件复用 |
| `lab07-multiplier/` | 实验七 | 8×8 移位相加乘法器，3 状态机 |

每个实验目录里都有：

- 模块源码 `.v`
- `tb_*.v` 测试台（自带断言，直接打印 PASS / FAIL）
- `README.md`（实验要求、设计思路、仿真方法）

## 15 条指令集

| 类型 | 指令 | opcode / funct |
| --- | --- | --- |
| R 型 | `add` `sub` `and` `or` `slt` `sll` | `000000` / `20 22 24 25 2a 00` |
| I 型运算 | `addi` `andi` `ori` | `08` `0c` `0d` |
| 访存 | `lw` `sw` | `23` `2b` |
| 分支 | `beq` `bgtz` | `04` `07` |
| 跳转 | `j` | `02` |
| 停机 | `halt` | `3f` |

助记符沿用原课程的 `src1 src2 tar`（而不是 `rs rt rd`）：`src1` / `src2` 只读，`tar` 只写，这样 I 型指令是否写寄存器一眼可辨，译码器可以直接输出寄存器编号。

## 一键运行

从仓库根目录执行：

```bash
bash run_tests.sh
```

脚本会逐个实验调用 `iverilog` 编译、用 `vvp` 运行测试台，汇总 PASS / FAIL。

单独跑一个实验（以实验五为例）：

```bash
cd lab05-single-cycle-cpu
iverilog -g2012 -o sim.out *.v
vvp sim.out
```

需要 Icarus Verilog（本机为 12.0）；在 Windows 上可用 Git Bash 运行以上命令。

## 与归档库的关系

- 归档库保留了原始工程和报告，其中 `SingleCPU/SingleCPU.v` 存在控制器端口不一致的已知问题（顶层按位拆信号，`Control.v` 却输出 32 位 `MicroInstruct`）。
- 本仓库重写时统一了接口：单周期版直接输出控制信号，多周期版使用 32 位微指令字，两者都能编译通过并跑通测试程序。
- 本站代码仅用于个人学习与验证，请不要直接抄写作业。
