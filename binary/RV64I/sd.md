# `sd`: Store Doubleword

[← all instructions](../README.md) · extension **RV64I** · format **S** · category *Store*

```
M[rs1 + sext(imm)][63:0] = rs2
```

## Encoding

![sd encoding](../../docs/img/instructions/sd.svg)

```
bit:  31                              0
      iiii iiit tttt ssss s011 iiii i010 0011
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `c` = CSR address, `z` = 5-bit CSR immediate, `f` = funct3, `m/p/u` = fence fields.

## Example

`sd a0, 16(sp)` assembles to **`0x00a13823`** = `00000000101000010011100000100011`

![example](../../docs/img/instructions/sd_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `imm[11:5]` | 31:25 | `iiiiiii` | `0000000` |
| `rs2` | 24:20 | `ttttt` | `01010` |
| `rs1` | 19:15 | `sssss` | `00010` |
| `funct3` | 14:12 | `011` | `011` |
| `imm[4:0]` | 11:7 | `iiiii` | `10000` |
| `opcode` | 6:0 | `0100011` | `0100011` |

Try it yourself:

```bash
node tools/rv.mjs encode "sd a0, 16(sp)"
node tools/rv.mjs decode 00a13823
```

## Control signals from the Control Unit ([`src/Control_Unit.sv`](../../src/Control_Unit.sv))

These are the exact values the RTL produces for the example word above (computed by the
bit-exact twin in `model/core.js`, which `make test` checks against the RTL every cycle).

| signal | value | | signal | value |
|---|---|---|---|---|
| `REGISTER_WRITE_ENABLE` | `0` | | `IS_A_MULTIPLY_DIVIDE_INSTRUCTION` | `0` |
| `MEMORY_READ_ENABLE` | `0` | | `IS_A_BRANCH_INSTRUCTION` | `0` |
| `MEMORY_WRITE_ENABLE` | `1` | | `IS_A_JAL_INSTRUCTION` | `0` |
| `CSR_WRITE_ENABLE` | `0` | | `IS_A_JALR_INSTRUCTION` | `0` |
| `CSR_WRITE_USING_IMMEDIATE` | `0` | | `IMMEDIATE_TYPE_SELECT` | `IMMEDIATE_S` |
| `ALU_INPUT_A_IS_PC` | `0` | | `WRITEBACK_SELECT` | `WRITEBACK_ALU` |
| `ALU_INPUT_B_IS_IMMEDIATE` | `1` | | `ALU_OPERATION` | `ALU_ADD` |
| `ALU_IS_WORD_OPERATION` | `0` | |  |  |

## Journey through the 6-stage pipeline

| stage | what happens to `sd` |
|---|---|
| **FETCH1** | The PC is sent to the instruction memory. At the same time the **GSharePredictor** reads the 2-bit counter at `PC[5:2] XOR GLOBAL_HISTORY_REGISTER` (it does not know yet what instruction this is). |
| **FETCH2** | The 32-bit word arrives from memory. It is not a branch or JAL, so fetching simply continues at `PC + 4`. |
| **DECODE** | **ControlUnit** + **ALUdec** recognise `sd` from opcode `0100011`, funct3 `011`; the **ImmediateGenerator** builds the S-type immediate. The **RegisterFile** is read for `rs1` and `rs2`, and the forwarding muxes replace a stale value with a newer one from EXECUTE, MEMORY or WRITEBACK. |
| **EXECUTE** | The ALU computes the address `rs1 + imm` and sends it to the data memory. **StoreControl** moves the low 64 bits of `rs2` into the right byte lanes and sets the 8-bit write mask; the memory is written at the end of this cycle (`0x1000_0000` prints a character instead). |
| **MEMORY** | No memory work. **WriteControl** picks the result value. |
| **WRITEBACK** | Nothing to write. The instruction retires (`instret` + 1). |

See the whole datapath in the [block diagram](../../docs/ARCHITECTURE.md) and step through a program in the [web simulator](../../web/index.html).
