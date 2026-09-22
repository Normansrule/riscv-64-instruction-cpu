# `lbu` — Load Byte Unsigned (zero-extend)

[← all instructions](../README.md) · extension **RV64I** · format **I** · category *Load*

```
rd = zext(M[rs1 + sext(imm)][7:0])
```

## Encoding

![lbu encoding](../../docs/img/instructions/lbu.svg)

```
bit:  31                              0
      iiii iiii iiii ssss s100 dddd d000 0011
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `f` = funct3, `m/p/u` = fence fields.

## Example

`lbu a0, 16(sp)` assembles to **`0x01014503`** = `00000001000000010100010100000011`

![example](../../docs/img/instructions/lbu_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `imm[11:0]` | 31:20 | `iiiiiiiiiiii` | `000000010000` |
| `rs1` | 19:15 | `sssss` | `00010` |
| `funct3` | 14:12 | `100` | `100` |
| `rd` | 11:7 | `ddddd` | `01010` |
| `opcode` | 6:0 | `0000011` | `0000011` |

Try it yourself:

```bash
node tools/rv.mjs encode "lbu a0, 16(sp)"
node tools/rv.mjs decode 01014503
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

| stage | what happens to `lbu` |
|---|---|
| **IF** | Fetch the 32-bit word at `PC` from instruction memory; predict not-taken: `PC ← PC + 4`. |
| **ID** | Decoder recognises `lbu` from opcode `0000011`, funct3 `100`; the immediate generator builds the I-type immediate. |
| **RR** | Read `rs1` from the register file. |
| **EX** | ALU computes the effective address `rs1 + imm`. Operands may be replaced by forwarded values from EX/MEM or MEM/WB. |
| **MEM** | Read memory at the address; zero-extend the 8-bit value to 64 bits. |
| **WB** | Write `rd` ← loaded value. |
