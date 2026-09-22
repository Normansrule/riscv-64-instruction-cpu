# `remuw` — Remainder Word Unsigned

[← all instructions](../README.md) · extension **RV64M** · format **R** · category *Divide*

```
rd = sext(rs1[31:0] %u rs2[31:0])
```

## Encoding

![remuw encoding](../../docs/img/instructions/remuw.svg)

```
bit:  31                              0
      0000 001t tttt ssss s111 dddd d011 1011
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `f` = funct3, `m/p/u` = fence fields.

## Example

`remuw a0, a1, a2` assembles to **`0x02c5f53b`** = `00000010110001011111010100111011`

![example](../../docs/img/instructions/remuw_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `funct7` | 31:25 | `0000001` | `0000001` |
| `rs2` | 24:20 | `ttttt` | `01100` |
| `rs1` | 19:15 | `sssss` | `01011` |
| `funct3` | 14:12 | `111` | `111` |
| `rd` | 11:7 | `ddddd` | `01010` |
| `opcode` | 6:0 | `0111011` | `0111011` |

Try it yourself:

```bash
node tools/rv.mjs encode "remuw a0, a1, a2"
node tools/rv.mjs decode 02c5f53b
```

## Control signals set by the decoder (`rtl/decoder.v`)

| signal | value | | signal | value |
|---|---|---|---|---|
| `use_rs1` | 1 | | `is_load` | 0 |
| `use_rs2` | 1 | | `is_store` | 0 |
| `reg_write` | 1 (if rd≠x0) | | `is_branch` | 0 |
| `alu_op` | REMU | | `is_jal` / `is_jalr` | 0 / 0 |
| `a_sel` | RS1 | | `wb_pc4` | 0 |
| `b_imm` | 0 | | `is_halt` | 0 |
| `is_word` | 1 | | | |

## Journey through the 6-stage pipeline

| stage | what happens to `remuw` |
|---|---|
| **IF** | Fetch the 32-bit word at `PC` from instruction memory; predict not-taken: `PC ← PC + 4`. |
| **ID** | Decoder recognises `remuw` from opcode `0111011`, funct3 `111`, funct7 `0000001`; the immediate generator builds the R-type immediate. |
| **RR** | Read `rs1` and `rs2` from the register file (write-first bypass if WB is writing the same register). |
| **EX** | ALU performs **REMU** on 32 bits, result sign-extended to 64: `rd = sext(rs1[31:0] %u rs2[31:0])`. Operands may be replaced by forwarded values from EX/MEM or MEM/WB. |
| **MEM** | No memory access: the result passes through to MEM/WB. |
| **WB** | Write `rd` ← ALU result. |
