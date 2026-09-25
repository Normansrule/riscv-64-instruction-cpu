# From the EECS 151 Riscv151 to Riscv64

This CPU grew out of an EECS 151/251A ASIC project (UC Berkeley, Spring 2026): **Riscv151**, a
6-stage RV32I core with a gshare branch predictor, taped out as a placed-and-routed sky130 design.
The student-written original is preserved unchanged in
[`original/eecs151-rv32i/`](../original/eecs151-rv32i) (course-staff files such as the memory
system and test harness are not included).

## What stayed the same

* The six stages and their names: FETCH1, FETCH2, DECODE, EXECUTE, MEMORY, WRITEBACK.
* The idea of predicting in FETCH1, redirecting predicted-taken branches and JALs in FETCH2, and
  checking in EXECUTE (`BranchControl` is logically unchanged).
* Forwarding into DECODE with the priority x0 > EXECUTE > MEMORY > WRITEBACK > register file.
* `LOAD_STALL` comparing the rs1/rs2 fields.
* Every module name and interface style: `ControlUnit`, `ALUdec`, `ImmediateGenerator`,
  `RegisterFile`, `BranchComparator`, `BranchControl`, `GSharePredictor`, `LoadControl`,
  `StoreControl`, `WriteControl`, `CSRFile`, the five packages, and the naming conventions.
* `PC_RESET = 0x2000`, the `tohost` CSR at `0x51E`, 16 counters reset to weakly taken.

## What changed, and why

| area | Riscv151 (original) | Riscv64 (this repo) | why |
|---|---|---|---|
| ISA | RV32I + CSRRW(I) | RV64I + M + full Zicsr | 64-bit registers, multiply/divide, `rdcycle`/`rdinstret` |
| datapath | 32-bit | 64-bit, plus `ALU_IS_WORD_OPERATION` for the W instructions | RV64 |
| ALU | shared 33-bit adder | shared 65-bit adder, W results sign-extended | same trick, wider |
| M extension | none | `MultiplyDivideUnit` next to the ALU | teaching the M instructions |
| global history | shifted on every fetch (`FETCH_IS_A_BRANCH_INSTRUCTION` tied to 1) and nudged on mispredicts | shifted only for real branches in FETCH2; each instruction carries a checkpoint; a flush restores it | the history then matches the real branch sequence (Skadron et al., 2000) |
| CSRs | tohost, status; CSRRS/CSRRC behaved like writes | RW / RS / RC semantics, no write when rs1 = x0, `cycle`, `instret`, `mhartid` | spec-correct `csrr`, self-timing programs |
| memory | I-cache + D-cache (student `cache.sv`) + DRAM model, `stall` input | 64 KiB scratchpad, no stalls | every cycle is explainable and cycle-exact against a model |
| fetch bookkeeping | `POST_FLUSH`, `POST_BRANCHING`, `FETCH1_PC_CYCLE_DELAY` (cache latency) | not needed: the memory answers in exactly one cycle | simpler to read |
| register file reset | reset loop over all registers | no reset (initial values for simulation) | a reset mux per bit is expensive; software never reads before writing |
| verification | VCS + staff test harness | Icarus / Verilator + cycle-exact JavaScript twin, 859-case self-check | open tools, runs anywhere |

## The original's physical design results

From the Innovus post-route reports in the original build (sky130, `sky130_scl_9T` library):

| metric | value |
|---|---|
| die | 3.0 mm x 3.0 mm |
| clock period | 26 ns (38.5 MHz) |
| worst setup slack | +0.163 ns (ss, 100 C, 1.60 V) |
| worst hold slack | +0.041 ns |
| standard cells | 15,753 (16,022 instances) |
| SRAM macros | 8 x `sram22_256x32m4w8` (cache data), 2 x `sram22_64x32m4w8` (tags) |
| cell density | 2.8% (98.5% with fillers) |
| leakage power | 0.030 mW |

See [SILICON.md](SILICON.md) for the pictures.
