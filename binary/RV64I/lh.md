# `lh` — Load Halfword (sign-extend)

[← all instructions](../README.md) · extension **RV64I** · format **I** · category *Load*

```
rd = sext(M[rs1 + sext(imm)][15:0])
```

## Encoding

![lh encoding](../../docs/img/instructions/lh.svg)

```
bit:  31                              0
      iiii iiii iiii ssss s001 dddd d000 0011
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `f` = funct3, `m/p/u` = fence fields.

## Example

`lh a0, 16(sp)` assembles to **`0x01011503`** = `00000001000000010001010100000011`

![example](../../docs/img/instructions/lh_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `imm[11:0]` | 31:20 | `iiiiiiiiiiii` | `000000010000` |
| `rs1` | 19:15 | `sssss` | `00010` |
| `funct3` | 14:12 | `001` | `001` |
| `rd` | 11:7 | `ddddd` | `01010` |
| `opcode` | 6:0 | `0000011` | `0000011` |

Try it yourself:

```bash
node tools/rv.mjs encode "lh a0, 16(sp)"
node tools/rv.mjs decode 01011503
```

## Control signals set by the decoder (`rtl/decoder.v`)

| signal | value | | signal | value |
|---|---|---|---|---|
| `use_rs1` | 1 | | `is_load` | 1 |
| `use_rs2` | 0 | | `is_store` | 0 |
| `reg_write` | 1 (if rd≠x0) | | `is_branch` | 0 |
| `alu_op` | ADD | | `is_jal` / `is_jalr` | 0 / 0 |
| `a_sel` | RS1 | | `wb_pc4` | 0 |
| `b_imm` | 1 | | `is_halt` | 0 |
| `is_word` | 0 | | | |

## Journey through the 6-stage pipeline

| stage | what happens to `lh` |
|---|---|
| **IF** | Fetch the 32-bit word at `PC` from instruction memory; predict not-taken: `PC ← PC + 4`. |
| **ID** | Decoder recognises `lh` from opcode `0000011`, funct3 `001`; the immediate generator builds the I-type immediate. |
| **RR** | Read `rs1` from the register file. |
| **EX** | ALU computes the effective address `rs1 + imm`. Operands may be replaced by forwarded values from EX/MEM or MEM/WB. |
| **MEM** | Read memory at the address; sign-extend the 16-bit value to 64 bits. |
| **WB** | Write `rd` ← loaded value. |
