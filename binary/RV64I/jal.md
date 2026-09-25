# `jal`: Jump And Link

[← all instructions](../README.md) · extension **RV64I** · format **J** · category *Jump*

```
rd = pc + 4; pc = pc + sext(imm)
```

## Encoding

![jal encoding](../../docs/img/instructions/jal.svg)

```
bit:  31                              0
      iiii iiii iiii iiii iiii dddd d110 1111
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `c` = CSR address, `z` = 5-bit CSR immediate, `f` = funct3, `m/p/u` = fence fields.

## Example

`jal ra, +2048` assembles to **`0x001000ef`** = `00000000000100000000000011101111`

![example](../../docs/img/instructions/jal_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `imm[20|10:1|11|19:12]` | 31:12 | `iiiiiiiiiiiiiiiiiiii` | `00000000000100000000` |
| `rd` | 11:7 | `ddddd` | `00001` |
| `opcode` | 6:0 | `1101111` | `1101111` |

Try it yourself:

```bash
node tools/rv.mjs encode "jal ra, 2048"   # use a label or a number for the offset
node tools/rv.mjs decode 001000ef
```

## Control signals from the Control Unit ([`src/Control_Unit.sv`](../../src/Control_Unit.sv))

These are the exact values the RTL produces for the example word above (computed by the
bit-exact twin in `model/core.js`, which `make test` checks against the RTL every cycle).

| signal | value | | signal | value |
|---|---|---|---|---|
| `REGISTER_WRITE_ENABLE` | `1` | | `IS_A_MULTIPLY_DIVIDE_INSTRUCTION` | `0` |
| `MEMORY_READ_ENABLE` | `0` | | `IS_A_BRANCH_INSTRUCTION` | `0` |
| `MEMORY_WRITE_ENABLE` | `0` | | `IS_A_JAL_INSTRUCTION` | `1` |
| `CSR_WRITE_ENABLE` | `0` | | `IS_A_JALR_INSTRUCTION` | `0` |
| `CSR_WRITE_USING_IMMEDIATE` | `0` | | `IMMEDIATE_TYPE_SELECT` | `IMMEDIATE_J` |
| `ALU_INPUT_A_IS_PC` | `1` | | `WRITEBACK_SELECT` | `WRITEBACK_PC_ADD_4` |
| `ALU_INPUT_B_IS_IMMEDIATE` | `1` | | `ALU_OPERATION` | `ALU_ADD` |
| `ALU_IS_WORD_OPERATION` | `0` | |  |  |

## Journey through the 6-stage pipeline

| stage | what happens to `jal` |
|---|---|
| **FETCH1** | The PC is sent to the instruction memory. At the same time the **GSharePredictor** reads the 2-bit counter at `PC[5:2] XOR GLOBAL_HISTORY_REGISTER` (it does not know yet what instruction this is). |
| **FETCH2** | The word arrives. Opcode `1101111` = JAL: the target `PC + imm` is computed right here and FETCH1 is **always** redirected (the jump is never wrong), squashing the one instruction fetched behind it (1 bubble). |
| **DECODE** | **ControlUnit** + **ALUdec** recognise `jal` from opcode `1101111`; the **ImmediateGenerator** builds the J-type immediate. No registers are needed. |
| **EXECUTE** | The ALU computes `PC + imm` (not needed any more) and `PC + 4` becomes the link value. BranchControl sees a JAL: it was already redirected in FETCH2, so **no flush**. |
| **MEMORY** | No memory work. **WriteControl** picks the `WRITEBACK_PC_ADD_4` value, which can be forwarded back to DECODE. |
| **WRITEBACK** | The **RegisterFile** writes `rd` at the clock edge (ignored if `rd` is `x0`). The instruction is now **retired** and the `instret` counter goes up by one. |

See the whole datapath in the [block diagram](../../docs/ARCHITECTURE.md) and step through a program in the [web simulator](../../web/index.html).
