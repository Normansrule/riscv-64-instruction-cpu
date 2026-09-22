# `ecall` — Environment Call

[← all instructions](../README.md) · extension **RV64I** · format **SYS** · category *System*

```
trap to the environment (this core: HALT the simulation)
```

## Encoding

![ecall encoding](../../docs/img/instructions/ecall.svg)

```
bit:  31                              0
      0000 0000 0000 0000 0000 0000 0111 0011
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `f` = funct3, `m/p/u` = fence fields.

## Example

`ecall` assembles to **`0x00000073`** = `00000000000000000000000001110011`

![example](../../docs/img/instructions/ecall_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `funct12` | 31:20 | `000000000000` | `000000000000` |
| `rs1` | 19:15 | `00000` | `00000` |
| `funct3` | 14:12 | `000` | `000` |
| `rd` | 11:7 | `00000` | `00000` |
| `opcode` | 6:0 | `1110011` | `1110011` |

Try it yourself:

```bash
node tools/rv.mjs encode "ecall"
node tools/rv.mjs decode 00000073
```

## Control signals set by the decoder (`rtl/decoder.v`)

| signal | value | | signal | value |
|---|---|---|---|---|
| `use_rs1` | 0 | | `is_load` | 0 |
| `use_rs2` | 0 | | `is_store` | 0 |
| `reg_write` | 0 | | `is_branch` | 0 |
| `alu_op` | — (unused) | | `is_jal` / `is_jalr` | 0 / 0 |
| `a_sel` | RS1 | | `wb_pc4` | 0 |
| `b_imm` | 0 | | `is_halt` | 1 |
| `is_word` | 0 | | | |

## Journey through the 6-stage pipeline

| stage | what happens to `ecall` |
|---|---|
| **IF** | Fetch the 32-bit word at `PC` from instruction memory; predict not-taken: `PC ← PC + 4`. |
| **ID** | Decoder recognises `ecall` from opcode `1110011`, funct3 `000`; the immediate generator builds the SYS-type immediate. |
| **RR** | Nothing to read: this instruction has no register sources. |
| **EX** | Halt instruction detected in EX: flush the younger instructions and stop fetching. |
| **MEM** | No memory access: the result passes through to MEM/WB. |
| **WB** | Reaching WB halts the core; the simulation ends. |
