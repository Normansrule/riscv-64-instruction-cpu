# Performance: a shorter critical path, fewer wasted cycles, a realistic memory

How the performance edition was built from the baseline pipeline, what each change bought, and what
it cost. Every number is produced by a script in this repository, and every behavioural change is
verified cycle by cycle against the RTL by `make test`, which builds **both** designs.

| build | how to get it | what it is |
|---|---|---|
| **performance** (default) | `make test`, `make run PROG=...` | 4 KiB 2-way set-associative instruction cache with next-line prefetch, 4 KiB 2-way write-through data cache (LRU replacement), tournament predictor (per-branch history table + gshare + chooser), 16-entry branch target buffer, 8-entry return address stack, precise load stalls, iterative multiply/divide, Kogge-Stone adders |
| **baseline** | `-DBASELINE`, `CONFIG=baseline` | the plain 6-stage pipeline: single-cycle 64 KiB memory, 4-bit gshare only, single-cycle multiply/divide |

Every feature is a parameter of [`src/Riscv64.sv`](../src/Riscv64.sv) / [`src/Riscv64_top.sv`](../src/Riscv64_top.sv)
(`CACHES_ENABLE`, `MISS_LATENCY`, `TOURNAMENT_PREDICTOR`, `BTB_ENABLE`, `RAS_ENABLE`,
`PRECISE_LOAD_STALL`, `ITERATIVE_MULTIPLY_DIVIDE`, `GSHARE_HISTORY_BITS`), with the same switches in
`CONFIGS` in [`model/core.js`](../model/core.js), so each one can be measured on its own.

## The result

![CPI per program](img/charts/performance.svg)

| program | M ops | baseline: cycles | CPI | performance: cycles | CPI | time, baseline 130 nm (7.5 MHz) | time, performance 130 nm (180 MHz) | time, performance 7 nm (1.37 GHz) |
|---|:-:|---:|---:|---:|---:|---:|---:|---:|
| `00_pipeline_fill` |  | 10 | 2.00 | 21 | **4.20** | 1.3 µs | 0.12 µs | 0.02 µs |
| `01_hello` |  | 139 | 1.43 | 147 | **1.52** | 18.5 µs | 0.82 µs | 0.11 µs |
| `02_forwarding` |  | 12 | 1.71 | 23 | **3.29** | 1.6 µs | 0.13 µs | 0.02 µs |
| `03_load_use` |  | 18 | 1.64 | 40 | **3.64** | 2.4 µs | 0.22 µs | 0.03 µs |
| `04_branch_penalty` |  | 50 | 1.52 | 53 | **1.61** | 6.7 µs | 0.29 µs | 0.04 µs |
| `05_fibonacci` |  | 366 | 1.20 | 328 | **1.08** | 48.8 µs | 1.82 µs | 0.24 µs |
| `06_bubble_sort` | yes | 1,124 | 1.56 | 992 | **1.38** | 149.9 µs | 5.51 µs | 0.72 µs |
| `07_factorial_recursive` | yes | 327 | 1.39 | 463 | **1.96** | 43.6 µs | 2.57 µs | 0.34 µs |
| `08_gcd_euclid` | yes | 33 | 1.74 | 76 | **4.00** | 4.4 µs | 0.42 µs | 0.06 µs |
| `09_primes_sieve` | yes | 19,773 | 1.33 | 16,868 | **1.14** | 2636.4 µs | 93.71 µs | 12.29 µs |
| `10_print_numbers` | yes | 737 | 1.37 | 1,024 | **1.90** | 98.3 µs | 5.69 µs | 0.75 µs |
| `11_gshare_patterns` |  | 1,519 | 1.38 | 1,139 | **1.03** | 202.5 µs | 6.33 µs | 0.83 µs |
| `12_measure_cpi` | yes | 122 | 1.28 | 151 | **1.59** | 16.3 µs | 0.84 µs | 0.11 µs |
| `13_function_call_cost` | yes | 174 | 1.54 | 277 | **2.45** | 23.2 µs | 1.54 µs | 0.20 µs |
| `14_false_load_stall` |  | 49 | 1.29 | 82 | **2.16** | 6.5 µs | 0.46 µs | 0.06 µs |
| `15_system_calls` |  | 89 | 1.68 | 116 | **2.19** | 11.9 µs | 0.64 µs | 0.08 µs |
| `16_cache_conflicts` |  | 208 | 1.22 | 440 | **2.57** | 27.7 µs | 2.44 µs | 0.32 µs |
| `17_predictor_challenge` |  | 7,492 | 1.48 | 6,277 | **1.24** | 998.9 µs | 34.87 µs | 4.58 µs |
| `isa_selfcheck` | yes | 7,526 | 1.16 | 18,229 | **2.81** | 1003.5 µs | 101.27 µs | 13.29 µs |

Geometric-mean speed-up of the performance edition over the baseline, both on 130 nm: **17.5x** (clock and cycles together). Cache misses are included: these programs are tiny, so their few cold misses weigh heavily.
## Part 1: cycles per instruction

`cycles = N + 5 + L + 3F + R + K + I + D` ([MATH.md](MATH.md)) says exactly where every cycle above
one per instruction comes from.

