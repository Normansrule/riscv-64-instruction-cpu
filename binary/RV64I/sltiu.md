# `sltiu` — Set if Less Than Immediate Unsigned

[← all instructions](../README.md) · extension **RV64I** · format **I** · category *Compare (imm)*

```
rd = (rs1 <u sext(imm)) ? 1 : 0
```

## Encoding

![sltiu encoding](../../docs/img/instructions/sltiu.svg)

```
bit:  31                              0
      iiii iiii iiii ssss s011 dddd d001 0011
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `f` = funct3, `m/p/u` = fence fields.

## Example

`sltiu a0, a1, -5` assembles to **`0xffb5b513`** = `11111111101101011011010100010011`

![example](../../docs/img/instructions/sltiu_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `imm[11:0]` | 31:20 | `iiiiiiiiiiii` | `111111111011` |
| `rs1` | 19:15 | `sssss` | `01011` |
| `funct3` | 14:12 | `011` | `011` |
| `rd` | 11:7 | `ddddd` | `01010` |
| `opcode` | 6:0 | `0010011` | `0010011` |

Try it yourself:

```bash
node tools/rv.mjs encode "sltiu a0, a1, -5"
node tools/rv.mjs decode ffb5b513
```

## Control signals set by the decoder (`rtl/decoder.v`)

| signal | value | | signal | value |
|---|---|---|---|---|
| `use_rs1` | 1 | | `is_load` | 0 |
| `use_rs2` | 0 | | `is_store` | 0 |
| `reg_write` | 1 (if rd≠x0) | | `is_branch` | 0 |
| `alu_op` | SLTU | | `is_jal` / `is_jalr` | 0 / 0 |
| `a_sel` | RS1 | | `wb_pc4` | 0 |
| `b_imm` | 1 | | `is_halt` | 0 |
| `is_word` | 0 | | | |

## Journey through the 6-stage pipeline

| stage | what happens to `sltiu` |
|---|---|
| **IF** | Fetch the 32-bit word at `PC` from instruction memory; predict not-taken: `PC ← PC + 4`. |
| **ID** | Decoder recognises `sltiu` from opcode `0010011`, funct3 `011`; the immediate generator builds the I-type immediate. |
| **RR** | Read `rs1` from the register file. |
| **EX** | ALU performs **SLTU**: `rd = (rs1 <u sext(imm)) ? 1 : 0`. Operands may be replaced by forwarded values from EX/MEM or MEM/WB. |
| **MEM** | No memory access: the result passes through to MEM/WB. |
| **WB** | Write `rd` ← ALU result. |
