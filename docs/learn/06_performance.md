# 6. Measuring performance

## CPI

**Cycles Per Instruction (CPI)** = cycles / instructions. A perfect pipeline has CPI 1.0; every
bubble pushes it up. Run time = instructions x CPI x clock period.

## Every cycle is accounted for

The model tags each bubble with the event that created it, so this equation holds **exactly** for
every program (`make math` checks all 30 runs):

```text
cycles = N + 5 + L + 3F + R + K     (K: multiply/divide busy cycles, performance edition)
          |   |   |    |    +-- FETCH2 redirects that survived (1 bubble each)
          |   |   |    +------- flushes from EXECUTE: wrong guesses and JALRs (3 bubbles each)
          |   |   +------------ load stalls (1 bubble each)
          |   +---------------- filling the 6-stage pipeline once
          +-------------------- instructions retired
```

![CPI stack](../img/charts/cpi_stack.svg)

Blue is useful work; every other colour is a type of bubble. Look for which colour dominates a
program: that is the hazard worth fixing first.

## A program that measures itself

The `CSRFile` has two read-only counters, `cycle` and `instret`.
[`12_measure_cpi.s`](../../programs/12_measure_cpi.s) reads both before and after a loop:

```asm
rdcycle   s0            # start the stopwatch
rdinstret s1
loop: ...
rdcycle   s2            # stop it
rdinstret s3
```

A subtle point that real hardware shares: the counters are **read** in EXECUTE but `instret`
**counts** in WRITEBACK, so instructions still in flight around the reads land inside the window.
That is why benchmarks time long loops.

Next: [7. From RTL to silicon](07_silicon.md)
