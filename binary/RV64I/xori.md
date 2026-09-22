# `xori` — Exclusive OR Immediate

[← all instructions](../README.md) · extension **RV64I** · format **I** · category *Logic (imm)*

```
rd = rs1 ^ sext(imm)
```

## Encoding

![xori encoding](../../docs/img/instructions/xori.svg)

```
bit:  31                              0
      iiii iiii iiii ssss s100 dddd d001 0011
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `f` = funct3, `m/p/u` = fence fields.

## Example

`xori a0, a1, -5` assembles to **`0xffb5c513`** = `11111111101101011100010100010011`

![example](../../docs/img/instructions/xori_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `imm[11:0]` | 31:20 | `iiiiiiiiiiii` | `111111111011` |
| `rs1` | 19:15 | `sssss` | `01011` |
| `funct3` | 14:12 | `100` | `100` |
| `rd` | 11:7 | `ddddd` | `01010` |
| `opcode` | 6:0 | `0010011` | `0010011` |

Try it yourself:

```bash
node tools/rv.mjs encode "xori a0, a1, -5"
node tools/rv.mjs decode ffb5c513
```

## Control signals set by the decoder (`rtl/decoder.v`)

| signal | value | | signal | value |
|---|---|---|---|---|
| `use_rs1` | 1 | | `is_load` | 0 |
| `use_rs2` | 0 | | `is_store` | 0 |
| `reg_write` | 1 (if rd≠x0) | | `is_branch` | 0 |
| `alu_op` | XOR | | `is_jal` / `is_jalr` | 0 / 0 |
| `a_sel` | RS1 | | `wb_pc4` | 0 |
| `b_imm` | 1 | | `is_halt` | 0 |
| `is_word` | 0 | | | |

## Journey through the 6-stage pipeline

| stage | what happens to `xori` |
|---|---|
| **IF** | Fetch the 32-bit word at `PC` from instruction memory; predict not-taken: `PC ← PC + 4`. |
| **ID** | Decoder recognises `xori` from opcode `0010011`, funct3 `100`; the immediate generator builds the I-type immediate. |
| **RR** | Read `rs1` from the register file. |
| **EX** | ALU performs **XOR**: `rd = rs1 ^ sext(imm)`. Operands may be replaced by forwarded values from EX/MEM or MEM/WB. |
| **MEM** | No memory access: the result passes through to MEM/WB. |
| **WB** | Write `rd` ← ALU result. |
