# =============================================================================
# 14_false_load_stall.s: a stall caused by bits that only LOOK like a register
#
# LOAD_STALL in src/Riscv64.sv compares the rs1 and rs2 FIELDS (bits 19:15 and
# 24:20) of the DECODE instruction with the load's rd, whether or not the
# instruction really reads those registers. That is simple and always safe,
# but sometimes it stalls for nothing:
#
#   ld   t0, 0(s0)        t0 is x5
#   addi a1, zero, 5      I-type: bits 24:20 are imm[4:0] = 00101 = "x5"!
#                         -> LOAD_STALL, although addi never reads rs2
#
#   ld   t0, 0(s0)
#   addi a1, zero, 6      imm[4:0] = 00110 = "x6" -> no stall
#
#   a0 = cycles for version A (false stall)    a1 = cycles for version B
# The web simulator marks the first stall "false". Lab 5 in docs/EXPERIMENTS.md
# adds USES_REGISTER1/USES_REGISTER2 signals to the Control Unit to remove it.
#
# EXPECT: a2 = 5
# EXPECT: a3 = 6
# EXPECT: a0 = 4
# EXPECT: a1 = 3
# =============================================================================
    la   s0, value
    nop
    nop
    nop
    rdcycle t2
    ld   t0, 0(s0)
    addi a2, zero, 5         # false LOAD_STALL: imm 5 sits where rs2 would be
    rdcycle t3
    nop
    nop
    nop
    rdcycle t4
    ld   t0, 0(s0)
    addi a3, zero, 6         # no stall
    rdcycle t5
    sub  a0, t3, t2
    sub  a1, t5, t4
    halt

    .align 3
value:
    .dword 42
