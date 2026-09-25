# `auipc`: Add Upper Immediate to PC

[← all instructions](../README.md) · extension **RV64I** · format **U** · category *Upper immediate*

```
rd = pc + sext(imm20 << 12)
```

## Encoding

![auipc encoding](../../docs/img/instructions/auipc.svg)

```
bit:  31                              0
      iiii iiii iiii iiii iiii dddd d001 0111
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `c` = CSR address, `z` = 5-bit CSR immediate, `f` = funct3, `m/p/u` = fence fields.

## Example

`auipc a0, 0x12345` assembles to **`0x12345517`** = `00010010001101000101010100010111`

![example](../../docs/img/instructions/auipc_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `imm[31:12]` | 31:12 | `iiiiiiiiiiiiiiiiiiii` | `00010010001101000101` |
| `rd` | 11:7 | `ddddd` | `01010` |
| `opcode` | 6:0 | `0010111` | `0010111` |

Try it yourself:

```bash
node tools/rv.mjs encode "auipc a0, 0x12345"
node tools/rv.mjs decode 12345517
```

## Control signals from the Control Unit ([`src/Control_Unit.sv`](../../src/Control_Unit.sv))

These are the exact values the RTL produces for the example word above (computed by the
bit-exact twin in `model/core.js`, which `make test` checks against the RTL every cycle).

| signal | value | | signal | value |
|---|---|---|---|---|
| `REGISTER_WRITE_ENABLE` | `1` | | `IS_A_MULTIPLY_DIVIDE_INSTRUCTION` | `0` |
| `MEMORY_READ_ENABLE` | `0` | | `IS_A_BRANCH_INSTRUCTION` | `0` |
| `MEMORY_WRITE_ENABLE` | `0` | | `IS_A_JAL_INSTRUCTION` | `0` |
| `CSR_WRITE_ENABLE` | `0` | | `IS_A_JALR_INSTRUCTION` | `0` |
| `CSR_WRITE_USING_IMMEDIATE` | `0` | | `IMMEDIATE_TYPE_SELECT` | `IMMEDIATE_U` |
| `ALU_INPUT_A_IS_PC` | `1` | | `WRITEBACK_SELECT` | `WRITEBACK_ALU` |
| `ALU_INPUT_B_IS_IMMEDIATE` | `1` | | `ALU_OPERATION` | `ALU_ADD` |
| `ALU_IS_WORD_OPERATION` | `0` | |  |  |

## Journey through the 6-stage pipeline

| stage | what happens to `auipc` |
|---|---|
| **FETCH1** | The PC is sent to the instruction memory. At the same time the **GSharePredictor** reads the 2-bit counter at `PC[5:2] XOR GLOBAL_HISTORY_REGISTER` (it does not know yet what instruction this is). |
| **FETCH2** | The 32-bit word arrives from memory. It is not a branch or JAL, so fetching simply continues at `PC + 4`. |
| **DECODE** | **ControlUnit** + **ALUdec** recognise `auipc` from opcode `0010111`; the **ImmediateGenerator** builds the U-type immediate. No registers are needed. |
| **EXECUTE** | The ALU adds `PC + imm` (ALU input A is the PC). |
| **MEMORY** | No memory work. **WriteControl** picks the `WRITEBACK_ALU` value, which can be forwarded back to DECODE. |
| **WRITEBACK** | The **RegisterFile** writes `rd` at the clock edge (ignored if `rd` is `x0`). The instruction is now **retired** and the `instret` counter goes up by one. |

See the whole datapath in the [block diagram](../../docs/ARCHITECTURE.md) and step through a program in the [web simulator](../../web/index.html).