| change | term | how | cost |
|---|---|---|---|
| **Branch Target Buffer** | R | 16 entries remember "the instruction at this PC jumped to that PC"; FETCH1 redirects immediately | 960 flip-flops |
| **Return Address Stack** | F | calls push PC + 4 in FETCH2, returns pop and redirect (1 bubble instead of a 3-bubble flush); the pointer is checkpointed and restored on flushes | 8 x 64-bit entries |
| **Tournament predictor** | F | a per-branch history table (fast learner) next to gshare (pattern learner), and a chooser per branch that learns which to trust (Alpha 21264 style) | 2 x 128 two-bit counters |
| **Precise load stalls** | L | `ControlUnit` reports `USES_REGISTER1/2`, so only real dependences stall | a few gates |
| **Instruction cache + next-line prefetch** | I | after a miss on line X, line X + 1 is fetched in the background: sequential code misses half as often (self-check: 917 → 459 misses) | 4 KiB SRAM + tags |
| **Data cache** | D | write-through: stores never wait; only loads that miss wait for their line | 4 KiB SRAM + tags |
| **Data next-line prefetch** | D | after a load miss on line X, line X + 1 is fetched in the background (sieve: 32 → 16 data misses) | a second refill request path |
| **2 ways + LRU** (both caches) | I, D | two lines per set, so addresses 2 KiB apart no longer evict each other; `16_cache_conflicts.s` shows 2 arrays fitting and 3 thrashing | a second tag compare, 1 LRU bit per set |

Why add caches if they add cycles? The baseline assumes 64 KiB of memory that answers in one cycle.
That is fine in a simulator but not in silicon: a memory that large cannot be read in one short clock
cycle. Real CPUs keep small, fast caches next to the pipeline and pay a miss penalty now and then.
The penalty here is `MISS_LATENCY + 1 = 11` cycles; long-running code hides it (the sieve runs at CPI
1.15 with caches), while programs of a few dozen instructions are dominated by their cold misses.

## Part 2: frequency

```bash
make timing                              # both builds on SkyWater 130 nm
tools/timing.sh performance asap7        # the same RTL on ASAP7, a 7 nm-class library
```

sv2v converts the SystemVerilog, Yosys synthesizes it without area-oriented rewriting, and ABC maps
it onto the cell library and reports the longest register-to-register path. **Logic only**: no
wires, clock skew or slow corner; after place and route expect 1.5x to 2.5x longer. The cache
memories are left out (a real chip uses SRAM macros for them).

| step | limiting path | 130 nm |
|---|---|---:|
| baseline RTL, timing-driven flow, M unit excluded | `EXECUTE_PC + 4` incrementer on the flush path | 4.6 ns |
| baseline single-cycle multiply/divide unit alone | 64 subtract steps in a row | **133 ns** |
| Kogge-Stone prefix adders (ALU, branch compare, FETCH2 target), PC + 4 carried down the pipeline | | 4.1 ns (M excluded) |
| iterative multiply/divide unit | its setup, then its negation | 11.1 → 5.9 ns |
| prefix-OR negation, magnitudes a cycle earlier, return check against `rs1` | | 4.8 ns |
| tournament predictor, prefix incrementers for the PCs | FETCH2 target → next-PC mux | 5.0 ns |
| 64-bit counters split into halves with a registered carry (removes the 7 nm counter path) | the multiply step (64 x 16 bits + accumulate) | **5.5 ns (180 MHz)** |

| build | SkyWater 130 nm | ASAP7 7 nm-class |
|---|---:|---:|
| baseline (single-cycle M unit excluded) | 4.1 ns | 0.64 ns (1.57 GHz) |
| **performance** (everything included) | **5.5 ns (180 MHz)** | **0.73 ns (1.37 GHz)** |

## Why not 2 nm, or 0.42 nm?

A process node is a property of the **factory**, not of the Verilog. The RTL describes logic; a
foundry's library of transistors decides how fast that logic switches. The same RTL here gives
5.5 ns on 130 nm and 0.73 ns on a 7 nm-class library, 7.5x faster, without changing a line.

The limiting path differs by process: at 130 nm it is the multiply step, at 7 nm the front end
(FETCH2's target add feeding the next-PC multiplexer). ABC's mapping has some run-to-run spread:
near-equal paths can swap places and move the result by about 10%.

* **2 nm** processes exist commercially (for example at TSMC, Samsung and Intel), but their design
  kits are under non-disclosure agreements; no open library below 7 nm exists to measure with.
  "2 nm" is also a marketing name: the actual gate pitch in such processes is tens of nanometres.
* **0.42 nm** is about the distance between neighbouring silicon atoms (0.235 nm bond length, 0.543 nm
  lattice constant). No transistor can be built at that scale; it is not a process node.

What this repository *can* show is the design side, which carries over to any node: measure the
critical path, make it shallower (prefix adders, prefix negation), spread long work over several
cycles (the iterative M unit), and win the cycles back with prediction and caching. Chips at 2 GHz
and above add deeper pipelines (10 or more stages), out-of-order execution and hand-tuned circuits.

## What to try next

* **Narrow the multiply step** (64 x 8 bits per cycle: shorter at 130 nm, 4 more cycles per multiply).
* **Time the cache hit path**: address → tag compare → `DATA_CACHE_STALL` → every pipeline enable.
  With the tag SRAM included this is likely the next critical path (it was on the 32-bit prototype).
* **Split EXECUTE** into two stages, or resolve branches one stage later, and compare the clock gain
  with the extra bubbles.
* **Radix-4 division**, a 2-way set-associative data cache, or a bigger tournament predictor
  (Labs 10 and 11 in [EXPERIMENTS.md](EXPERIMENTS.md)).
* **Real sign-off**: run OpenROAD on the sv2v output for placed-and-routed numbers.
