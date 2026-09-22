# `lui` — Load Upper Immediate

[← all instructions](../README.md) · extension **RV64I** · format **U** · category *Upper immediate*

```
rd = sext(imm20 << 12)
```

## Encoding

![lui encoding](../../docs/img/instructions/lui.svg)

```
bit:  31                              0
      iiii iiii iiii iiii iiii dddd d011 0111
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `f` = funct3, `m/p/u` = fence fields.

## Example

`lui a0, 0x12345` assembles to **`0x12345537`** = `00010010001101000101010100110111`

![example](../../docs/img/instructions/lui_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `imm[31:12]` | 31:12 | `iiiiiiiiiiiiiiiiiiii` | `00010010001101000101` |
| `rd` | 11:7 | `ddddd` | `01010` |
| `opcode` | 6:0 | `0110111` | `0110111` |

Try it yourself:

```bash
node tools/rv.mjs encode "lui a0, 0x12345"
node tools/rv.mjs decode 12345537
```

## Control signals set by the decoder (`rtl/decoder.v`)

| signal | value | | signal | value |
|---|---|---|---|---|
| `use_rs1` | 0 | | `is_load` | 0 |
| `use_rs2` | 0 | | `is_store` | 0 |
| `reg_write` | 1 (if rd≠x0) | | `is_branch` | 0 |
| `alu_op` | ADD | | `is_jal` / `is_jalr` | 0 / 0 |
| `a_sel` | ZERO | | `wb_pc4` | 0 |
| `b_imm` | 1 | | `is_halt` | 0 |
| `is_word` | 0 | | | |

## Journey through the 6-stage pipeline

| stage | what happens to `lui` |
|---|---|
| **IF** | Fetch the 32-bit word at `PC` from instruction memory; predict not-taken: `PC ← PC + 4`. |
| **ID** | Decoder recognises `lui` from opcode `0110111`; the immediate generator builds the U-type immediate. |
| **RR** | Nothing to read: this instruction has no register sources. |
| **EX** | ALU computes `0 + imm` (A input selects ZERO). |
| **MEM** | No memory access: the result passes through to MEM/WB. |
| **WB** | Write `rd` ← ALU result. |
