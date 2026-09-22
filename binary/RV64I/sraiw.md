# `sraiw` — Shift Right Arithmetic Immediate Word

[← all instructions](../README.md) · extension **RV64I** · format **I-sh32** · category *Word (32-bit)*

```
rd = sext(rs1[31:0] >>s shamt[4:0])
```

## Encoding

![sraiw encoding](../../docs/img/instructions/sraiw.svg)

```
bit:  31                              0
      0100 000h hhhh ssss s101 dddd d001 1011
```

Fixed bits are `0`/`1`. Letters are filled in by the assembler:
`d` = rd, `s` = rs1, `t` = rs2, `i` = immediate, `h` = shift amount, `f` = funct3, `m/p/u` = fence fields.

## Example

`sraiw a0, a1, 5` assembles to **`0x4055d51b`** = `01000000010101011101010100011011`

![example](../../docs/img/instructions/sraiw_example.svg)

| field | bits | template | example |
|---|---|---|---|
| `funct7` | 31:25 | `0100000` | `0100000` |
| `shamt[4:0]` | 24:20 | `hhhhh` | `00101` |
| `rs1` | 19:15 | `sssss` | `01011` |
| `funct3` | 14:12 | `101` | `101` |
| `rd` | 11:7 | `ddddd` | `01010` |
| `opcode` | 6:0 | `0011011` | `0011011` |

Try it yourself:

```bash
node tools/rv.mjs encode "sraiw a0, a1, 5"
node tools/rv.mjs decode 4055d51b
```

## Control signals set by the decoder (`rtl/decoder.v`)

| signal | value | | signal | value |
|---|---|---|---|---|
| `use_rs1` | 1 | | `is_load` | 0 |
| `use_rs2` | 0 | | `is_store` | 0 |
| `reg_write` | 1 (if rd≠x0) | | `is_branch` | 0 |
| `alu_op` | SRA | | `is_jal` / `is_jalr` | 0 / 0 |
| `a_sel` | RS1 | | `wb_pc4` | 0 |
| `b_imm` | 1 | | `is_halt` | 0 |
| `is_word` | 1 | | | |

## Journey through the 6-stage pipeline

| stage | what happens to `sraiw` |
|---|---|
| **IF** | Fetch the 32-bit word at `PC` from instruction memory; predict not-taken: `PC ← PC + 4`. |
| **ID** | Decoder recognises `sraiw` from opcode `0011011`, funct3 `101`, funct7 `0100000`; the immediate generator builds the I-sh32-type immediate. |
| **RR** | Read `rs1` from the register file. |
| **EX** | ALU performs **SRA** on 32 bits, result sign-extended to 64: `rd = sext(rs1[31:0] >>s shamt[4:0])`. Operands may be replaced by forwarded values from EX/MEM or MEM/WB. |
| **MEM** | No memory access: the result passes through to MEM/WB. |
| **WB** | Write `rd` ← ALU result. |
