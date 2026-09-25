# RISC-V major opcode map (RV64IM + Zicsr subset implemented here)

The opcode is `inst[6:0]`. For 32-bit instructions `inst[1:0]` is always `11`
(`00`, `01`, `10` mark 16-bit compressed instructions, not implemented here).
Rows are `inst[6:5]`, columns are `inst[4:2]`.

| inst[6:5] \ inst[4:2] | 000 | 001 | 010 | 011 | 100 | 101 | 110 | 111 |
|---|---|---|---|---|---|---|---|---|
| **00** | **LOAD**<br>`0000011` | · | · | **MISC_MEM**<br>`0001111` | **OP_IMM**<br>`0010011` | **AUIPC**<br>`0010111` | **OP_IMM_32**<br>`0011011` | · |
| **01** | **STORE**<br>`0100011` | · | · | · | **OP**<br>`0110011` | **LUI**<br>`0110111` | **OP_32**<br>`0111011` | · |
| **10** | · | · | · | · | · | · | · | · |
| **11** | **BRANCH**<br>`1100011` | **JALR**<br>`1100111` | · | **JAL**<br>`1101111` | **SYSTEM**<br>`1110011` | · | · | · |

## Instructions under each opcode

### LOAD `0000011`

[`lb`](RV64I/lb.md) · [`lh`](RV64I/lh.md) · [`lw`](RV64I/lw.md) · [`ld`](RV64I/ld.md) · [`lbu`](RV64I/lbu.md) · [`lhu`](RV64I/lhu.md) · [`lwu`](RV64I/lwu.md)

### MISC_MEM `0001111`

[`fence`](RV64I/fence.md)

### OP_IMM `0010011`

[`addi`](RV64I/addi.md) · [`slti`](RV64I/slti.md) · [`sltiu`](RV64I/sltiu.md) · [`xori`](RV64I/xori.md) · [`ori`](RV64I/ori.md) · [`andi`](RV64I/andi.md) · [`slli`](RV64I/slli.md) · [`srli`](RV64I/srli.md) · [`srai`](RV64I/srai.md)

### AUIPC `0010111`

[`auipc`](RV64I/auipc.md)

### OP_IMM_32 `0011011`

[`addiw`](RV64I/addiw.md) · [`slliw`](RV64I/slliw.md) · [`srliw`](RV64I/srliw.md) · [`sraiw`](RV64I/sraiw.md)

### STORE `0100011`

[`sb`](RV64I/sb.md) · [`sh`](RV64I/sh.md) · [`sw`](RV64I/sw.md) · [`sd`](RV64I/sd.md)

### OP `0110011`

[`add`](RV64I/add.md) · [`sub`](RV64I/sub.md) · [`sll`](RV64I/sll.md) · [`slt`](RV64I/slt.md) · [`sltu`](RV64I/sltu.md) · [`xor`](RV64I/xor.md) · [`srl`](RV64I/srl.md) · [`sra`](RV64I/sra.md) · [`or`](RV64I/or.md) · [`and`](RV64I/and.md) · [`mul`](RV64M/mul.md) · [`mulh`](RV64M/mulh.md) · [`mulhsu`](RV64M/mulhsu.md) · [`mulhu`](RV64M/mulhu.md) · [`div`](RV64M/div.md) · [`divu`](RV64M/divu.md) · [`rem`](RV64M/rem.md) · [`remu`](RV64M/remu.md)

### LUI `0110111`

[`lui`](RV64I/lui.md)

### OP_32 `0111011`

[`addw`](RV64I/addw.md) · [`subw`](RV64I/subw.md) · [`sllw`](RV64I/sllw.md) · [`srlw`](RV64I/srlw.md) · [`sraw`](RV64I/sraw.md) · [`mulw`](RV64M/mulw.md) · [`divw`](RV64M/divw.md) · [`divuw`](RV64M/divuw.md) · [`remw`](RV64M/remw.md) · [`remuw`](RV64M/remuw.md)

### BRANCH `1100011`

[`beq`](RV64I/beq.md) · [`bne`](RV64I/bne.md) · [`blt`](RV64I/blt.md) · [`bge`](RV64I/bge.md) · [`bltu`](RV64I/bltu.md) · [`bgeu`](RV64I/bgeu.md)

### JALR `1100111`

[`jalr`](RV64I/jalr.md)

### JAL `1101111`

[`jal`](RV64I/jal.md)

### SYSTEM `1110011`

[`ecall`](RV64I/ecall.md) · [`ebreak`](RV64I/ebreak.md) · [`csrrw`](Zicsr/csrrw.md) · [`csrrs`](Zicsr/csrrs.md) · [`csrrc`](Zicsr/csrrc.md) · [`csrrwi`](Zicsr/csrrwi.md) · [`csrrsi`](Zicsr/csrrsi.md) · [`csrrci`](Zicsr/csrrci.md)

