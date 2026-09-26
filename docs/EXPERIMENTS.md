# Experiments and labs

Labs 4 to 8 are now **built** in the performance edition (see [PERFORMANCE.md](PERFORMANCE.md)),
behind parameters. Do them in the other direction: switch one feature off in `src/Riscv64.sv` and
`model/core.js` (`CONFIGS`), predict the change with the cycle equation, then measure it with
`make test` and `make timing`. Or re-implement one yourself from the baseline build.

Each lab changes one thing, predicts the effect with the equation from [MATH.md](MATH.md), then
measures it. Labs 1 to 3 need no code changes. For labs that change the RTL, change
[`model/core.js`](../model/core.js) the same way and keep `make test` passing: the model and RTL
must still agree on every cycle, which is the best proof that you understand your change.

## Lab 1: history length (no code)

```bash
make bp PROG=06_bubble_sort
make bp PROG=09_primes_sieve
```

![sweep](img/charts/predictor_sweep.svg)

Measured cycles on the original design ([performance edition table](img/charts/predictor_sweep.md)):

| program | off | 2 bits | **4 bits (tape-out)** | 6 bits | 10 bits |
|---|---:|---:|---:|---:|---:|
| 06_bubble_sort | **1069** | 1091 | 1124 | 1073 | 1143 |
| 09_primes_sieve | 20897 | 20152 | **19773** | 19847 | 19876 |
| 11_gshare_patterns | 2106 | 2006 | 1519 | **1517** | 1520 |

Questions: why is bubble sort *faster* with no predictor at 4 bits? (Hint: its inner branch changes
behaviour as the array gets sorted, and each extra history bit gives it more counters to train.)
Combine with the area table in [SILICON.md](SILICON.md): which history length would you tape out?

## Lab 2: counter reset value

Counters reset to `2'b10` (weakly taken), as in the original. Change the reset in
`GSharePredictor` and `GShare` in `model/core.js` to `2'b01` and compare `make bp` results. Which
programs care, and why only at the start?

## Lab 3: the real cost of each hazard (no code)

```bash
make charts
```

![CPI stack](img/charts/cpi_stack.svg)

For each program, which colour is largest? Predict the new cycle count if that hazard disappeared
completely, using `cycles = N + 5 + L + 3F + R`.

## Lab 4: a multi-cycle divider

The `MultiplyDivideUnit` is combinational: a 64-bit divide in one cycle is a very long path. Replace
it with a 1-bit-per-cycle restoring divider (64 cycles) that stalls EXECUTE. You will need a new
stall source next to `LOAD_STALL` that also holds EXECUTE. Measure CPI on a divide-heavy program.

## Lab 5: remove false load stalls

`LOAD_STALL` compares the rs1/rs2 fields even for instructions that do not read them
([`14_false_load_stall.s`](../programs/14_false_load_stall.s)). Add `USES_REGISTER1` and
`USES_REGISTER2` outputs to `ControlUnit` (U-type, JAL and immediate CSR forms do not use rs1;
only R-type, stores and branches use rs2) and gate the comparison. Expected: `14_false_load_stall`
goes from 25 to 24 cycles; the model's `falseLoadStalls` counter shows how many remain elsewhere.

## Lab 6: a Return Address Stack

Every `ret` (a JALR) flushes 3 instructions ([`13_function_call_cost.s`](../programs/13_function_call_cost.s):
7 cycles per call). Add a small stack: push `PC + 4` in FETCH2 when a JAL writes `ra`, pop it in
FETCH2 for `jalr x0, 0(ra)` and redirect there, then in EXECUTE only flush if the popped address
was wrong. Expected: about 3 fewer cycles per call.

## Lab 7: predict in FETCH1 with a Branch Target Buffer

A correctly predicted taken branch still costs 1 bubble, because the target is only known in FETCH2.
A Branch Target Buffer (BTB) indexed by the PC in FETCH1 can supply the target a cycle earlier.
Measure how much of `R` disappears on `11_gshare_patterns` and what the BTB costs in area (`make synth`).

## Lab 8: attack the critical path

On the original chip, 56% of the 26 ns clock is the ALU's ripple-carry adder
([critical path](img/silicon/critical_path.svg)). Write a parallel-prefix (Kogge-Stone or
Brent-Kung) adder module, use it inside `ALU`, and compare depth with Yosys (`make synth` then look
at the `ALU` cell count and area). Discuss the second half of that path: the stall signal from the
data cache. How would you move that decision off the path?

## Lab 9: forwarding into EXECUTE instead of DECODE

This design (like the original) forwards into DECODE, which puts `EXECUTE_FORWARD_DATA` (the ALU
output) in front of the EXECUTE pipeline register: ALU -> forwarding mux -> register in one cycle.
Textbook pipelines forward into EXECUTE instead. Sketch both paths on the block diagram and explain
which is longer, and what that means for the clock period.

## Lab 10: put the caches back

The original design used a student-written cache ([`original/eecs151-rv32i/src/cache.sv`](../original/eecs151-rv32i/src/cache.sv))
with a `stall` input. Add a stall input to `Riscv64` that freezes every pipeline register (the
original's `CONTINUE_PIPELINE`), model a fixed miss latency in `ScratchpadMemory`, and add a
`miss` term to the cycle equation.
