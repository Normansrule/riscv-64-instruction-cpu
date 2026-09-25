# =============================================================================
# 02_forwarding.s: a chain of dependent instructions with ZERO stalls
#
# Each instruction needs the result of the one right before it. Without
# forwarding, DECODE would have to wait until the producer had written the
# register file in WRITEBACK. This core forwards INTO DECODE (like the EECS 151
# Riscv151 design): the value is taken from EXECUTE (1 instruction back),
# MEMORY (2 back) or WRITEBACK (3 back), nearest first, and latched into
# EXECUTE together with the instruction.
#
#   What to look for: "fwd rs1: EXECUTE" / "fwd rs2: MEMORY" in the DECODE
#                     stage of the web simulator, and CPI staying low.
# EXPECT: a0 = 26
# EXPECT: a1 = 7
# =============================================================================
    li   a0, 1
    addi a0, a0, 2       # a0 = 3     needs a0 from 1 instr ago -> forwarded from EXECUTE
    add  a0, a0, a0      # a0 = 6     again from EXECUTE
    li   a1, 7           # independent
    add  a0, a0, a1      # a0 = 13    a1 from EXECUTE, a0 from MEMORY
    slli a0, a0, 1       # a0 = 26
    halt
