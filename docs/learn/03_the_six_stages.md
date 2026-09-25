# 3. The six stages and how to read the diagrams

![block diagram](../img/cpu_block_diagram.svg)

## How to read the block diagram

* **Coloured bands** are the six stages, left to right, in the order an instruction visits them.
* **Thick dark bars** between the bands are the **pipeline registers** (`FETCH2_*`, `DECODE_*`,
  `EXECUTE_*`, `MEMORY_*`, `WRITEBACK_*`). On each clock edge they capture everything the stage to
  their left computed. Nothing crosses a bar except at a clock edge.
* **Boxes** are modules: each has its own file in [`src/`](../../src). Trapezoids are
  multiplexers (they pick one of several inputs).
* **Wires that go right** carry an instruction forward. **Wires that go left** are feedback: forwarding
  (orange, green, red), redirects (cyan), flushes (magenta), predictor updates (teal, dashed).

| stage | modules | what happens |
|---|---|---|
| FETCH1 | `FETCH1_PC`, `GSharePredictor`, instruction memory | send the PC to memory; read a gshare counter to guess whether a branch here will be taken |
| FETCH2 | predecode, target adder | the instruction arrives; a predicted-taken branch or any JAL **redirects** FETCH1 to `PC + imm` |
| DECODE | `ControlUnit`, `ALUdec`, `ImmediateGenerator`, `RegisterFile`, forwarding muxes | make the control signals, read registers, pick the newest value of each source |
| EXECUTE | `ALU`, `MultiplyDivideUnit`, `BranchComparator`, `BranchControl`, `CSRFile`, `StoreControl` | compute; resolve branches; **flush** if a guess was wrong; start loads and do stores |
| MEMORY | `LoadControl`, `WriteControl` | the loaded doubleword arrives; pick and extend the right bytes; choose the result |
| WRITEBACK | `RegisterFile` write port | write `rd`; the instruction retires |

## How to read a pipeline chart

![forwarding](../img/pipeline/02_forwarding.svg)

* Each **row** is one instruction, in fetch order. Each **column** is one clock cycle.
* The coloured box says which stage the instruction is in during that cycle.
* A **small ring** on a DECODE box means one of its operands was forwarded.
* **Hatched** boxes are held by a load stall; **grey, crossed-out** rows were fetched down a
  wrong path and squashed; the bottom row shows hazard events (`stall`, `flush`, `redir`).

Reading a column top to bottom tells you what the whole CPU is doing in that one cycle. Reading a
row left to right tells you the life of one instruction.

## Zoom into one cycle

```bash
make cycle PROG=02_forwarding C=7
```

prints everything that happens in cycle 7: which instruction each stage holds, the gshare index
arithmetic, which operands are forwarded from where, the ALU inputs and output, and what is written
back. The [web simulator](../../web/index.html) shows the same, one Step at a time.

Next: [4. Data hazards](04_data_hazards.md)
