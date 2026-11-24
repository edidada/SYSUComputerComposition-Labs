#!/usr/bin/env bash
# 逐个实验编译并运行 testbench，汇总结果
set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

for lab in lab01-and-gate lab02-button-counter lab03-four-bit-adder \
           lab04-running-light lab05-single-cycle-cpu \
           lab06-multi-cycle-cpu lab07-multiplier; do
  dir="$ROOT/$lab"
  echo "================== $lab =================="
  if (cd "$dir" && iverilog -g2012 -o sim.out *.v && vvp sim.out); then
    echo "[$lab] PASS"
    PASS=$((PASS+1))
  else
    echo "[$lab] FAIL"
    FAIL=$((FAIL+1))
  fi
  rm -f "$dir/sim.out"
done

echo "================== SUMMARY =================="
echo "PASS: $PASS  FAIL: $FAIL"
if [ "$FAIL" -ne 0 ]; then
  exit 1
fi
